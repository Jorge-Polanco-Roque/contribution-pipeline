# Round 002 — review (M3, agentes separados)

- **Reporter (subagente)** eligió y sembró el bug **sin intervención mía**: `variance()`
  dividía entre `n-1` (muestral) en vez de `n` (poblacional), contradiciendo su docstring.
  Latente porque el único test usaba valores constantes (varianza 0 bajo cualquier divisor).
- **Contributor (subagente, ciego)** — solo vio el issue #3 + el código; **prohibido** el
  catálogo/oráculo. Diagnosticó la causa raíz correctamente, fix de 1 línea + tests de regresión.
- **Oráculo:** FALLÓ en main, PASA en la rama → fix real (validación independiente del referee).
- **CI Actions:** verde. **Gate local:** verde a la primera.
- **Veredicto:** APROBADO → merge (squash) → issue #3 cerrado automáticamente.
- **Sin colusión:** dos contextos de agente separados; B resolvió a ciegas. ✅
