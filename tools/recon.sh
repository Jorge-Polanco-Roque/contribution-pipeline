#!/usr/bin/env bash
# recon.sh — reconocimiento de repos para decidir DÓNDE contribuir (read-only, no toca nada).
#   recon.sh profile <owner/repo>        perfil de salud + veredicto GO/MAYBE/SKIP
#   recon.sh find <lang> [min_stars]     repos ≥stars en el nicho con good-first-issues abiertos
#   recon.sh issues <owner/repo>         lista los good-first-issue / help-wanted abiertos
# Filtro duro por defecto: ≥100 estrellas. Fuente: gh api / gh search.
set -uo pipefail
MIN_STARS="${MIN_STARS:-100}"
have(){ command -v "$1" >/dev/null 2>&1; }
have gh || { echo "requiere gh"; exit 1; }
have jq || { echo "requiere jq"; exit 1; }

days_since() { # <iso8601> → días desde esa fecha (macOS date)
  local iso="$1" then now
  then=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso" +%s 2>/dev/null) || { echo 9999; return; }
  now=$(date +%s); echo $(( (now - then) / 86400 ))
}

count_issues() { # <repo> <label> → total_count real (search API)
  gh api -X GET search/issues \
    -f q="repo:$1 is:issue is:open label:\"$2\"" --jq '.total_count' 2>/dev/null || echo 0
}

cmd_profile() {
  local repo="${1:?uso: recon.sh profile <owner/repo>}"
  local j; j=$(gh repo view "$repo" --json nameWithOwner,stargazerCount,forkCount,isArchived,isFork,pushedAt,primaryLanguage,licenseInfo 2>/dev/null) \
    || { echo "❌ no existe o es privado: $repo"; return 1; }
  local stars forks archived isfork pushed lang license
  stars=$(jq -r '.stargazerCount' <<<"$j"); forks=$(jq -r '.forkCount' <<<"$j")
  archived=$(jq -r '.isArchived' <<<"$j"); isfork=$(jq -r '.isFork' <<<"$j")
  pushed=$(jq -r '.pushedAt' <<<"$j"); lang=$(jq -r '.primaryLanguage.name // "?"' <<<"$j")
  license=$(jq -r '.licenseInfo.spdxId // "none"' <<<"$j")
  local age; age=$(days_since "$pushed")
  local gfi hw; gfi=$(count_issues "$repo" "good first issue"); hw=$(count_issues "$repo" "help wanted")
  local contrib ci
  contrib=$(gh api "repos/$repo/contents/CONTRIBUTING.md" >/dev/null 2>&1 && echo sí || echo no)
  ci=$(gh api "repos/$repo/contents/.github/workflows" --jq 'length' 2>/dev/null || echo 0)

  # --- salud fina (v2) ---
  local since merged30 ext dco tr=""
  since=$(date -v-30d +%Y-%m-%d 2>/dev/null || echo "1970-01-01")
  merged30=$(gh api -X GET search/issues -f q="repo:$repo is:pr is:merged merged:>=$since" --jq '.total_count' 2>/dev/null || echo 0)
  # PRs de EXTERNOS mergeados (muestra de 30 recientes cerrados) → ¿aceptan gente de fuera?
  ext=$(gh api "repos/$repo/pulls?state=closed&per_page=30" \
        --jq '[.[]|select(.merged_at!=null)|select(.author_association=="CONTRIBUTOR" or .author_association=="NONE" or .author_association=="FIRST_TIME_CONTRIBUTOR")]|length' 2>/dev/null || echo 0)
  # ¿DCO? Signed-off-by en commits recientes
  dco=$(gh api "repos/$repo/commits?per_page=15" --jq '[.[]|select(.commit.message|test("Signed-off-by"))]|length' 2>/dev/null || echo 0)
  # task-runner (preferible al workflow para paridad del gate)
  local f; for f in Makefile justfile .pre-commit-config.yaml noxfile.py tox.ini; do
    gh api "repos/$repo/contents/$f" >/dev/null 2>&1 && tr="$tr $f"; done
  [ -z "$tr" ] && tr=" (ninguno)"
  local dco_note="no"; [ "$dco" -gt 7 ] && dco_note="sí (Signed-off-by)"

  # --- veredicto ---
  local verdict reason=""
  if [ "$archived" = true ]; then verdict="⛔ SKIP"; reason="archivado"
  elif [ "$isfork" = true ]; then verdict="⛔ SKIP"; reason="es un fork (posible honeypot)"
  elif [ "$stars" -lt "$MIN_STARS" ]; then verdict="⛔ SKIP"; reason="<$MIN_STARS estrellas ($stars)"
  elif [ "$age" -gt 60 ]; then verdict="⚠️ MAYBE"; reason="último push hace $age días (maintainer lento)"
  elif [ "$((gfi + hw))" -eq 0 ]; then verdict="⚠️ MAYBE"; reason="sin good-first-issue/help-wanted abiertos"
  elif [ "$ci" -eq 0 ]; then verdict="⚠️ MAYBE"; reason="sin CI en .github/workflows"
  elif [ "$merged30" -eq 0 ]; then verdict="⚠️ MAYBE"; reason="sin PRs mergeados en 30 días (¿activo con PRs?)"
  elif [ "$ext" -eq 0 ]; then verdict="⚠️ MAYBE"; reason="sin merges de externos recientes (¿aceptan de fuera?)"
  else verdict="✅ GO"; reason="sano, activo, con issues acogedores y merges de externos"; fi

  cat <<EOF
── Perfil: $repo ────────────────────────────────
  ⭐ estrellas   : $stars   (mín $MIN_STARS) · forks: $forks
  🗣️ lenguaje    : $lang · licencia: $license
  🕒 último push : hace $age días
  🧩 issues      : good-first-issue=$gfi · help-wanted=$hw
  🔁 PRs         : mergeados 30d=$merged30 · de externos (muestra 30)=$ext
  📜 CONTRIBUTING: $contrib · CI workflows: $ci · DCO: $dco_note
  🔧 task-runner : $tr
  🏷️ archivado=$archived · fork=$isfork
  VEREDICTO: $verdict — $reason
EOF
}

