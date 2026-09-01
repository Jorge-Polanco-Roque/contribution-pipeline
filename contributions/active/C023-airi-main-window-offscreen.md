# C023 — moeru-ai/airi — ventana principal off-screen persiste irrecuperable

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#2422](https://github.com/moeru-ai/airi/pull/2422)) — esperando review |
| Nicho | VTuber/IA · desktop (Electron main) |
| Salud del repo | GO — activo; ya mergeé #2408 + 4 PRs abiertos |
| Stack | TypeScript / Electron (vitest) |
| Origen | bug #2181 «Desktop: dragging the main window off-screen persists an unrecoverable position» (`env/os-all`, 0 comentarios) |
| PR URL | **https://github.com/moeru-ai/airi/pull/2422** |
| Issue | https://github.com/moeru-ai/airi/issues/2181 |
| Política IA | ✅ airi no exige disclosure |
| Estimación | P(merge) **alta** (bug real, causa auto-evidente, comportamiento especificado por el reporter, helper puro testeado, 0 comentarios) · +~110 |
| Fechas | seleccionado 2026-08-31 · PR 2026-08-31 · merge — |

## Qué pide el issue
Al arrastrar la ventana desktop fuera de pantalla, la posición inválida se persiste y se restaura igual
al reabrir → ventana invisible, control «Center main window» inalcanzable. Esperado (palabras del reporter):
restaurar bounds guardados **solo tras validar/clampar** contra un work area disponible; sin intersección → safe.

## Causa raíz (auto-evidente)
`main/index.ts` restauraba `x/y` guardados **directo** al `BrowserWindow` sin clamp contra displays.

## Solución
- Helper puro `shared/utils/electron/windows/window-bounds.ts` → `sanitizePersistedWindowBounds(bounds,
  workAreas, primary)`: si los bounds solapan un display → clamp al work area del de mayor solape; si no
  solapan ninguno → centra en el primario. Electron-free → testeable.
- `resolveMainWindowBounds()` en `main/index.ts` lo aplica antes de crear la ventana (inyecta
  `screen.getAllDisplays()`). Sin posición guardada → `x/y` undefined (Electron centra, como antes).
- Ponytail: reusa el patrón `clampBoundsWithinRect` (privado en caption); no refactoricé caption (fuera de scope,
  ofrecido como follow-up en el PR).

## Gate (calidad) — VERDE
- **vitest 6/6** — on-screen intacto · clamp der/abajo · clamp negativo · fuera-de-todo→centra · display
  secundario · sin work areas.
- **Falla sin el fix**: sin el helper, los bounds off-screen se aplican tal cual (el test cubre la lógica de clamp).
- **ESLint 0** (arreglé orden de imports con `--fix`) · **filtro 0 IA** ✓.
- typecheck: no corre local (`isolated-vm`, infra) → CI. Wiring Electron (main/index.ts) no unit-testable local;
  el helper puro sí está 100% cubierto y el bug es auto-evidente del código sin clamp.

## Commit
- `fix(stage-tamagotchi): clamp restored main-window bounds onto an available display` (identidad Jorge, sin trailer IA).

## Acción del accionista
PR #2422 bajo tu cuenta. Siguiente: responder review cuando llegue.

## Bitácora
- 2026-08-31: seleccionado #2181 tras descartar #2123 (posible ya-arreglado en versión reciente, dice
  collaborator) y #2161 (`builtIn_emitSparkCommand` leak: subsistema agent/tool-routing + @nekomeowww core
  triando → perfil trampa openai #4774). #2181 tiene causa localizada, `env/os-all`, 0 comentarios, helper puro
  testeable. Fix + 6 tests + wiring, gate verde, PR #2422. **Cuarto issue distinto de airi** esta racha.
- 2026-08-31: review de **@nekomeowww (MEMBER)** — *"clamp should use es-toolkit"* — y **Codex P2** —
  determinar ownership del display por `bounds` completos (no `workArea`), para no mover al monitor equivocado
  una ventana sobre la taskbar. Ambas atendidas: `clampWithin` usa `clamp` de es-toolkit; firma cambiada a
  `displays: {bounds, workArea}[]` (ownership por bounds → clamp en workArea); test nuevo del caso
  bounds-vs-workArea (falla con la lógica vieja). 7/7 + ESLint 0. Push + respuesta.

## Update 2026-09-01 — CERRADO
Cerrado por @nekomeowww como **"Duplicated"** (alguien ya arreglaba el mismo bug). No fue por calidad.
🎓 Lección: en bugs de subsistemas activos, buscar PRs/efforts abiertos antes de invertir (como openai #4774).
