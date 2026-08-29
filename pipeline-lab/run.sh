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

# Secretos sintéticos que gitleaks Y el grep-fallback cazan (NO allowlisteados).
# Nota: una AWS Access Key ID (AKIA…) por sí sola NO es secreto → gitleaks no la marca; no la usamos.
GHP='ghp_1a2B3c4D5e6F7g8H9i0JkLmNoPqRsTuVwXyz'                          # github-pat (ghp_ + 36)
SLACK='xoxb-1234567890123-1234567890123-aBcDeFgHiJkLmNoPqRsTuVwX'       # slack-bot-token
PRIVKEY='-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAAB\n-----END OPENSSH PRIVATE KEY-----'

pass=0; fail=0
declare -a ROWS

# build_git <dir>: repo git con un commit base (identidad local, sin firmar)
build_git() {
  local d="$1"; git init -q "$d"
  git -C "$d" config user.email lab@local; git -C "$d" config user.name lab
}
commit() { git -C "$1" add -A && git -C "$1" commit -qm x; }

# build_wt_repo <dir>: repo con bare origin/main + rama 'feature' (para que diff_base del gate resuelva).
# El caller añade archivos (untracked) al working tree; el risk-scan los ve como líneas nuevas.
build_wt_repo() {
  local d="$1" o="$1.origin.git"
  # pyproject.toml va en el BASE (tracked, sin cambios en la rama) → SCA advisory, no bloquea.
  build_git "$d"; echo base > "$d/base.txt"; : > "$d/pyproject.toml"; commit "$d"
  git init -q --bare "$o"; git -C "$d" remote add origin "$o"; git -C "$d" branch -M main
  git -C "$d" push -q -u origin main; git -C "$d" remote set-head origin -a >/dev/null 2>&1
  git -C "$d" checkout -q -b feature
}

# build_wt_rust <dir> <contenido_lib_base>: crate rust con bare origin/main + rama 'feature'
build_wt_rust() {
  local d="$1" o="$1.origin.git"
  build_git "$d"
  printf '[package]\nname = "labcrate"\nversion = "0.1.0"\nedition = "2021"\n\n[dependencies]\n' > "$d/Cargo.toml"
  mkdir -p "$d/src"; printf '%s\n' "$2" > "$d/src/lib.rs"; commit "$d"
  git init -q --bare "$o"; git -C "$d" remote add origin "$o"; git -C "$d" branch -M main
  git -C "$d" push -q -u origin main; git -C "$d" remote set-head origin -a >/dev/null 2>&1
  git -C "$d" checkout -q -b feature
}

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

# ---------- Fixtures de seguridad (deterministas con gitleaks o con grep-fallback) ----------
d="$LAB/sec-clean";     build_git "$d"; : > "$d/pyproject.toml"; echo 'x=1' > "$d/a.py"; commit "$d"
run_case sec-clean sec exit0 "$d"

d="$LAB/sec-slack";     build_git "$d"; : > "$d/pyproject.toml"; echo "TOK='$SLACK'" > "$d/cfg.py"; commit "$d"
run_case sec-slack sec exit1 "$d"

d="$LAB/sec-privkey";   build_git "$d"; : > "$d/pyproject.toml"; printf '%b\n' "$PRIVKEY" > "$d/id"; commit "$d"
run_case sec-privkey sec exit1 "$d"

d="$LAB/sec-ghtoken";   build_git "$d"; : > "$d/pyproject.toml"; echo "TOK='$GHP'" > "$d/t.py"; commit "$d"
run_case sec-ghtoken sec exit1 "$d"

# Secreto en archivo NO agregado (untracked): el gate debe atraparlo igual
d="$LAB/sec-untracked"; build_git "$d"; : > "$d/pyproject.toml"; commit "$d"; echo "TOK='$GHP'" > "$d/leak.py"
run_case sec-untracked sec exit1 "$d"

# Secreto en carpeta que NO es repo git: el gate debe atraparlo igual
d="$LAB/sec-nongit";    mkdir -p "$d"; : > "$d/pyproject.toml"; echo "TOK='$GHP'" > "$d/cfg.py"
run_case sec-nongit sec exit1 "$d"

# ---------- Fixtures hyper-experto: risk-scan del diff (diff-aware, advisory) ----------
# Diff con construcciones riesgosas nuevas → el gate debe SURFACEARLAS (unwrap/unsafe/cast as).
d="$LAB/risk-scan"; build_wt_repo "$d"
printf 'fn f(x: &[u8]) -> u8 {\n    let n = x.len() as u8;\n    let a = unsafe { *x.get_unchecked(0) };\n    a.wrapping_add(n)\n}\nfn g(m: Option<u8>) -> u8 { m.unwrap() }\n' > "$d/risky.rs"
run_case risk-scan sec "grep:construcciones riesgosas" "$d"

# Diff sin construcciones riesgosas → mensaje de "sin construcciones riesgosas nuevas".
d="$LAB/risk-clean"; build_wt_repo "$d"
printf 'fn add(a: i32, b: i32) -> i32 {\n    a + b\n}\n' > "$d/clean.rs"
run_case risk-clean sec "grep:sin construcciones riesgosas nuevas" "$d"

# ---------- Fixtures del gate diff-aware de calidad (clippy + feature-aware) ----------
# clippy: hallazgo NUEVO en el diff → bloquea (surfacea "en TU diff").
d="$LAB/clippy-new"; build_wt_rust "$d" 'pub fn ok() -> i32 { 1 }'
printf '\npub fn bad() -> i32 { return 2; }\n' >> "$d/src/lib.rs"   # needless_return en código NUEVO
run_case clippy-new full "grep:en TU diff" "$d"

# clippy: hallazgo PRE-EXISTENTE (en el base) + diff limpio → NO bloquea (deuda ajena).
d="$LAB/clippy-pre"; build_wt_rust "$d" 'pub fn bad() -> i32 { return 2; }'
printf '\npub fn ok() -> i32 { 3 }\n' >> "$d/src/lib.rs"           # adición limpia; el warning es del base
run_case clippy-pre full "grep:pre-existentes" "$d"

# feature-aware: el diff añade una feature → el gate la detecta y prueba con ella.
d="$LAB/feat-aware"; build_wt_rust "$d" 'pub fn ok() -> i32 { 1 }'
printf '\n[features]\nfoo = []\n' >> "$d/Cargo.toml"
run_case feat-aware full "grep:features introducidas por el diff" "$d"

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
