# C001 — servo/rust-smallvec #494 — impl `arbitrary::Arbitrary` for `SmallVec`

| Campo | Valor |
|---|---|
| Estado | **enviado** (PR abierto, esperando review del maintainer) |
| Nicho | infra/data-structures (Rust) |
| Salud del repo | GO — 1.7k★, 28 merges/30d, 22... externos, sin `test=false` |
| Stack | Rust |
| Issue URL | https://github.com/servo/rust-smallvec/issues/494 |
| PR URL | **https://github.com/servo/rust-smallvec/pull/496** |
| Etiquetas | good first issue · help wanted · r-feature · p-medium |
| Estimación | P(merge) media-alta (impl pedido explícitamente, patrón conocido) · +39/−0 |
| Fechas | seleccionado 2026-08-29 · PR 2026-08-29 · merge — |

## Qué pide el issue
Implementar `arbitrary::Arbitrary` para `SmallVec`: existe en la rama v1, portarla a v2.

## Solución
Porté el impl a la API v2 (`SmallVec<T, const N>`), feature-gated `arbitrary` (como `serde`).
Delega en `Unstructured::arbitrary_iter`/`arbitrary_take_rest_iter` + `FromIterator`. Test añadido.

## Gate (calidad + seguridad)
- `cargo build/test --features arbitrary` verde (test_arbitrary pasa); `cargo fmt --check` limpio.
- Seguridad diff-aware: SCA (`cargo audit`) auditó la nueva dep `arbitrary` → sin vulns.
- clippy `-D warnings` local marcó **deuda pre-existente de smallvec** (no mi diff) — su CI (toolchain fijado) es la verdad.

## Acción del accionista
El PR ya está publicado bajo tu cuenta. Siguiente: **responder al review del maintainer** (yo redacto, tú publicas). La CI del repo puede requerir tu-aprobación-de-maintainer para arrancar (contribuidor primerizo).

## Bitácora
- 2026-08-29: seleccionado (recon + verificación), implementado (dry-run T6), PR #496 abierto.

## Lección (al cerrar)
<pendiente del resultado del review/merge>
