# C003 — uutils/sed #394 — Implementar comando GNU `R` (leer una línea de archivo)

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#544](https://github.com/uutils/sed/pull/544)) — esperando review |
| Nicho | infra/devtools (Rust, org uutils) |
| Salud del repo | GO — 104★, 34 merges/30d, 21/30 externos, CONTRIBUTING sí, activo hoy |
| Stack | Rust |
| Issue URL | https://github.com/uutils/sed/issues/394 |
| PR URL | **https://github.com/uutils/sed/pull/544** |
| Etiquetas | good first issue |
| Estimación | P(merge) alta (feature pedida, patrón `W`#531 fresco de referencia) · +74/−0 + `named_reader.rs` |
| Fechas | seleccionado 2026-08-29 · PR — · merge — |

## Qué pide el issue
Comando GNU `R filename`: encolar la **siguiente** línea del archivo para insertarla al final
del ciclo. Contraparte line-oriented de `r` (como `W` lo es de `w`).

## Solución
Nuevo `NamedReader` (espejo de `NamedWriter`): abre el archivo lazy, lee una línea por
invocación con `read_until(b'\n')` (preserva el `\n` y la última línea sin newline). Archivo
ilegible/agotado → sin más líneas, sin error (semántica GNU). Enganches: variante
`CommandData::NamedReader`, handler `compile_read_line_command`, dispatch `'R' if !posix`,
brazo `'R'` en processor que encola `AppendElement::Text`. Reservado a no-POSIX + rechazado bajo `--sandbox`.

## Gate (calidad + seguridad) — VERDE
- `cargo fmt --all -- --check` ✓ · `cargo test --all` ✓ (387+286, 0 fallos) · `cargo clippy --all-targets --workspace -psed -- -D warnings` ✓ (comando exacto del CI).
- 7 tests nuevos (3 unit `NamedReader` + 4 integración). El behavioral **falla sin el fix** (R = "invalid command code").
- Smoke test vs semántica GNU: idéntico. Secretos/SCA/SAST ✓.

## Selección — trampas evitadas (aprendizaje)
- #540 (`\U\L\u\l\E`): **descartado** — `uutils/sed` ya usa `\u`/`\U` como escapes unicode-hex → conflicto de diseño.
- #398 (`W`): **descartado** — ya implementado por #531 hace 3 días (issue abierto sin cerrar).
- #543 (back-refs byte mode): descartado — cambio de motor de regex, no mecánico.
- Regla: antes de codear, verificar (a) conflicto con extensiones existentes del repo, (b) PRs/commits recientes que ya resuelven el issue.

## Acción del accionista
**Abrir el PR** (yo tengo la rama lista en el fork). Comando:
`gh pr create --repo uutils/sed --base main --head Jorge-Polanco-Roque:feat/R-read-one-line --title "Implement GNU R (read one line from file) command" --body-file <cuerpo>`

## Bitácora
- 2026-08-29: seleccionado (recon GO + descarte de 3 trampas), implementado, gate verde, rama pusheada al fork. PR pendiente de tu OK.

## Lección (al cerrar)
<pendiente>
