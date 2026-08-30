# C007 — uutils/coreutils #14232 — `ls -lh` respeta el separador decimal del locale

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#14264](https://github.com/uutils/coreutils/pull/14264)) — esperando review |
| Nicho | infra/devtools (Rust, coreutils GNU-parity) |
| Salud del repo | GO — 24k★, org uutils (pro-IA verificado), muy activo (144 merges/30d) |
| Stack | Rust |
| Issue URL | https://github.com/uutils/coreutils/issues/14232 |
| PR URL | **https://github.com/uutils/coreutils/pull/14264** |
| Etiquetas | U - ls (parte de un issue U-du/U-numfmt/U-ls) |
| Política IA | ✅ permite IA sin divulgación obligatoria (mismo org que sed) |
| Estimación | P(merge) alta (fix mínimo, mirror de precedente #12357, GNU como referencia) · +22 |
| Fechas | seleccionado 2026-08-29 · PR 2026-08-29 · merge — |

## Qué pide el issue
`du -h`, `ls -lh`, `numfmt --to=iec` imprimían el decimal con `.` ignorando `LC_NUMERIC`; GNU usa el
separador del locale (`4,0K` en de_DE). Rompe `du -h | sort -h` (sort sí lee el locale).

## Solución
`ls` formatea tamaños vía `uucore::human_readable`, que **ya localiza** el separador (`localize_decimal`),
pero el crate `ls` **no habilitaba el feature `i18n-decimal`** → la localización se compilaba fuera.
Fix: añadir `"i18n-decimal"` a los features de uucore en `src/uu/ls/Cargo.toml` (1 línea), **mirror de lo
que hizo `du`** (#12357). `du` y `numfmt` ya estaban hechos → `ls` era el hueco restante. Test añadido
espejando `test_du_h_locale_decimal_separator`.

## Gate / verificación — VERDE
- Suite `ls`: 172 passed, 0 failed. `cargo fmt`/`clippy -D warnings` limpios.
- **Prueba real en el binario standalone** `uu_ls`: con fix `ls -lh`→`8,4K`, sin fix→`8.4K`.

## Lección técnica — unificación de features en tests de workspace
El test de integración (harness `tests` con muchas utils) **pasa aunque falte el fix**: `du` habilita
`i18n-decimal`, y la **unificación de features de Cargo** lo activa para el `uucore` compartido → `ls`
lo hereda en el test. El test de `du` tiene la misma limitación. **Regla:** para fixes que son
*feature-gating* per-crate, el test de integración documenta el comportamiento pero **no aísla el fix**;
la prueba real es el **binario standalone** (`cargo build -p uu_ls` + ejecutar). Verificar ahí, no solo en el harness.

## Lección de selección
- coreutils está **muy transitado**: #14229, #14160, #14153, #13964 ya tenían PR abierto → descartados.
  #14232 seguía uncontested porque la parte `ls` faltaba (du/numfmt ya hechos). Filtro "PRs compitiendo" clave.
- **Sexto repo distinto** → KPI de repos diversos cumplido.

## Acción del accionista
PR publicado bajo tu cuenta. Siguiente: responder al review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-29: seleccionado (tras descartar 4 candidatos coreutils contestados), fix mínimo verificado en binario real, PR #14264 abierto.

## Lección (al cerrar)
<pendiente del review/merge>
