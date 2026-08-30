# C012 — boa-dev/boa #3975 — entrecomillar claves de objeto no-identificador en `to_interned_string`

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#5500](https://github.com/boa-dev/boa/pull/5500)) + claim posteado — esperando review |
| Nicho | Rust / devtools / language-impl (motor JavaScript embebible) |
| Salud del repo | GO — 7.5k★, activo, 240 issues, welcoming (good-first-issue) |
| Stack | Rust |
| Origen | issue #3975 (bug A-Bug, sin asignar, sin fix merged) |
| Política IA | ✅ **sin política de IA** (revisado CONTRIBUTING + code-search: cero menciones) → filtro 0 OK |
| Reto | medio-alto: bug de conformidad en el pretty-printer del AST; **2 intentos previos cerrados** (#5029, #1694) por fix incompleto |
| Estimación | P(merge) alta (bug real, fix mínimo + correcto + test que prueba el fix, gate del repo verde) · 2 archivos |
| Fechas | seleccionado 2026-08-30 · PR — · merge — |

## Qué pide
`PropertyName::to_interned_string` (el pretty-printer del AST) emite las claves **crudas**. Para claves que
no son `IdentifierName` válido (p.ej. `{ ':checked + div': 1 }`), produce **JS no parseable**
(`:checked + div: 1`). Debe entrecomillarlas.

## Causa raíz + solución
`core/ast/src/property.rs` L75 resolvía el símbolo y lo emitía tal cual. Fix: si la clave es un identificador
válido → bare; si no → `"..."`. Las claves numéricas ya son `Computed` (se emiten `[1]`), así que el caso
`Literal` solo cubre identificadores y strings → check simple y correcto.

**Decisión de diseño (ponytail):** check de identificador **ASCII conservador, sin dep nueva**. `boa_ast` tiene
deps deliberadamente lean (sin `icu_properties`); meter ICU solo para un pretty-printer de debug sería scope
creep. El check conservador nunca produce output inválido (a lo sumo entrecomilla un identificador Unicode
válido = más verboso pero válido), a diferencia del `char::is_alphabetic` de #5029 que el bot marcó como
incorrecto. Documentado en el código + ofrezco cambiar a ICU si el maintainer lo prefiere.

## Verificación (gate del repo, verde)
- ✅ `cargo fmt --check` limpio · `cargo clippy` sin warnings.
- ✅ Test nuevo `object_non_identifier_keys` (round-trip de 4 claves: normal/`a-b`/`:checked + div`/vacía).
- ✅ **El test prueba el fix:** sin el cambio → `a-b: 2, :checked + div: 3, : 4` (el bug #3975); con el fix → entrecomilladas.
- ✅ 33 tests de formato + 46 de boa_ast pasan (sin regresión).

## Por qué se eligió (mayor P(merge) tras vetar varios)
Descartados por churn/trampa: #4439 (Blocked + 5 PRs fallidos), #4663 (ya arreglado en main hoy), #4350
(#5031 merged), #4360 (PR abierto). #3975 quedó: real, sin resolver, sin asignar, sin PR abierto, y con un
fix acotado pero no trivial (2 intentos incompletos previos).

## Acción del accionista (2 gates)
1. **Claim:** comentar en #3975 que lo tomas (lo pide CONTRIBUTING).
2. **Abrir PR** bajo tu cuenta con "Closes #3975".

## Bitácora
- 2026-08-30: seleccionado tras vetar 4 issues churny; fix implementado + verificado; gate verde.
- 2026-08-30: claim posteado en #3975; **PR #5500 abierto** bajo cuenta de Jorge. Esperando review.

## Lección (al cerrar)
<pendiente del review/merge>
