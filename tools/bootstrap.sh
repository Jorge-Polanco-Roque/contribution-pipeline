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
# SCA Python
if [ -n "$BREW" ]; then ensure pip-audit brew brew install pip-audit; else note "⏭️ pip-audit (requiere brew)"; fi
# SCA Rust (compila desde crates.io)
if have cargo; then ensure cargo-audit cargo cargo install cargo-audit --locked; else note "⏭️ cargo-audit (requiere cargo)"; fi
# SCA Go (solo si hay Go)
if have go; then ensure govulncheck go go install golang.org/x/vuln/cmd/govulncheck@latest; else note "⏭️ govulncheck (requiere Go, ausente)"; fi

echo; echo "== Resumen Fase 0 =="; printf "%s\n" "${REPORT[@]}"
echo; echo "Nota: cargo-audit deja el binario en ~/.cargo/bin — asegúrate de que esté en tu PATH."
