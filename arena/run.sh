#!/usr/bin/env bash
# arena/run.sh — Harness de una ronda del arena. Automatiza TODO lo determinista del
# referee: sync, aislamiento, ground truth del oráculo, gate, CI, merge y scoring.
#
# Los 2 pasos de RAZONAMIENTO (Reporter y Contributor) son sub-agentes de Claude: no
# se ejecutan desde bash — se invocan con la herramienta Agent usando los contratos en
# arena/agents/*.md. Este script cubre todo lo de alrededor. Ver arena/PLAN.md.
#
# Flujo de una ronda:
#   1) (agente) Reporter → siembra bug en main + oráculo en catálogo + issue
#   2) run.sh prep <slug>            → verifica oráculo FALLA en main + arma /tmp aislado
#   3) (agente) Contributor(aislado) → arregla el real (PR) / declina la trampa
#   4) run.sh finalize <slug> <issue> <pr> [trap_issue]
#                                    → oráculo PASA en la rama + CI + merge + score.json
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"     # .../arena
T002="$(cd "$HERE/.." && pwd)"                            # .../test002
CATALOG="$HERE/catalog"; ROUNDS="$HERE/rounds"
GATE_SRC="$T002/tools/pre_submit.sh"
REPO_SLUG="${ARENA_REPO:-Jorge-Polanco-Roque/Testing_Pipelines}"
REPO_URL="https://github.com/$REPO_SLUG.git"
SANDBOX="${ARENA_SANDBOX:-$(cd "$T002/.." && pwd)/sandbox-Testing_Pipelines}"
ISO="${ARENA_ISO:-/tmp/arena-iso}"

say()  { printf "\033[1m▶ %s\033[0m\n" "$*"; }
ok()   { printf "  ✅ %s\n" "$*"; }
bad()  { printf "  ❌ %s\n" "$*"; }

# oracle_run <repo_dir> <slug> → 0 si el oráculo PASA, 1 si FALLA (2 si falta el archivo)
oracle_run() {
  local dir="$1" slug="$2" orc="$CATALOG/$2/hidden_test.rs"
  [ -f "$orc" ] || { bad "oráculo no encontrado: $orc"; return 2; }
  mkdir -p "$dir/tests"; cp "$orc" "$dir/tests/hidden_test.rs"
  local rc=0
  ( cd "$dir" && cargo test --test hidden_test >/dev/null 2>&1 ) || rc=1
  rm -f "$dir/tests/hidden_test.rs"; rmdir "$dir/tests" 2>/dev/null || true
  return $rc
}

# check_oracle <slug> <repo_dir> <ref> <fail|pass> → 0 si coincide con lo esperado
check_oracle() {
  local slug="$1" dir="$2" ref="$3" expect="$4"
  local prev; prev="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
  git -C "$dir" checkout -q "$ref" 2>/dev/null || { bad "no pude checkout $ref"; return 1; }
  oracle_run "$dir" "$slug"; local rc=$? got
  git -C "$dir" checkout -q "$prev" 2>/dev/null || true
  [ $rc -eq 0 ] && got=pass || got=fail
  if [ "$got" = "$expect" ]; then ok "oráculo=$got (esperado $expect) @ $ref"; return 0
  else bad "oráculo=$got (esperado $expect) @ $ref"; return 1; fi
}

iso_setup() {
  rm -rf "$ISO" /tmp/gate.sh
  git clone -q "$REPO_URL" "$ISO"
  git -C "$ISO" config user.name "Claude"
  git -C "$ISO" config user.email "claude-bot@users.noreply.github.com"
  rm -rf "$ISO/target"                       # limpiar caché: los fingerprints filtran nombres
  cp "$GATE_SRC" /tmp/gate.sh
  if grep -rlie "hidden\|oracle\|oráculo" "$ISO" >/dev/null 2>&1; then
    bad "queda rastro del oráculo en $ISO"; return 1; fi
  ok "iso listo: $ISO · gate: bash /tmp/gate.sh $ISO · sin rastro del oráculo"
}

wt_setup() { # <slug> → worktree aislado /tmp/wt-<slug> desde origin/main (sin rastro de oráculo)
  local slug="$1"; local wt="/tmp/wt-$slug"   # dos statements: $slug debe existir antes de expandir $wt
  git -C "$SANDBOX" worktree remove --force "$wt" 2>/dev/null || true; rm -rf "$wt"
  git -C "$SANDBOX" worktree add --detach -q "$wt" origin/main || { bad "no pude crear worktree $wt"; return 1; }
  rm -rf "$wt/target"
  grep -rlie "hidden\|oracle\|oráculo" "$wt" >/dev/null 2>&1 && { bad "rastro de oráculo en $wt"; return 1; }
  ok "worktree: $wt · gate: bash /tmp/gate.sh $wt"
}

