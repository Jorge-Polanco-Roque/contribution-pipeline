# C021 — moeru-ai/airi — TTS corrompe scripts sin espacios (grapheme clusters descartados)

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#2414](https://github.com/moeru-ai/airi/pull/2414)) — esperando review |
| Nicho | VTuber/IA · TTS/streaming |
| Salud del repo | GO — activo, ya mergeé #2408 + PR #2413 abierto |
| Stack | TypeScript / Vue (pnpm monorepo, vitest) |
| Origen | bug #2366 «Thai (and other space-less script) TTS text gets corrupted» |
| PR URL | **https://github.com/moeru-ai/airi/pull/2414** |
| Issue | https://github.com/moeru-ai/airi/issues/2366 |
| Política IA | ✅ airi no exige disclosure |
| Estimación | P(merge) **alta** (bug real, causa raíz confirmada, fix mínimo, test que falla sin fix) · +7/−0 código |
| Fechas | seleccionado 2026-08-30 · PR 2026-08-30 · merge — |

## Qué pide el issue
El texto enviado al TTS se corrompe en tailandés (chat correcto, voz gibberish). Reporter
**supone** split por espacios / bytes.

## Causa raíz (confirmada por mí, distinta a la supuesta)
No es el split por espacios (ese path ya usa `Intl.Segmenter`/grapheme clusters vía `clustr`, que
hace stream-decode correcto). Es `chunkTTSInput` (`utils/tts.ts:76`): la guarda `if (value.length > 1)`
hace `continue` **descartando** el grapheme cluster (en el chunker **activo**
`pipelines-audio/src/processors/tts-chunker.ts:72` — ver corrección abajo). En
tailandés/lao/khmer/devanagari una sílaba es
consonante + vocal/tono combinantes = cluster multi-code-unit → **se pierde**; los consonantes sueltos
que quedan se reensamblan en otras palabras válidas. Reproducido en test unitario:
`ดึกป่านนี้แล้วยังจะหาเรื่องกินอีกนะคะเนี่ย` → `กานแวงจะหาเองนกนะคะเย` en `main`.

## ⚠️ Corrección post-review (Codex, P1) — 2026-08-30
**Primer intento tocó el archivo EQUIVOCADO.** Arreglé `stage-ui/src/utils/tts.ts` (`chunkTTSInput`),
que resultó ser **código muerto** (ningún importador). El chunker **activo** para chat auto-TTS es
`pipelines-audio/src/processors/tts-chunker.ts` (`chunkTtsInput`, usado por `createSpeechPipeline` en
Stage.vue), copia duplicada con el mismo bug. Codex lo marcó (P1). **Force-push**: moví el fix al chunker
activo, revertí el muerto, test de regresión en `tts-chunker.test.ts`. Lección → LEARNINGS.

## Fix
`buffer += value` en esa rama (preservar el cluster como texto normal; nunca es puntuación de 1 char).
1 línea de cambio de comportamiento. También preserva emoji ZWJ. En `pipelines-audio/tts-chunker.ts`.

## Gate (calidad) — VERDE
- **vitest 17/17** en `tts-chunker.test.ts` (14 existentes + 3 nuevos: Thai match exacto, Devanagari
  matras, ASCII sin regresión).
- **Falla sin el fix** ✓ (el test Thai reproduce la corrupción en el chunker activo).
- **ESLint 0** · **filtro 0 IA** ✓.
- typecheck: no corre local (node_modules incompleto por `isolated-vm`, infra) → CI.

## Commit
- `fix(pipelines-audio): preserve multi-code-unit grapheme clusters in TTS chunking` (identidad Jorge, sin trailer IA).

## Acción del accionista
PR #2414 bajo tu cuenta. Siguiente: responder review cuando llegue.

## Bitácora
- 2026-08-30: seleccionado #2366. **Verifiqué la causa raíz real antes de codear** (regla del proyecto):
  descarté la hipótesis del reporter (espacios/bytes) leyendo `clustr` (stream-decode OK) y hallé el
  descarte de clusters en `tts.ts`. Reproducción unitaria (falla sin fix) → fix de 1 línea + tests de
  regresión (Thai/Devanagari/ASCII). Gate verde, PR #2414. Segundo PR en airi esta ronda (tras #2413).
