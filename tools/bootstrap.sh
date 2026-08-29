#!/usr/bin/env bash
# bootstrap.sh — Fase 0: instala/verifica el tooling de calidad+seguridad del pipeline.
# Idempotente (si ya está, lo reporta y sigue) · best-effort (un fallo no aborta).
# Uso: bash tools/bootstrap.sh
set -uo pipefail

export PATH="$HOME/.cargo/bin:$PATH"          # cargo install deja binarios aquí
have(){ command -v "$1" >/dev/null 2>&1; }
declare -a REPORT
note(){ REPORT+=("$1"); printf "%s\n" "$1"; }

ensure(){ # <bin> <etiqueta_método> <cmd...>
  local bin="$1" how="$2"; shift 2
  if have "$bin"; then note "✅ $bin — ya presente"; return; fi
  printf "⏳ instalando %s (%s)...\n" "$bin" "$how"
  if "$@" >"/tmp/bootstrap-$bin.log" 2>&1 && have "$bin"; then
    note "✅ $bin — instalado"
  else
    note "❌ $bin — falló o no quedó en PATH (ver /tmp/bootstrap-$bin.log)"
  fi
}

echo "== Fase 0: tooling de seguridad =="
BREW=""; have brew && { BREW=1; echo "Homebrew: $(command -v brew)"; } || echo "⚠️ sin Homebrew"

# Secretos
if [ -n "$BREW" ]; then ensure gitleaks brew brew install gitleaks; else note "⏭️ gitleaks (requiere brew)"; fi
# SAST
if [ -n "$BREW" ]; then ensure semgrep brew brew install semgrep; else note "⏭️ semgrep (requiere brew)"; fi
# SCA multi-ecosistema (base OSV)
if [ -n "$BREW" ]; then ensure osv-scanner brew brew install osv-scanner; else note "⏭️ osv-scanner (requiere brew)"; fi
# SCA Python — vía uv/pipx sobre python3.12. NO usar `brew install pip-audit`: engancha
# python@3.14, cuyo pyexpat busca un símbolo de libexpat que el del sistema no tiene → crashea.
if have uv;   then ensure pip-audit uv   uv tool install pip-audit --python python3.12
elif have pipx; then ensure pip-audit pipx pipx install pip-audit
else note "⏭️ pip-audit (instala uv o pipx; evita brew por el bug de python@3.14/pyexpat)"; fi
# SCA Rust (compila desde crates.io)
if have cargo; then ensure cargo-audit cargo cargo install cargo-audit --locked; else note "⏭️ cargo-audit (requiere cargo)"; fi
# Semver de API (reto 6): detecta rupturas de API pública en libs
if have cargo; then ensure cargo-semver-checks cargo cargo install cargo-semver-checks --locked; else note "⏭️ cargo-semver-checks (requiere cargo)"; fi
# SCA Go (solo si hay Go)
if have go; then ensure govulncheck go go install golang.org/x/vuln/cmd/govulncheck@latest; else note "⏭️ govulncheck (requiere Go, ausente)"; fi

echo; echo "== Resumen Fase 0 =="; printf "%s\n" "${REPORT[@]}"
echo; echo "Nota: los binarios de cargo (cargo-audit, cargo-semver-checks) van a ~/.cargo/bin — el gate ya lo añade al PATH."
echo "Deep-gate opt-in (correr solo cuando el diff lo amerite — ver arena/CHALLENGES.md):"
echo "  · UB/soundness (retos 5,7): rustup toolchain install nightly && cargo +nightly miri test"
echo "  · concurrencia (reto 7): loom como dev-dep en tests del repo"
echo "  · propiedad/fuzz (retos 1,2,9): proptest/quickcheck (dev-dep) · cargo-fuzz (nightly)"
echo "  · rendimiento (reto 3): criterion (dev-dep) con umbral de regresión"
