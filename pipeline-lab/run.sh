#!/usr/bin/env bash
# run.sh — Laboratorio del pipeline. Construye fixtures efímeros (mini-repos por
# stack + casos de seguridad), corre tools/pre_submit.sh contra cada uno, captura
# la salida en results/ y asevera exit code / contenido esperado.
#
# Objetivo: cazar falsos negativos/positivos y bugs del gate de forma reproducible,
# para iterar sobre él con evidencia. Secretos usados = ejemplos sintéticos.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
GATE="$HERE/../tools/pre_submit.sh"
RESULTS="$HERE/results"; rm -rf "$RESULTS"; mkdir -p "$RESULTS"
LAB="$(mktemp -d)"; trap 'rm -rf "$LAB"' EXIT

AWS='AKIAIOSFODNN7EXAMPLE'                 # clave de ejemplo canónica de AWS (sintética)
GHP="ghp_$(printf 'A%.0s' {1..36})"        # token GitHub sintético (ghp_ + 36)

pass=0; fail=0
declare -a ROWS

# build_git <dir>: repo git con un commit base (identidad local, sin firmar)
build_git() {
  local d="$1"; git init -q "$d"
  git -C "$d" config user.email lab@local; git -C "$d" config user.name lab
}
commit() { git -C "$1" add -A && git -C "$1" commit -qm x; }

# run_case <name> <sec|full> <exitN|grep:STR> <dir>
run_case() {
  local name="$1" mode="$2" assert="$3" dir="$4" out rc ok
  if [ "$mode" = sec ]; then out=$(bash "$GATE" --security "$dir" 2>&1); rc=$?
  else                        out=$(bash "$GATE" "$dir" 2>&1); rc=$?; fi
  printf '%s\n' "$out" > "$RESULTS/$name.log"
  case "$assert" in
    exit*)  [ "$rc" = "${assert#exit}" ] && ok=1 || ok=0 ;;
    grep:*) printf '%s' "$out" | grep -qF "${assert#grep:}" && ok=1 || ok=0 ;;
  esac
  if [ "$ok" = 1 ]; then pass=$((pass+1)); ROWS+=("✅ $name — $assert (rc=$rc)")
  else                   fail=$((fail+1)); ROWS+=("❌ $name — esperaba $assert, rc=$rc  → results/$name.log"); fi
}

# ---------- Fixtures de seguridad (deterministas vía fallback grep) ----------
d="$LAB/sec-clean";     build_git "$d"; : > "$d/pyproject.toml"; echo 'x=1' > "$d/a.py"; commit "$d"
run_case sec-clean sec exit0 "$d"

d="$LAB/sec-aws";       build_git "$d"; : > "$d/pyproject.toml"; echo "KEY='$AWS'" > "$d/cfg.py"; commit "$d"
run_case sec-aws sec exit1 "$d"

d="$LAB/sec-privkey";   build_git "$d"; : > "$d/pyproject.toml"; printf -- '-----BEGIN OPENSSH PRIVATE KEY-----\nx\n' > "$d/id"; commit "$d"
run_case sec-privkey sec exit1 "$d"

d="$LAB/sec-ghtoken";   build_git "$d"; : > "$d/pyproject.toml"; echo "TOK='$GHP'" > "$d/t.py"; commit "$d"
run_case sec-ghtoken sec exit1 "$d"

# Secreto en archivo NO agregado (untracked): el gate debe atraparlo igual
d="$LAB/sec-untracked"; build_git "$d"; : > "$d/pyproject.toml"; commit "$d"; echo "KEY='$AWS'" > "$d/leak.py"
run_case sec-untracked sec exit1 "$d"

# Secreto en carpeta que NO es repo git: el gate debe atraparlo igual
d="$LAB/sec-nongit";    mkdir -p "$d"; : > "$d/pyproject.toml"; echo "KEY='$AWS'" > "$d/cfg.py"
run_case sec-nongit sec exit1 "$d"

# ---------- Fixtures de detección / exit codes ----------
d="$LAB/unknown";       build_git "$d"; echo hi > "$d/README.md"; commit "$d"
run_case unknown-stack full exit2 "$d"

d="$LAB/multi";         build_git "$d"; : > "$d/pyproject.toml"; : > "$d/package.json"; commit "$d"
run_case multi-stack full "grep:Stack(s): python node" "$d"

# ---------- Reporte ----------
{
  echo "# Resultados — $(printf '%s casos, %s ok, %s fallos' "$((pass+fail))" "$pass" "$fail")"
  printf '%s\n' "${ROWS[@]}"
} | tee "$RESULTS/summary.txt"

[ "$fail" -eq 0 ]