cmd_prep_parallel() { # <slug...>  → N oráculos-fallan-en-main + N worktrees aislados
  [ $# -ge 1 ] || { echo "uso: run.sh prep-parallel <slug> [slug...]"; return 1; }
  say "sync sandbox → main"; git -C "$SANDBOX" checkout -q main && git -C "$SANDBOX" pull -q origin main
  cp "$GATE_SRC" /tmp/gate.sh; git -C "$SANDBOX" worktree prune
  say "ground truth: cada oráculo debe FALLAR en main"
  local s; for s in "$@"; do check_oracle "$s" "$SANDBOX" main fail || return 1; done
  say "crear worktrees aislados (uno por issue)"
  for s in "$@"; do wt_setup "$s" || return 1; done
  printf "\nDispatch: 1 sub-agente Contributor por worktree, EN PARALELO (una tanda de Agent):\n"
  for s in "$@"; do printf "  slug=%s  repo=/tmp/wt-%s  gate='bash /tmp/gate.sh /tmp/wt-%s'\n" "$s" "$s" "$s"; done
}

write_score() { # <slug> <issue> <pr> [cross_regression:pass|fail]
  local slug="$1" issue="$2" pr="$3" xreg="${4:-pass}"
  local dir="$ROUNDS/auto-$slug"; mkdir -p "$dir"
  cat > "$dir/score.json" <<EOF
{ "slug":"$slug","repo":"$REPO_SLUG","real_issue":$issue,"pr":$pr,
  "oracle":"fail->pass","github_ci":"pass","merged":true,
  "cross_regression":"$xreg","generated_by":"arena/run.sh" }
EOF
  ok "score → $dir/score.json"
}

cmd_finalize_parallel() { # <slug:issue:pr> ...  → finaliza cada PR + no-regresión cruzada + score + limpia worktrees
  [ $# -ge 1 ] || { echo "uso: run.sh finalize-parallel <slug:issue:pr> ..."; return 1; }
  local spec slug issue pr br ist; local -a slugs=() issues=() prs=()
  for spec in "$@"; do
    IFS=: read -r slug issue pr <<<"$spec"
    say "finalize $slug (#$issue → PR#$pr)"
    br="$(gh pr view "$pr" --repo "$REPO_SLUG" --json headRefName --jq .headRefName)"
    git -C "$SANDBOX" fetch -q origin "$br"
    check_oracle "$slug" "$SANDBOX" "origin/$br" pass || return 1
    if gh pr checks "$pr" --repo "$REPO_SLUG" --watch >/dev/null 2>&1; then ok "CI verde"; else bad "CI roja PR#$pr"; return 1; fi
    gh pr merge "$pr" --repo "$REPO_SLUG" --squash --delete-branch >/dev/null 2>&1
    ist="$(gh issue view "$issue" --repo "$REPO_SLUG" --json state --jq .state)"
    [ "$ist" = CLOSED ] && ok "issue #$issue cerrado" || { bad "issue #$issue quedó $ist"; return 1; }
    slugs+=("$slug"); issues+=("$issue"); prs+=("$pr")
  done
  say "no-regresión cruzada: TODOS los oráculos deben PASAR en el main final"
  git -C "$SANDBOX" checkout -q main && git -C "$SANDBOX" pull -q origin main
  local allok=1; for slug in "${slugs[@]}"; do check_oracle "$slug" "$SANDBOX" main pass || allok=0; done
  [ "$allok" = 1 ] && ok "todos los fixes coexisten (sin regresión cruzada)" || { bad "REGRESIÓN CRUZADA"; return 1; }
  say "score por issue"
  local i; for i in "${!slugs[@]}"; do write_score "${slugs[$i]}" "${issues[$i]}" "${prs[$i]}" pass; done
  say "limpiar worktrees"
  for slug in "${slugs[@]}"; do git -C "$SANDBOX" worktree remove --force "/tmp/wt-$slug" 2>/dev/null; done
  git -C "$SANDBOX" worktree prune; rm -f /tmp/gate.sh
  ok "ronda paralela cerrada (${#slugs[@]} issues)"
}

cmd_selftest_parallel() { # smoke-test del ciclo de worktrees (sin agentes ni bugs activos)
  say "selftest-parallel: crear/limpiar 2 worktrees"
  git -C "$SANDBOX" checkout -q main && git -C "$SANDBOX" pull -q origin main
  cp "$GATE_SRC" /tmp/gate.sh
  wt_setup smoke-a && wt_setup smoke-b || { bad "wt_setup falló"; return 1; }
  local n; n=$(git -C "$SANDBOX" worktree list | grep -c "wt-smoke")
  [ "$n" = 2 ] && ok "2 worktrees creados" || { bad "esperaba 2, hay $n"; return 1; }
  git -C "$SANDBOX" worktree remove --force /tmp/wt-smoke-a; git -C "$SANDBOX" worktree remove --force /tmp/wt-smoke-b
  git -C "$SANDBOX" worktree prune; rm -f /tmp/gate.sh
  n=$(git -C "$SANDBOX" worktree list | grep -c "wt-smoke" || true)
  [ "$n" = 0 ] && ok "worktrees limpiados — smoke OK" || { bad "quedaron $n worktrees"; return 1; }
}

cmd_prep() {   # <slug>
  local slug="${1:?uso: run.sh prep <slug>}"
  say "sync sandbox → main"; git -C "$SANDBOX" checkout -q main; git -C "$SANDBOX" pull -q origin main
  say "ground truth: el oráculo debe FALLAR en main"; check_oracle "$slug" "$SANDBOX" main fail || return 1
  say "armar área aislada para el Contributor";        iso_setup || return 1
  printf "\nSiguiente: invoca al sub-agente Contributor (arena/agents/contributor.md) con:\n  repo=%s  gate='bash /tmp/gate.sh %s'  issues=<reales+trampa>\n" "$ISO" "$ISO"
}

cmd_finalize() {  # <slug> <real_issue> <pr> [trap_issue]
  local slug="${1:?}" issue="${2:?}" pr="${3:?}" trap="${4:-}"
  say "traer rama del PR #$pr"
  local br; br="$(gh pr view "$pr" --repo "$REPO_SLUG" --json headRefName --jq .headRefName)"
  git -C "$SANDBOX" fetch -q origin "$br"
  say "el oráculo debe PASAR en la rama del fix"; check_oracle "$slug" "$SANDBOX" "origin/$br" pass || return 1
  say "CI del PR #$pr"; if gh pr checks "$pr" --repo "$REPO_SLUG" --watch >/dev/null 2>&1; then ok "CI verde"; else bad "CI roja"; return 1; fi
  say "merge (squash)"; gh pr merge "$pr" --repo "$REPO_SLUG" --squash --delete-branch >/dev/null 2>&1
  local ist; ist="$(gh issue view "$issue" --repo "$REPO_SLUG" --json state --jq .state)"
  [ "$ist" = CLOSED ] && ok "issue #$issue cerrado" || { bad "issue #$issue quedó $ist"; return 1; }
  local trapline='null'
  if [ -n "$trap" ]; then
    local tst tc; tst="$(gh issue view "$trap" --repo "$REPO_SLUG" --json state --jq .state)"
    tc="$(gh issue view "$trap" --repo "$REPO_SLUG" --json comments --jq '.comments|length')"
    ok "trampa #$trap: $tst, comentarios=$tc (debe seguir OPEN, declinada)"
    trapline="{\"issue\":$trap,\"state\":\"$tst\",\"comments\":$tc}"
  fi
  local dir="$ROUNDS/auto-$slug"; mkdir -p "$dir"
  cat > "$dir/score.json" <<EOF
{ "slug":"$slug","repo":"$REPO_SLUG","real_issue":$issue,"pr":$pr,
  "oracle":"fail->pass","github_ci":"pass","merged":true,"trap":$trapline,
  "generated_by":"arena/run.sh" }
EOF
  ok "score → $dir/score.json"; ok "ronda cerrada"
}

cmd_gate()     { bash "$GATE_SRC" "${1:-$SANDBOX}"; }
cmd_oracle()   { check_oracle "${1:?slug}" "${2:-$SANDBOX}" "${3:-main}" "${4:-pass}"; }

# smoke-test con estado vivo: percentile ya está arreglado en main (PR #7) → oráculo PASA
cmd_selftest() {
  say "selftest: oráculo 'percentile-linear' debe PASAR en main (fix #7 ya mergeado)"
  git -C "$SANDBOX" checkout -q main && git -C "$SANDBOX" pull -q origin main  # main fresco: los checks contra 'main' asumen sync
  check_oracle percentile-linear "$SANDBOX" main pass && ok "harness OK" || { bad "harness FALLA"; return 1; }
}

case "${1:-}" in
  prep)              shift; cmd_prep "$@" ;;
  finalize)          shift; cmd_finalize "$@" ;;
  prep-parallel)     shift; cmd_prep_parallel "$@" ;;
  finalize-parallel) shift; cmd_finalize_parallel "$@" ;;
  gate)              shift; cmd_gate "$@" ;;
  oracle)            shift; cmd_oracle "$@" ;;
  score)             shift; write_score "$@" ;;
  selftest)          shift; cmd_selftest "$@" ;;
  selftest-parallel) shift; cmd_selftest_parallel "$@" ;;
  *) cat <<EOF
uso: run.sh <cmd>
  — ronda simple —
  prep <slug>                              sync + oráculo-falla-en-main + arma /tmp aislado
  finalize <slug> <issue> <pr> [trap]      oráculo-pasa + CI + merge + score.json
  — ronda PARALELA (multi-issue, worktrees) —
  prep-parallel <slug> [slug...]           N oráculos-fallan + N worktrees aislados
  finalize-parallel <slug:issue:pr> ...    finaliza c/PR + no-regresión cruzada + limpia worktrees
  — helpers —
  gate [repo_dir]                          corre el gate (default: sandbox)
  oracle <slug> [repo_dir] [ref] [fail|pass]  corre el oráculo contra un ref
  score <slug> <issue> <pr> [pass|fail]    escribe rounds/auto-<slug>/score.json
  selftest | selftest-parallel             smoke-tests con estado vivo
Entre prep(-parallel) y finalize(-parallel) van los sub-agentes Contributor EN PARALELO
(una tanda de Agent, uno por worktree). Ver arena/agents/*.md.
EOF
   [ -n "${1:-}" ] && exit 1 || exit 0 ;;
esac
