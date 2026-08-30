# C001 — servo/rust-smallvec #494 — impl `arbitrary::Arbitrary` for `SmallVec`

| Campo | Valor |
|---|---|
| Estado | **🟢 MERGEADO 2026-08-29** (por @alejandro-vaz) — primer merge real (gate F0) |
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
- 2026-08-29: review del maintainer (@alejandro-vaz, "looks good" + 3 nits). Atendido: rebase sobre v2
  (#495 movió tests a integración), test → `tests/arbitrary.rs` (`required-features`), quitada la feature
  redundante, reordenada la dep. Force-push + comentario. PR MERGEABLE. Lección en LEARNINGS.

## Lección (al cerrar)
**MERGEADO** — primer merge real bajo la cuenta del accionista. Bien: selección de repo sano, impl pedido
explícito, 3 nits de review atendidos rápido y limpio. **Ironía/riesgo:** el mismo maintainer cerró #500
citando que **servo prohíbe IA** — este merge se coló antes de que lo notara. No repetir en servo; el valor
está en el *método* (que sí funcionó), aplicado a repos con política pro-IA (uutils). Ver LEARNINGS 2026-08-29.