cmd_find() {
  local lang="${1:?uso: recon.sh find <lang> [min_stars]}" stars="${2:-$MIN_STARS}"
  echo "Buscando repos $lang con ≥$stars estrellas y good-first-issues abiertos (por recencia)…"
  gh search repos --language "$lang" --stars ">=$stars" --good-first-issues ">=1" \
      --sort updated --limit 25 --json fullName,stargazersCount,description 2>/dev/null \
    | jq -r '.[] | "\(.stargazersCount)\t\(.fullName)\t\((.description // "")[0:60])"' \
    | sort -rn | awk -F'\t' '{printf "  ⭐%-7s %-40s %s\n", $1, $2, $3}'
}

cmd_issues() {
  local repo="${1:?uso: recon.sh issues <owner/repo>}"
  echo "── good-first-issue / help-wanted abiertos en $repo ──"
  gh issue list --repo "$repo" --state open --limit 20 \
      --search 'label:"good first issue","help wanted" sort:created-desc' \
      --json number,title,labels 2>/dev/null \
    | jq -r '.[] | "  #\(.number)  \(.title)"' | head -20
}

cmd_ci() { # <owner/repo> — extrae los comandos que corre el CI del repo (para paridad del gate)
  local repo="${1:?uso: recon.sh ci <owner/repo>}"
  local files; files=$(gh api "repos/$repo/contents/.github/workflows" --jq '.[].name' 2>/dev/null | grep -E '\.ya?ml$')
  if [ -z "$files" ]; then echo "sin .github/workflows en $repo"; else
    local f
    for f in $files; do
      echo "── workflow: $f ──"
      gh api "repos/$repo/contents/.github/workflows/$f" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null | awk '
        function trim(s){ gsub(/^[ \t]+|[ \t]+$/,"",s); return s }
        { raw=$0; ind=match(raw,/[^ ]/)
          if (inblk){ if (raw ~ /^[ \t]*$/) next; if (ind<=blk){inblk=0} else { if (trim(raw) !~ /^#/) print "    $ " trim(raw); next } }
          if (raw ~ /run:[ \t]*[|>]/){ blk=index(raw,"run"); inblk=1; next }
          if (raw ~ /run:[ \t]*[^ \t|>]/){ c=raw; sub(/^.*run:[ \t]*/,"",c); print "    $ " trim(c); next }
          if (raw ~ /uses:[ \t]*/){ u=raw; sub(/^.*uses:[ \t]*/,"",u); print "    · uses " trim(u); next }
        }'
    done
  fi
  echo "── config de toolchain detectada ──"
  local cfg found=0
  for cfg in .pre-commit-config.yaml Makefile justfile noxfile.py tox.ini rust-toolchain.toml rust-toolchain .nvmrc .python-version; do
    gh api "repos/$repo/contents/$cfg" >/dev/null 2>&1 && { echo "    ⚙️ $cfg"; found=1; }
  done
  [ "$found" = 0 ] && echo "    (ninguna)"
}

cmd_t1() { # T1 — precisión de veredictos de recon sobre repos de estado CONOCIDO
  echo "T1 — recon accuracy (SKIP = descartado · OK = GO/MAYBE, elegible):"
  local pass=0 fail=0 spec repo expect verdict got
  # ground truth independiente: 0★ y archivado → SKIP; repos sanos grandes → OK
  local -a cases=(
    "Jorge-Polanco-Roque/Testing_Pipelines:SKIP"   # 0 estrellas
    "angular/angular.js:SKIP"                       # archivado
    "BurntSushi/ripgrep:OK"                         # sano, activo
    "uutils/coreutils:OK"                           # sano, acogedor
    "sharkdp/bat:OK"                                # sano, activo
  )
  for spec in "${cases[@]}"; do
    repo="${spec%:*}"; expect="${spec##*:}"
    verdict=$(cmd_profile "$repo" 2>/dev/null | grep "VEREDICTO:")
    if printf '%s' "$verdict" | grep -q "SKIP"; then got=SKIP; else got=OK; fi
    if [ "$got" = "$expect" ]; then pass=$((pass+1)); printf "  ✅ %-38s %s\n" "$repo" "$verdict"
    else fail=$((fail+1)); printf "  ❌ %-38s esperaba %s → %s\n" "$repo" "$expect" "$verdict"; fi
  done
  echo "  → $pass/$((pass+fail)) correctos"; [ "$fail" -eq 0 ]
}

case "${1:-}" in
  profile) shift; cmd_profile "$@" ;;
  find)    shift; cmd_find "$@" ;;
  issues)  shift; cmd_issues "$@" ;;
  ci)      shift; cmd_ci "$@" ;;
  t1)      shift; cmd_t1 "$@" ;;
  *) cat <<EOF
uso: recon.sh <cmd>   (read-only; filtro duro ≥$MIN_STARS estrellas)
  profile <owner/repo>        salud + veredicto GO/MAYBE/SKIP
  find <lang> [min_stars]     repos del nicho con good-first-issues abiertos
  issues <owner/repo>         good-first-issue / help-wanted abiertos del repo
  ci <owner/repo>             comandos que corre el CI del repo (paridad del gate)
  t1                          test de precisión de veredictos (repos conocidos)
EOF
   [ -n "${1:-}" ] && exit 1 || exit 0 ;;
esac
