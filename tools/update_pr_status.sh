#!/usr/bin/env bash
# update_pr_status.sh — regenera la tabla de "Contribuciones reales" del README con el estado
# actual de los PRs del accionista. Reemplaza el bloque entre <!-- PRS:START --> y <!-- PRS:END -->.
# Los títulos se sanitizan (escape de '|') para no romper la tabla; nada se interpola sin cuidar.
set -euo pipefail
AUTHOR="${AUTHOR:-Jorge-Polanco-Roque}"
README="${README:-README.md}"

rows=""
# PRs del autor (todos los estados), más reciente primero
while IFS=$'\t' read -r repo num title url; do
  [ -z "$url" ] && continue
  # estado preciso: MERGED / CLOSED / OPEN (search no distingue merged)
  st="$(gh pr view "$url" --json state --jq .state 2>/dev/null || echo OPEN)"
  case "$st" in
    MERGED) emoji="🟢 mergeado" ;;
    CLOSED) emoji="🔴 cerrado" ;;
    *)      emoji="🟡 abierto" ;;
  esac
  title="${title//|/\\|}"   # escapar pipes para la tabla
  rows+="| [$repo #$num]($url) | \`$repo\` | $title | $emoji |"$'\n'
# Solo repos AJENOS (contribuciones reales) — se excluyen los repos propios del autor
# (sandbox Testing_Pipelines, operador contribution-pipeline, etc.).
done < <(gh search prs --author "$AUTHOR" --limit 50 --json url,title,repository,createdAt \
         | jq -r --arg me "$AUTHOR" '
             map(select(.repository.nameWithOwner | ascii_downcase | startswith(($me|ascii_downcase) + "/") | not))
             | sort_by(.createdAt) | reverse | .[]
             | [.repository.nameWithOwner, (.url|split("/")|last), .title, .url] | @tsv')

[ -z "$rows" ] && rows="| — | — | *(sin PRs aún)* | — |"$'\n'

block="| PR | Repo | Cambio | Estado |
|---|---|---|---|
${rows}
<sub>Actualizado automáticamente: $(date -u +%Y-%m-%d) (workflow semanal).</sub>"

# bloque a un archivo temporal → awk portable (BSD y GNU), sin problemas de saltos de línea en -v
tmp_block="$(mktemp)"; printf '%s\n' "$block" > "$tmp_block"
awk -v bf="$tmp_block" '
  /<!-- PRS:START -->/ { print; while ((getline line < bf) > 0) print line; close(bf); skip=1; next }
  /<!-- PRS:END -->/   { skip=0 }
  !skip { print }
' "$README" > "$README.tmp" && mv "$README.tmp" "$README"
rm -f "$tmp_block"
echo "README actualizado con el estado de los PRs de $AUTHOR."
