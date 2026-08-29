# C002 — servo/rust-smallvec — próximo candidato (EN LA RECÁMARA, sin abrir)

> Preparado para lanzar **en cuanto #496 tenga veredicto** (disciplina F0: un PR real a la vez).
> La reputación compone en el mismo repo, y ya conocemos su codebase y convenciones.

## Candidato primario: #492 — fix documentation build warning (unresolved link)
- Estado: OPEN · **sin asignar · 0 comentarios** · creado 2026-08-29 · labels `r-docs`/`p-low`/`good first issue`.
- Verificación aplicada: nadie en curso ✅ · docs (test convention N/A) · freshness hoy ✅.
- **Matiz hallado (importante):** el warning exacto del issue (`[`retain`]` en lib.rs:1614) **depende
  del set de features del build de docs**. En el build por defecto (`no_std`), `cargo doc` muestra
  otros warnings (`std::io::Write`, `std::error::Error` en lib.rs:24-25). → menos mecánico de lo que
  sugiere el título; al ejecutar hay que **reproducir con la config de docs del CI de smallvec**
  (probablemente `--all-features` o `--features std` + `RUSTDOCFLAGS=-Dwarnings`) y arreglar TODOS
  los intra-doc links rotos que aparezcan.

## Alternativas (mismo repo, por si #492 resulta espinoso)
- **#416** — `Implement try_with_capacity` (feature/impl acotado, patrón conocido como `arbitrary`).
- **#491** — `add full feature list to README.md` (docs puro; pero el formato puede ser subjetivo).

## Plan de ejecución (post-#496)
1. Rama limpia off `v2` (ya probado el flujo).
2. Reproducir el/los warning(s) con la config de docs correcta; arreglar los links.
3. Gate (`--parity` / genérico diff-aware) verde; `cargo doc` sin warnings.
4. Commit (Jorge + sign-off) → **borrador** → el accionista publica.

## Estado
- Clon listo en `~/Desktop/AnatemaBot/t6-smallvec` (rama `fix/docs-retain-link` off v2).
- **NO abierto.** Esperando resolución de [#496](https://github.com/servo/rust-smallvec/pull/496).
