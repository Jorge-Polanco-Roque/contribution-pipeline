# C020 — moeru-ai/airi — texto de display vs pronunciación TTS (ruby)

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#2413](https://github.com/moeru-ai/airi/pull/2413)) — esperando review |
| Nicho | VTuber/IA · TTS/streaming |
| Salud del repo | GO — repo activo, ya mergeé #2408 aquí |
| Stack | TypeScript / Vue (pnpm monorepo, vitest) |
| Origen | feature #2255 «Support separate display text and TTS pronunciation» (label `needs-more-info`) |
| PR URL | **https://github.com/moeru-ai/airi/pull/2413** |
| Issue | https://github.com/moeru-ai/airi/issues/2255 |
| Política IA | ✅ airi no exige disclosure (consistente con #2408 mergeado) |
| Estimación | P(merge) media (diseño abierto por `needs-more-info` → presentado como propuesta) · +246/−1 |
| Fechas | seleccionado 2026-08-30 · PR 2026-08-30 · merge — |

## Qué pide el issue
Separar el texto que se **muestra** (kanji `約束`) del que se **pronuncia** (lectura
`やくそく`) a partir de markup ruby `｜約束《やくそく》は`. El markup nunca se muestra ni se
habla; el parsing debe ser **seguro a través de fronteras de chunk de streaming arbitrarias**.
Hint del reporter: una proyección `displayText`/`speechText` general en el **boundary
core-agent→speech** es más reutilizable que hacerlo por-provider de TTS.

## Solución
- `packages/stage-ui/src/libs/speech/ruby-annotation.ts` (~138 líneas): proyector **streaming-safe**
  stateful. `createRubyProjector().push(chunk)`/`flush()` → `{displayText, speechText}`.
  Bufferea anotaciones incompletas, commitea al cerrar `》`; malformado → literal en flush (sin pérdida).
  Texto sin anotar pasa igual (no-op). Convenience `projectRuby(text)`.
- Wiring del **lado speech** en `Stage.vue`: `onTokenLiteral` proyecta → `speechText`→TTS;
  reset por mensaje (`onBeforeMessageComposed`); flush en `onStreamEnd`. Canal TTS aislado →
  **display del chat sin regresión** (lo construye el store aparte).
- Render del `displayText` en el chat = **follow-up** (toca el message renderer) — dejado fuera
  para diff mínimo, ofrecido en el cuerpo del PR.

## Decisión de scope
Label `needs-more-info` → diseño no fijado. Entregué la parte difícil y reutilizable (el parser)
+ wiring mínimo, presentado como **propuesta** (sintaxis = 3 constantes en 1 archivo; ubicación =
función pura reubicable). Invito al maintainer a confirmar sintaxis/ubicación/render-display.

## Gate (calidad) — VERDE
- **vitest 9/9** — incluye barrido de **todos** los puntos de corte de chunk (contrato de streaming),
  char-a-char, multi-anotación, malformado, "no emite anotación parcial hasta cerrar".
- **ESLint 0** (config antfu, parser + Stage.vue).
- **filtro 0 IA**: airi sin requisito de disclosure ✓.
- typecheck: no corre local (node_modules incompleto por fallo de build nativo de `isolated-vm`,
  infra ajena) → lo cubre el CI; edición trivialmente bien-tipada.

## Commit
- `4385eed` `feat(stage-ui): separate display text and TTS pronunciation via ruby annotations`
  (identidad Jorge, sin trailer de IA — identidad es del accionista).

## Acción del accionista
PR #2413 bajo tu cuenta. Siguiente: responder al review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-30: seleccionado #2255 (tras confirmar #2297 ya arreglado por #2336). Verifiqué que no
  existe parser ruby en el repo (ponytail: `《》` ya eran soft-punct en el chunker, sin extracción).
  Localicé el boundary real (`Stage.vue:onTokenLiteral`→`appendText`). Parser + tests + wiring speech,
  gate verde, PR #2413 abierto como propuesta (respeta `needs-more-info`).

## Update 2026-09-01 — CERRADO
Cerrado sin merge (feature ruby `needs-more-info` declinada). 🎓 Lección: features `needs-more-info` tienen baja
P(merge) aunque el código/tests sean buenos — priorizar bugs con causa raíz clara sobre features especulativas.
