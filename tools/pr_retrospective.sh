#!/usr/bin/env bash
# pr_retrospective.sh <owner/repo> <pr> — reúne el contexto de un PR para APRENDER de él,
# especialmente si se cerró SIN merge (rechazo). Junta reviews, comentarios (generales + inline)
# y el motivo de cierre, y deja una plantilla de aprendizaje para volcar en LEARNINGS.md.
#
# Uso típico (cuando un PR real se cierra sin merge):
#   bash tools/pr_retrospective.sh servo/rust-smallvec 496
set -uo pipefail
REPO="${1:?uso: pr_retrospective.sh <owner/repo> <pr>}"; PR="${2:?falta el número de PR}"

meta=$(gh pr view "$PR" --repo "$REPO" --json state,title,url,closedAt,mergedAt,author,body 2>/dev/null) \
  || { echo "No pude leer $REPO#$PR"; exit 1; }
state=$(jq -r '.state' <<<"$meta"); merged=$(jq -r '.mergedAt // "—"' <<<"$meta")

echo "# Retrospectiva — $REPO#$PR"
jq -r '"Título: \(.title)\nURL: \(.url)\nEstado: \(.state) · cerrado: \(.closedAt // "—") · merged: \(.mergedAt // "—")"' <<<"$meta"
case "$state:$merged" in
  MERGED:*)  echo ">> MERGEADO — no es un rechazo (aprender qué salió BIEN)." ;;
  CLOSED:—)  echo ">> ⚠️ CERRADO SIN MERGE (rechazo) — analizar por qué." ;;
  *)         echo ">> Abierto — retrospectiva parcial (aún en review)." ;;
esac

echo; echo "## Reviews (veredictos)"
gh pr view "$PR" --repo "$REPO" --json reviews \
  --jq '.reviews[] | "- @\(.author.login) [\(.state)]: \((.body // "")[0:300])"' 2>/dev/null | grep . || echo "  (sin reviews)"

echo; echo "## Comentarios del hilo"
gh pr view "$PR" --repo "$REPO" --json comments \
  --jq '.comments[] | "- @\(.author.login): \((.body // "")[0:300])"' 2>/dev/null | grep . || echo "  (sin comentarios)"

echo; echo "## Comentarios inline (archivo:línea)"
gh api "repos/$REPO/pulls/$PR/comments" \
  --jq '.[] | "- \(.path):\(.line // .original_line) @\(.user.login): \((.body // "")[0:300])"' 2>/dev/null | grep . || echo "  (sin comentarios inline)"

cat <<'EOF'

## Plantilla de aprendizaje → volcar en LEARNINGS.md
- Contexto: <repo#pr — qué era>
- ✅ Qué salió bien:
- ❌ Por qué se rechazó / qué pidieron:
- 🔎 Causa raíz (marca una): selección · código/correctitud · estilo/convención del repo · social/timing · scope
- 🛠️ Regla o ajuste resultante (a qué alimenta): SOUL §5 filtro · contributor.md · gate · recon
- Acción: mover contributions/active/CNNN → passed/ con la lección.
EOF
