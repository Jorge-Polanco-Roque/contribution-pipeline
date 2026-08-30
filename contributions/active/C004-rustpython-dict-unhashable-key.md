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

## Review de CodeRabbit + lección técnica (hash-once / re-hash-on-error)
CodeRabbit marcó un **bug de correctitud real (Minor)**: `wrap_unhashable_error` reescribía **cualquier**
`TypeError` de la operación como "unhashable", pero las operaciones de dict también **comparan** claves al
resolver colisiones (`key_eq` → `__eq__`). Un `TypeError` del `__eq__` de una clave que colisiona se
etiquetaba mal. Válido.

- ❌ **Primer intento fallido (mío):** pre-chequeo `check_hashable` que hasheaba la clave por separado antes de
  la operación. Envolvía solo el hash, sí — **pero añadía un hash extra**. Rompió `test_do_not_rehash_dict_keys`,
  `test_setdefault_atomic`, `test_setitem_atomic_at_resize` → CPython **verifica que la clave se hashea
  EXACTAMENTE una vez**. Lo cacé con `test_dict`/`test_set` **antes de pushear** (no shipear código roto).
- ✅ **Fix correcto:** desambiguar **en el camino de error** — re-hashear la clave *solo cuando la operación ya
  falló*. Éxito → hashea una vez (invariante preservado); error → si el re-hash falla = inhashable (reescribe),
  si pasa = error de comparación (propaga intacto). Cero costo extra en el hot path.
- 🛠️ **Reglas:** (1) al envolver errores, distinguir la **fuente** (hash vs comparación) — no asumir. (2) Correr
  **la suite completa** tras un refactor de un helper compartido: hay invariantes tácitos (hash-once/atomicidad)
  que solo un test específico revela. (3) El review adversarial (bot) **mejoró** el PR — no defenderse, verificar y corregir.
- Respuesta publicada: https://github.com/RustPython/RustPython/pull/8610#issuecomment-5466242402

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
- 2026-08-29: review de CodeRabbit (over-wrapping de errores de comparación). 1er fix (doble-hash) rompió
  invariantes hash-once → detectado con las suites; 2º fix (re-hash-on-error) correcto + test de regresión.
  Pusheado al branch + réplica publicada. PR con 2 commits, más fuerte que el original.

## Lección (al cerrar)
<pendiente del review/merge>
