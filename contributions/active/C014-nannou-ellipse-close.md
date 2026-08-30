# C014 — nannou-org/nannou #1095 — cerrar el path del contorno de la elipse (stroke sin hueco)

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#1096](https://github.com/nannou-org/nannou/pull/1096)) — esperando review |
| Nicho | gráficos generativos / creative-coding (Rust, sobre Bevy) |
| Salud del repo | GO — 6.7k★, master mantenido (merges 2026-07-15), mergea externos |
| Stack | Rust (nannou_draw + lyon + bevy) |
| Origen | issue #1095 (bug, 2026-08-17, sin asignar, sin PR) |
| Política IA | ✅ **sin política de IA** (CONTRIBUTING sin ban/disclosure; sin DCO/CLA/template) → filtro 0 OK |
| Reto | medio: geometría/tesselación; fix acotado pero requiere entender las 2 ramas (con/sin resolución) y verificar sin GPU |
| Estimación | P(merge) alta (bug reciente, reporter auto-diagnosticó, fix mínimo + test que prueba el fix, gate verde) · 1 archivo |
| Fechas | seleccionado 2026-08-30 · PR — · merge — |

## Qué pide
`draw.ellipse()` **sin** `.resolution(...)` dibuja un arco de círculo **no cerrado**: para *stroke*, el path
abierto deja caps en la costura en vez de un join → hueco visible. Con `.resolution(...)` sí cierra.

## Causa raíz + solución
En `ellipse.rs`, la rama `None` (sin resolución) construye el path con `move_to` + `arc(2π)` + `build()`
**sin `builder.close()`**. La rama `Some` ya cierra (pasa `true` a `render_points_themed`). Fix: cerrar el
path. Refactoricé la construcción a un helper testeable `ellipse_outline_path(w,h)` que llama `close()`.

**Nota del reporter (rama con resolución):** cerrar ahí daría un segmento de ~longitud cero (primer≈último
punto), pero lyon filtra la degeneración → fuera de alcance, no se toca.

## Verificación (gate del repo, verde)
- ✅ Test nuevo `ellipse_outline_path_is_closed`: asevera que el path emite `PathEvent::End { close: true }`.
- ✅ **El test prueba el fix:** sin `close()` → FAILED ("ellipse outline path should be closed"); con él → ok.
- ✅ Test `degenerate_ellipse_has_no_outline` (radio cero → None).
- ✅ `cargo fmt --check` limpio · `clippy` cero warnings nuevos (los 52 del crate son deuda pre-existente) · tests verdes.
- ⚠️ El render real es bevy+GPU (no testeable headless) → verificación a nivel de path lyon (CPU), que es donde vive el bug.

## Cómo se eligió
Proyecto elegido por Jorge (nannou, gráficos generativos). Filtro 0 ✓. Descarté los bugs viejos 2018-2020
(platform/driver-específicos, posiblemente moot tras upgrades de wgpu/bevy). #1095 es **reciente (2026-08)**,
concreto, reproducible, relevante al master actual (bevy-based, mantenido), sin reclamar ni PR.

## Acción del accionista (2 gates)
1. **Abrir PR** bajo tu cuenta con "Closes #1095".
2. Responder review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-30: seleccionado; fix + refactor a helper + tests; gate verde.
- 2026-08-30: **PR #1096 abierto** bajo cuenta de Jorge. Esperando review.

## Lección (al cerrar)
<pendiente del review/merge>
