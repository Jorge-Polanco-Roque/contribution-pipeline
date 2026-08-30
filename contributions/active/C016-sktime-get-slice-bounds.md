# C016 — sktime #10966 — get_slice: 0 es un bound válido, solo None es ausente

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#10967](https://github.com/sktime/sktime/pull/10967)) + bot all-contributors disparado — esperando review |
| Nicho | ML / series de tiempo (Python) |
| Salud del repo | GO — 9.9k★, hiperactivo, muy welcoming |
| Stack | Python (numpy/pandas) |
| Origen | issue #10966 (bug, creado 2026-08-30 — **fresco, sin reclamar, sin PR**) |
| Política IA | ⚠️ **divulgación de LLM requerida** (template pide prefaciar contenido LLM) → se divulga en el PR |
| Crédito | 🏆 **all-contributors** (muro de avatares en README) — objetivo del accionista |
| Estimación | P(merge) alta (bug objetivo y fresco, fix mínimo, 3 repros verificados, test que prueba el fix) · 2 archivos |
| Fechas | seleccionado 2026-08-30 · PR — · merge — |

## Qué pide
`get_slice(obj, start, end)` trataba un bound entero `0` como si fuera **omitido** (check *falsy*), y el path
NumPy hacía aritmética/comparaciones sobre `None` cuando solo se pasaba un bound. Repros (esperado: vacío):
- `get_slice(np.arange(5), 0, 0)` → devolvía `[0,1,2,3,4]`.
- `get_slice(np.arange(5), None, 0)` → `TypeError`.
- `get_slice(pd.Series(range(5)), 2, 0)` → devolvía `[2,3,4]`.

## Causa raíz + solución
Checks *falsy* (`if start`, `if start and end`) en vez de `is not None`, y aritmética sobre `None` sin guarda.
Fix: usar `is not None` en ambos paths (numpy + pandas), guardar la aritmética, y dejar que el slicing nativo
de Python maneje `None`/`0`. Diff mínimo, sin cambiar la semántica documentada.

## Verificación (gate del repo, verde)
- ✅ Los 3 repros → ahora vacíos; **6 casos de no-regresión** intactos (incl. `pd start=0 end=3` que antes fallaba).
- ✅ Test nuevo `test_get_slice_zero_and_none_bounds`.
- ✅ **El test prueba el fix:** sin el cambio → FAILED (`start=0,end=0` devuelve `[0,1,2,3,4]`); con él → ok.
- ✅ Suite `test_utils.py` **115 passed** · `ruff check` + `ruff format` limpios.

## Cómo se eligió (objetivo: CRÉDITO)
El accionista quiere un proyecto que **acredite** visiblemente. sktime usa **all-contributors** (avatar en el
README). Como el objetivo es crédito (no dificultad), evité los bugs difíciles/disputados y busqué algo
**objetivo y fresco**: #10966 se creó hoy, sin reclamar, con repro claro → aterriza limpio y da crédito.

## Acción del accionista (2 gates)
1. **Abrir PR** bajo tu cuenta (con divulgación de LLM que pide sktime) + "Fixes #10966".
2. Tras abrir: disparar el bot `@all-contributors please add @Jorge-Polanco-Roque for code, bug` → entras al muro.

## Bitácora
- 2026-08-30: seleccionado (fresco, objetivo, con crédito); fix + test; gate verde.
- 2026-08-30: **PR #10967 abierto** con divulgación de LLM; comentario `@all-contributors` posteado. Esperando review.

## Lección (al cerrar)
<pendiente del review/merge>
