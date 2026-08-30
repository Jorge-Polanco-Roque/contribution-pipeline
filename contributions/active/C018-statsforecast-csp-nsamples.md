# C018 — Nixtla/statsforecast #1202 — ConformalSeasonalPool: umbrales de n_samples + validación

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#1225](https://github.com/Nixtla/statsforecast/pull/1225)) — esperando review |
| Nicho | ML / forecasting estadístico (Python + C++/pybind11) |
| Salud del repo | GO — 4.9k★, activo (merge 2026-08-27), mergea externos |
| Stack | Python (numpy) sobre core C++ |
| Origen | issue #1202 (bug/doc, análisis exhaustivo del reporter @shivamlalakiya) |
| Política IA | ✅ sin ban ni divulgación; sin DCO/CLA |
| Crédito | 🏆 **all-contributors con bot activo** → avatar en README |
| Consideración ética | el reporter ofreció hacer el PR → **lo acredito explícitamente** en el PR (colaborativo, no poach) |
| Estimación | P(merge) alta (items objetivos y mecánicos, análisis ya hecho, test que prueba el fix) · 2 archivos |
| Fechas | seleccionado 2026-08-30 · PR — · merge — |

## Qué pide (items 1-3, los "small and mechanical" del reporter)
1. **Docstring de `n_samples`:** documentaba solo el umbral del bound **inferior** (`ceil(2/a)-1`) y su ejemplo
   estaba **off-by-one** (decía ≥40 para 95%, la fórmula da 39). Falta el umbral **superior** (`ceil(4/a)-1`).
2. **`predict_in_sample`:** su anchura depende de `R.size` (`calib_frac`×historia), **no** de `n_samples` —
   sin nota que lo aclare.
3. **`__init__`:** no validaba `n_samples`; `n_samples<1` era alcanzable (0 → degenerado).

## Solución
1. Docstring con **ambos** umbrales + ejemplo corregido (≥39 y ≥79 para 95%).
2. Nota en `predict_in_sample` fraseada contra `R.size`/`calib_frac`.
3. `if n_samples < 1: raise ValueError` (rechaza 0/negativos; `n_samples=1` sigue permitido, per reporter).
- **Item 4 (warning en runtime):** el reporter dijo que es decisión del maintainer → **deferido**, lo menciono en el PR.

## Verificación (gate del repo, verde)
- ✅ Umbrales validados analíticamente contra `_oriented_index` (lower n≥39, upper n≥79 para 95%).
- ✅ `n_samples=0/-5` → ValueError; `n_samples=1` permitido; forecast intacto.
- ✅ Test nuevo `test_invalid_n_samples_raises` (parametrizado 0/-1). **Prueba el fix:** sin validación → DID NOT RAISE.
- ✅ `ruff check` (reglas F) limpio · **23 tests CSP pasan**. (Evité `ruff format` — el repo no lo usa, habría sido scope creep.)

## Crédito al reporter
El PR acredita explícitamente el análisis de **@shivamlalakiya** y defiere el item 4 a los maintainers.

## Acción del accionista (2 gates)
1. **Abrir PR** ("Fixes #1202", items 1-3), acreditando al reporter.
2. **Tras merge:** `@all-contributors please add @Jorge-Polanco-Roque for code, doc`.

## Bitácora
- 2026-08-30: seleccionado (muro all-contributors activo); items 1-3 + test; gate verde.
- 2026-08-30: **PR #1225 abierto** bajo cuenta de Jorge, acreditando a @shivamlalakiya. Esperando review.

## Lección (al cerrar)
<pendiente del review/merge>
