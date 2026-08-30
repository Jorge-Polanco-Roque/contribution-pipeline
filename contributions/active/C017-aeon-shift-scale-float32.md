# C017 — aeon #3722 — preservar dtype en el zero-padding de shift_scale_invariant (float32)

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#3773](https://github.com/aeon-toolkit/aeon/pull/3773)) — esperando review |
| Nicho | ML / series de tiempo (Python, numba) |
| Salud del repo | GO — 1.4k★, activo (merge 2026-08-28), menos hiperactivo que sktime |
| Stack | Python (numpy + numba) |
| Origen | issue #3722 (bug, sin asignar, sin PR — el reclamante previo se retiró explícitamente) |
| Política IA | ✅ **sin política de IA** (sin ban ni divulgación; sin DCO/CLA) → filtro 0 limpio |
| Crédito | 🏆 **all-contributors con bot ACTIVO** (auto-mergea adiciones) → avatar en README garantizado |
| Estimación | P(merge) alta (bug objetivo, fix exacto dado, 2 bugs arreglados, test que prueba el fix) · 2 archivos |
| Fechas | seleccionado 2026-08-30 · PR — · merge — |

## Qué pide
`shift_scale_invariant_distance` y `KSpectralCentroid` lanzan `TypingError` de numba con input **float32**.
El zero-padding `np.zeros(±sh)` es float64; en las ramas de shift, `shifted_y` no unifica (float32 en una
rama, float64 en otras) dentro de la función jitteada.

## Causa raíz + solución
`aeon/distances/_shift_scale_invariant.py` L144/L147: `np.zeros(-sh)` / `np.zeros(sh)` sin dtype → float64.
Fix: `dtype=y.dtype` en **ambas** ramas (el reporter menció L144; L147 tenía el mismo defecto). Así todas las
ramas producen `y.dtype` y numba unifica.

## Verificación (gate del repo, verde)
- ✅ float32 ahora funciona (dist=0.1005, igual que float64); **KSpectralCentroid float32 fit** también.
- ✅ Test nuevo `test_shift_scale_invariant_distance_float32` (float32 no lanza + coincide con float64).
- ✅ **El test prueba el fix:** sin el cambio → `TypingError`; con él → 2 passed.
- ✅ `ruff check` + `ruff format` limpios.

## Cómo se eligió (objetivo: CRÉDITO, distinto a sktime)
Busqué otro proyecto que **acredite visiblemente**. aeon (hermano de sktime, series de tiempo) usa
**all-contributors con bot activo** — el más automático. Menos hiperactivo que sktime → issue limpio
disponible. #3722: objetivo, fix exacto dado, reclamante previo se retiró, @4nmus se fue al issue hermano #3723.

## Acción del accionista (2 gates)
1. **Abrir PR** bajo tu cuenta ("Fixes #3722"), título con prefijo `[BUG]`.
2. **Tras el merge:** `@all-contributors please add @Jorge-Polanco-Roque for code, bug` (lo pide su plantilla).

## Bitácora
- 2026-08-30: seleccionado (crédito + limpio); fix en ambas ramas + test; gate verde.
- 2026-08-30: **PR #3773 abierto** bajo cuenta de Jorge. Esperando review. (all-contributors bot tras merge.)

## Lección (al cerrar)
<pendiente del review/merge>
