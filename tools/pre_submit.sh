#!/usr/bin/env bash
# pre_submit.sh — GATE DE CALIDAD + SEGURIDAD antes de abrir/actualizar un PR.
# Corre el propio tooling del repo (formato, lint, build, tests) y una etapa de
# seguridad (secretos, vulnerabilidades de deps, SAST). Solo da luz verde si TODO
# pasa. Ningún PR sale sin esto. Filosofía ponytail: no reinventamos pruebas;
# usamos las del repo y herramientas estándar, best-effort si no están instaladas.
#
# Uso:
#   bash tools/pre_submit.sh [ruta_repo]        # calidad + seguridad (default: .)
#   bash tools/pre_submit.sh --security [ruta]  # solo la etapa de seguridad
#   bash tools/pre_submit.sh --check            # self-test de detección de stack
set -uo pipefail

export PATH="$HOME/.cargo/bin:$PATH"   # cargo-audit y otras herramientas de cargo viven aquí

step() { printf "\n\033[1m▶ %s\033[0m\n" "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }
fail=0
run() { # "descripción" comando...
  local desc="$1"; shift
  echo "  · $desc: $*"
  if "$@"; then echo "    ✅ ok"; else echo "    ❌ FALLÓ"; fail=1; fi
}
sec() { # binario "descripción" comando...  → corre si el binario existe; si no, omite (no falla)
  local bin="$1" desc="$2"; shift 2
  if have "$bin"; then run "$desc" "$@"
  else echo "  · $desc: ⚠ $bin no instalado — omitido (instálalo para cobertura real)"; fi
}

detect() { # imprime stacks detectados en el dir $1
  local d="$1" s=""
  [ -f "$d/Cargo.toml" ] && s="$s rust"
  [ -f "$d/go.mod" ] && s="$s go"
  { [ -f "$d/pyproject.toml" ] || [ -f "$d/setup.py" ] || ls "$d"/*.py >/dev/null 2>&1; } && s="$s python"
  [ -f "$d/package.json" ] && s="$s node"
  { [ -f "$d/CMakeLists.txt" ] || [ -f "$d/Makefile" ]; } && s="$s cpp"
  echo "${s# }"
}

# patrón de secretos obvios (una sola definición). Empieza con '-----' → siempre pasar con -e.
SECRET_RE='-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36,}|xox[baprs]-[0-9A-Za-z-]{10,}|AIza[0-9A-Za-z_-]{35}'

secrets_scan() { # secretos en lo que va a salir: gitleaks si está; si no, grep de patrones obvios
  step "Seguridad · secretos"
  if have gitleaks; then
    # historial de la rama + árbol de trabajo (incl. untracked), no solo lo commiteado
    run "gitleaks (git)"    gitleaks detect --no-banner --redact
    run "gitleaks (árbol)"  gitleaks detect --no-git --no-banner --redact
    return
  fi
  echo "  · gitleaks no instalado — fallback grep de patrones obvios"
  local hits
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # --untracked: cubre archivos nuevos aún sin 'git add'; --exclude-standard: respeta .gitignore
    hits=$(git grep -nIE --untracked --exclude-standard -e "$SECRET_RE" -- . ':!tools/pre_submit.sh' 2>/dev/null || true)
  else
    # carpeta que no es repo git: grep directo, saltando dirs pesados
    hits=$(grep -rnIE --exclude-dir='.git' --exclude-dir='node_modules' --exclude-dir='target' \
           --exclude-dir='dist' --exclude-dir='build' --exclude-dir='vendor' --exclude-dir='.venv' \
           -e "$SECRET_RE" . 2>/dev/null || true)
  fi
  if [ -n "$hits" ]; then echo "$hits"; echo "    ❌ posibles secretos en el árbol"; fail=1
  else echo "    ✅ sin patrones obvios"; fi
}

diff_base() { # imprime la merge-base con la rama por defecto, o vacío si estamos en ella / no hay git
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  local def cur
  def="$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')"; [ -z "$def" ] && def=main
  cur="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  [ "$cur" != "$def" ] || return
  git rev-parse --verify -q "origin/$def" >/dev/null || return
  git merge-base HEAD "origin/$def" 2>/dev/null
}

changed_files() { # <base> → archivos que introdujo esta rama (commits + working tree + untracked)
  local base="$1"
  { [ -n "$base" ] && git diff --name-only "$base" HEAD 2>/dev/null
    git diff --name-only HEAD 2>/dev/null
    git diff --name-only --cached 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u
}

deps_touched() { # <lista_cambiados> <archivos_dep...> → 1 si el diff tocó algún manifiesto/lock
  local changed="$1"; shift
  local f
  for f in "$@"; do printf '%s\n' "$changed" | grep -qE "(^|/)$f\$" && { echo 1; return; }; done
  echo 0
}

sast_semgrep() { # SAST diff-aware: bloquea solo por hallazgos NUEVOS vs la base
  step "Seguridad · SAST (patrones de código riesgoso)"
  have semgrep || { echo "  · semgrep: ⚠ no instalado — omitido"; return; }
  local base; base="$(diff_base)"
  if [ -n "$base" ]; then
    run "semgrep (nuevo vs base)" semgrep --error --quiet --baseline-commit "$base" --config auto .
  else
    echo "  · semgrep (informativo — sin base de diff; no bloquea deuda pre-existente):"
    semgrep --quiet --config auto . 2>&1 | grep -E "Finding|❯|❱|uses:|Details:" | sed 's/^/    /' || true
  fi
}

sca_run() { # <label> <touched:0|1> <bin> <cmd...> — SCA diff-aware
  local label="$1" touched="$2" bin="$3"; shift 3
  have "$bin" || { echo "  · $label: ⚠ $bin no instalado — omitido"; return; }
  if [ "$touched" = 1 ]; then
    # tocamos deps → somos responsables: bloquea por vulnerabilidades
    run "$label (deps tocadas → bloquea)" "$@"
  else
    # no tocamos deps → una vuln pre-existente NO es nuestra: informar, no bloquear
    if "$@" >/tmp/sca-out 2>&1; then
      echo "  · $label (informativo): ✅ sin vulnerabilidades"
    else
      echo "  · $label (informativo — no tocamos deps; deuda pre-existente NO bloquea):"
      grep -iE "RUSTSEC|GHSA|CVE|vulnerab|advisor|found [0-9]" /tmp/sca-out | head -5 | sed 's/^/    /'
    fi
  fi
}

diff_risk_scan() { # advisory: construcciones riesgosas NUEVAS en el diff (surfacea al revisor, NO bloquea)
  step "Revisión de riesgo del diff (advisory)"
  local base; base="$(diff_base)"
  [ -n "$base" ] || { echo "  · sin base de diff — omitido"; return; }
  local added
  added="$( { git diff --unified=0 "$base" -- . 2>/dev/null | grep '^+' | grep -v '^+++'
              git ls-files --others --exclude-standard 2>/dev/null | while read -r f; do sed 's/^/+/' "$f" 2>/dev/null; done
            } )"
  [ -n "$added" ] || { echo "  ✅ sin líneas añadidas"; return; }
  # patrones de riesgo (Rust-centric): panics, unsafe, casts truncantes, errores tragados, lints silenciados
  local re='\.unwrap\(\)|\.expect\(|panic!\(|unreachable!\(|todo!\(|unimplemented!\(|[^A-Za-z_]unsafe[ {]| as (u|i)(8|16|32|64|128|size)| as f(32|64)|let _ =|\.ok\(\)|unwrap_or_default\(\)|#\[allow'
  local hits; hits="$(printf '%s\n' "$added" | grep -nE "$re" || true)"
  if [ -n "$hits" ]; then
    echo "  ⚠ construcciones riesgosas introducidas por este diff (revisar — advisory, no bloquea):"
    printf '%s\n' "$hits" | sed 's/^/    /' | head -25
    echo "    → justifica cada unsafe (// SAFETY:); evita unwrap/panic en libs; revisa casts 'as' (truncan/desbordan) y errores tragados (let _ / .ok())"
  else
    echo "  ✅ sin construcciones riesgosas nuevas"
  fi
}

security_stage() { # depende de $STACKS ya calculado
  secrets_scan
  step "Seguridad · dependencias (CVE conocidas) — diff-aware"
  local base changed t; base="$(diff_base)"; changed="$(changed_files "$base")"
  # ponytail: keyed en el MANIFIESTO, no en lockfiles. Un lockfile generado sin commitear
  # (p.ej. Cargo.lock untracked tras build) NO debe contar como "deps tocadas" → falso positivo.
  # Ceiling: un `cargo update`/`npm update` solo-lockfile se pierde (raro; suele venir con manifiesto).
  for st in $STACKS; do case "$st" in
    rust)   t=$(deps_touched "$changed" Cargo.toml);                                      sca_run "cargo audit"  "$t" cargo-audit cargo audit ;;
    go)     t=$(deps_touched "$changed" go.mod);                                          sca_run "govulncheck"  "$t" govulncheck govulncheck ./... ;;
    python) t=$(deps_touched "$changed" pyproject.toml requirements.txt requirements.in setup.py setup.cfg Pipfile); sca_run "pip-audit" "$t" pip-audit pip-audit ;;
    node)   t=$(deps_touched "$changed" package.json);                                    sca_run "npm audit"    "$t" npm npm audit --audit-level=high ;;
    cpp)    echo "  · C/C++: sin audit estándar de deps — revisar manualmente." ;;
  esac; done
  sast_semgrep
  diff_risk_scan
}

# --- self-test de la única lógica no trivial: la detección de stack ---
if [ "${1:-}" = "--check" ]; then
  t=$(mktemp -d); mkdir -p "$t/r" "$t/p"; : > "$t/r/Cargo.toml"; : > "$t/p/pyproject.toml"
  [ "$(detect "$t/r")" = "rust" ]   || { echo "FAIL: rust";   rm -rf "$t"; exit 1; }
  [ "$(detect "$t/p")" = "python" ] || { echo "FAIL: python"; rm -rf "$t"; exit 1; }
  rm -rf "$t"; echo "OK: detección de stack correcta"; exit 0
fi

SECURITY_ONLY=0
if [ "${1:-}" = "--security" ]; then SECURITY_ONLY=1; shift; fi

REPO="${1:-.}"; cd "$REPO" 2>/dev/null || { echo "No existe: $REPO"; exit 1; }
STACKS=$(detect .)
[ -z "$STACKS" ] && { echo "Stack desconocido en $REPO — corre los checks del repo a mano."; exit 2; }
echo "Repo: $(pwd)"; echo "Stack(s): $STACKS"

if [ "$SECURITY_ONLY" -eq 0 ]; then
  for st in $STACKS; do case "$st" in
    rust)
      step "Rust"
      have cargo && run "formato" cargo fmt --all -- --check
      # ponytail: -D warnings iguala el rigor de muchos CI; relajar si el repo ya trae warnings viejos
      have cargo && run "lint"    cargo clippy --all-targets -- -D warnings
      have cargo && run "build"   cargo build --all-targets
      have cargo && run "tests"   cargo test --all ;;
    go)
      step "Go"
      have gofmt && run "formato" bash -c 'test -z "$(gofmt -l .)"'
      have go && run "vet"   go vet ./...
      have go && run "tests" go test ./... ;;
    python)
      step "Python"
      have ruff   && run "lint/formato" ruff check .
      have pytest && run "tests"        pytest -q ;;
    node)
      step "Node"
      have npm && run "lint"  npm run --if-present lint
      have npm && run "tests" npm test --if-present ;;
    cpp)
      step "C/C++"
      echo "  · build/test de C/C++ varía por repo; replica su CI local a mano." ;;
  esac; done
fi

security_stage

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ GATE OK (calidad + seguridad) — listo para revisar y abrir el PR."
else
  echo "❌ GATE FALLÓ — NO abrir PR. Arregla lo rojo primero."; exit 1
fi
