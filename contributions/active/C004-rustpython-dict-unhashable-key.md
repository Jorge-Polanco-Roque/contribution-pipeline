# C004 — RustPython/RustPython — mensaje CPython-style para claves inhashables en `dict`

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#8610](https://github.com/RustPython/RustPython/pull/8610)) — esperando review |
| Nicho | infra/lenguajes (Rust, intérprete de Python) |
| Salud del repo | GO — 22.3k★, 171 merges/30d, 22/30 externos, CONTRIBUTING claro, activo hoy |
| Stack | Rust |
| Origen | test de CPython marcado `TODO: RUSTPYTHON` (`test_dict.DictTest.test_unhashable_key`) |
| PR URL | **https://github.com/RustPython/RustPython/pull/8610** |
| Política IA | ✅ permite IA **con divulgación obligatoria** (trailer `Assisted-by`, nota en el PR) |
| Estimación | P(merge) alta (paridad CPython con test que ya existe, patrón espejo de `set`) · +42/−15 |
| Fechas | seleccionado 2026-08-29 · PR 2026-08-29 · merge — |

## Qué pide el issue/test
`dict` debe emitir el mensaje de CPython 3.14 `cannot use 'X' as a dict key (unhashable type: 'X')`
en todas las operaciones con clave, no el genérico `unhashable type: 'X'`.

## Solución
Helper `wrap_unhashable_error` en `PyDict` (espejo de `PySetInner`) que re-envuelve el `TypeError`
con el wording específico de dict. Se aplica en el **choke point real**: `inner_getitem`/`inner_setitem`/
`inner_delitem` (que cubren subscript slot + `#[pymethod]` + fast-path `get_item`/`set_item`/`del_item`),
más `contains`/`get`/`setdefault`/`pop` (que van directo a `entries.*`). La clave solo se materializa
en el error → sin costo en el hot path. Des-decoré `@unittest.expectedFailure` del test.

**Trampas de dispatch aprendidas:** los operadores de un dict exacto usan un **fast-path**
(`PyObject::get_item` → `PyDict::get_item` → `inner_*`) que **salta** el slot `AsMapping` y el
`#[pymethod]` — por eso envolver esos dos no bastaba. El único choke común es `inner_*`.

## Gate (calidad + seguridad) — VERDE
- `test_unhashable_key` pasa (des-decorado → **falla sin el fix**). `test_dict` (121) y `test_set` (630) verdes.
- `cargo fmt --check` limpio · clippy sin hallazgos en `dict.rs`. Requirió toolchain rustc 1.98 (repo pide ≥1.95).

## Política de IA — cumplimiento (lección clave)
RustPython **permite IA pero exige divulgarla** (política tipo Ghostty). Se cumplió:
- Commit con trailer `Assisted-by: Claude Opus 4.8 (Anthropic)` (NO `Co-authored-by`, reservado a humanos).
- Nota de divulgación honesta en el PR (implementado con Claude, verificado por el accionista).
- **Sin `Signed-off-by`** (el repo no usa DCO; firmarlo sobre código asistido por IA se leía como suplantación).
- Condición anti-GPL cumplida: escrito desde la fuente MIT de RustPython + comportamiento documentado, no de CPython.

## Acción del accionista
PR publicado bajo tu cuenta. Siguiente: responder al review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-29: seleccionado (veta `TODO: RUSTPYTHON`), implementado, gate verde, PR #8610 abierto con divulgación.

## Lección (al cerrar)
<pendiente del review/merge>
