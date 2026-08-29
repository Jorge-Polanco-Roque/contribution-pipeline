#!/usr/bin/env bash
# scan_bounties.sh — escanea bounties RECIENTES y abiertos en GitHub, por label + lenguaje.
# El $ real vive en Algora/Opire (usar Playwright para eso); esto descubre candidatos
# y su antigüedad, que es el mejor proxy de "poca competencia todavía".
#
# Uso:
#   bash tools/scan_bounties.sh [dias] [lenguajes...]
#     dias       antigüedad máxima del bounty (default 14)
#     lenguajes  default: rust python c++ go
#   bash tools/scan_bounties.sh --check      # self-test del cálculo de fecha
#
# Ejemplos:
#   bash tools/scan_bounties.sh 7 rust c++         # solo lo de la última semana
#   bash tools/scan_bounties.sh 30 rust python
set -euo pipefail

# ponytail: denylist por substring de repos-trampa vistos + tope por repo (MAXPER)
# que neutraliza cualquier repo que floodee, aunque no esté en la denylist.
DENY='oss-hunter|livefire|gitops-test-target|workedtask|refact-sublime|agent-bounties|NSPG13'
MAXPER=2  # máx issues por repo, para que un spam-repo no domine el listado

since_date() { # $1 = dias
  date -v-"${1}"d +%Y-%m-%d 2>/dev/null || date -d "-${1} days" +%Y-%m-%d
}

if [ "${1:-}" = "--check" ]; then
  s=$(since_date 14)
  [[ "$s" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "FAIL: fecha inválida: $s"; exit 1; }
  [ "$s" \< "$(date +%Y-%m-%d)" ] || { echo "FAIL: cutoff no es anterior a hoy"; exit 1; }
  echo "OK: cutoff 14d = $s (anterior a hoy)"; exit 0
fi

DAYS="${1:-14}"; [ $# -gt 0 ] && shift || true
LANGS=("$@"); [ ${#LANGS[@]} -eq 0 ] && LANGS=(rust python c++ go)
SINCE=$(since_date "$DAYS")

echo "# Bounties abiertos (label bounty), creados desde $SINCE — más nuevos primero"
echo "# Verificar \$ y # de /attempt en el board de Algora/Opire antes de decidir."

for lang in "${LANGS[@]}"; do
  echo; echo "## $lang"
  found=0
  for label in "💎 Bounty" "bounty"; do
    out=$(gh api -X GET search/issues \
        -f q="label:\"$label\" state:open language:$lang created:>=$SINCE sort:created-desc" \
        -f per_page=20 \
        --jq '.items[]? | [.created_at[0:10], (.repository_url|split("/")|.[-2:]|join("/")), .number, (.comments|tostring), (if .assignee then "ASIGNADO" else "libre" end), .title, .html_url] | @tsv' \
        2>/dev/null | grep -Eiv "$DENY" \
        | awk -F'\t' -v m="$MAXPER" '{c[$2]++; if(c[$2]<=m) print}' || true)
    if [ -n "$out" ]; then
      # $4=comentarios $5=asignación (proxies de competencia); ASIGNADO = saltar
      echo "$out" | awk -F'\t' '{printf "  [%s] %s#%s  (%s coment., %s)\n     %s\n     %s\n", $1,$2,$3,$4,$5,$6,$7}'
      found=1
    fi
  done
  [ "$found" -eq 0 ] && echo "  (sin resultados recientes)"
done
