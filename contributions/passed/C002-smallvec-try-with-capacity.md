# C002 — servo/rust-smallvec #416 — `try_with_capacity` (constructor falible)

| Campo | Valor |
|---|---|
| Estado | **🔴 CERRADO sin merge** — servo prohíbe contribuciones de IA (+ nit de overhead) |
| Nicho | infra/data-structures (Rust) |
| Salud del repo | GO — 1.7k★, maintainer activo (@alejandro-vaz revisó #496 el mismo día) |
| Stack | Rust |
| Issue URL | https://github.com/servo/rust-smallvec/issues/416 |
| PR URL | **https://github.com/servo/rust-smallvec/pull/500** |
| Etiquetas | help wanted · good first issue · p-high · r-feature |
| Estimación | P(merge) alta (p-high, infra ya existe, patrón conocido) · +26/−0 |
| Fechas | seleccionado 2026-08-29 · PR 2026-08-29 · merge — |

## Qué pide el issue
Análogo de `Vec::try_with_capacity` (nightly) para `SmallVec`. Comentario del maintainer:
"yeah maybe behind a feature gate on v2."

## Solución
Espejo falible de `with_capacity`: `let mut this = Self::new(); if cap > inline_size() { this.try_grow(cap)?; } Ok(this)`.
Reusa la infra falible que ya existe (`try_grow` → `Result<(), CollectionAllocErr>`, sin feature-gate).
Lo dejé **un-gated** para ser consistente con `try_reserve`/`try_grow`; en el PR ofrecí gatearlo si lo prefieren.
Test en `tests/main.rs` (casos inline y spilled), espejando `test_with_capacity`.

## Gate (calidad + seguridad)
- `cargo fmt --check` ✓ · `cargo test --test main test_try_with_capacity` ✓ · `cargo build` ✓.
- clippy diff-aware: sin hallazgos en mis líneas nuevas (deuda pre-existente del repo ignorada).
- Sin cambios en Cargo.toml (no dep nueva, no feature) → SCA no aplica.

## Acción del accionista
PR ya publicado bajo tu cuenta. Siguiente: **responder al review** cuando llegue (yo redacto, tú publicas).
Nota: la CI de contribuidor primerizo puede requerir tu-aprobación-de-maintainer para arrancar.

## Bitácora
- 2026-08-29: seleccionado tras verificar que la infra falible ya existía (`try_grow`, `try_reserve`).
  Implementado, gate verde, PR #500 abierto (segunda contribución en smallvec — reputación compuesta).

## Lección (al cerrar)
**CERRADO por @alejandro-vaz (2026-08-29):** (1) *"AI contributions are not allowed in any @servo
repository"* → **servo veta IA**; todo el org queda descartado (ver LEARNINGS + SOUL §5 filtro 0). (2) Nit
técnico válido: delegar en `try_grow` reverifica estado (spilled/len) innecesariamente; lo correcto es
asignar directo al saber que arranca vacío. Regla nueva: **verificar política de IA ANTES de seleccionar**
(`recon` ahora lo surfacea). Aun así, el impl era correcto y el gate verde — el fallo fue de *selección*, no de código.
