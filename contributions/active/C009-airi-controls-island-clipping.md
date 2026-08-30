# C009 — moeru-ai/airi #2400 — controls island expandido alcanzable en ventanas pequeñas

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#2412](https://github.com/moeru-ai/airi/pull/2412)) — esperando review |
| Nicho | AI-companion (TS monorepo, Vue + Electron, `stage-tamagotchi`) |
| Salud del repo | GO — 48.5k★, **ya nos mergeó #2408** (relación establecida) |
| Stack | TypeScript / Vue (UnoCSS) |
| Issue URL | https://github.com/moeru-ai/airi/issues/2400 |
| PR URL | **https://github.com/moeru-ai/airi/pull/2412** |
| Política IA | ✅ sin política de IA (ni ban ni divulgación) |
| Estimación | P(merge) media (fix chico y directo, pero UI + no verificado visualmente) · +4 |
| Fechas | seleccionado 2026-08-30 · PR 2026-08-30 · merge — |

## Qué pide el issue
En monitor/ventana pequeña, el menú expandido del **controls island** se corta y no hay forma de
alcanzar los controles cortados ("no way to make any further adjustments").

## Solución
Causa raíz: el island es `fixed` a una esquina; el **drawer expandido** (auth + grid de 8 botones) crece
verticalmente **sin `max-height` ni `overflow`** → rebasa el alto y se corta, sin scroll. Fix: acotar el
**drawer** (no el island entero — el toggle y controles principales deben quedar fijos) con
`max-h-[calc(100dvh - 5rem)] overflow-y-auto overscroll-contain` → scrollea en vez de cortar. +4 líneas, solo CSS.

## Gate / verificación
- Cambio solo de clases CSS (UnoCSS), no toca lógica/TS. **Limitación honesta:** no verificado visualmente
  (requiere montar la app Electron y encoger la ventana) — se declaró en el PR.

## Estrategia — reforzar un repo que ya nos mergeó
airi ya mergeó C006 (better-ws). Reincidir con un 2º PR **profundiza la relación** con un repo pro-IA de
48.5k★ (KPI: sostener repos donde mergean). Se eligió #2400 por estar **libre** (el reporter dijo que haría PR
pero no lo hizo en ~1 día) y ser el más self-contained de los que quedaban (los demás: UI-pesado o riesgo de alcance).

## Lección — review colaborativo cuando no puedes verificar del todo
Cuando el fix no es 100% verificable localmente (UI/Electron), **abrir con transparencia**: declarar la
limitación + ofrecer las alternativas de UX (aquí: scroll vs encoger iconos vía `controlsIslandIconSize`
vs reposicionar) para que el maintainer dirija. Baja el riesgo de rechazo y hace el review colaborativo desde el arranque.

## Acción del accionista
PR publicado bajo tu cuenta. Siguiente: responder al review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-30: seleccionado (quick win en repo que ya nos mergeó), fix CSS del drawer, PR #2412 abierto con nota de transparencia + alternativas.

## Lección (al cerrar)
<pendiente del review/merge>
