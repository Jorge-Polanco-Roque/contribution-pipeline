# Round 001 — issue

- **Repo:** Jorge-Polanco-Roque/Testing_Pipelines
- **Issue:** #1 — median() returns wrong value for even-length inputs
- **Tipo:** seeded (bug latente sembrado en el baseline)
- **Modo:** GitHub-mode
- **Reporter:** Agent A (cableado por Claude en M0)

## Síntoma reportado
`median(&[1,2,3,4])` da 3.0; se espera 2.5. El bug afecta solo longitudes pares.

## Criterio de aceptación
- `median(&[1,2,3,4]) == 2.5`
- `median(&[10,2,8,4]) == 6.0`
- comportamiento impar sin cambios
- test de regresión para longitudes pares

## Ground truth (oráculo, oculto para B)
`arena/catalog/median-even/hidden_test.rs` — debe **fallar** en `main` y **pasar** tras el fix.
