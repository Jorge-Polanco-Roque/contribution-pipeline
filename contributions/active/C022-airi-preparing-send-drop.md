# C022 — moeru-ai/airi — sends en fase `preparing` se pierden (registro de consumer perdido)

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#2415](https://github.com/moeru-ai/airi/pull/2415)) — esperando review |
| Nicho | VTuber/IA · infra (WebSocket transport, pinia store) |
| Salud del repo | GO — activo, ya mergeé #2408 + PRs #2413/#2414 abiertos |
| Stack | TypeScript / Vue (pnpm monorepo, vitest + pinia) |
| Origen | bug #2305 «consumer registration lost on first connect since the better-ws migration» |
| PR URL | **https://github.com/moeru-ai/airi/pull/2415** |
| Issue | https://github.com/moeru-ai/airi/issues/2305 |
| Política IA | ✅ airi no exige disclosure |
| Estimación | P(merge) **alta** (bug de fiabilidad real, causa raíz diagnosticada por el reporter con refs a línea, fix mínimo, test que falla sin fix) · +67/−11 |
| Fechas | seleccionado 2026-08-30 · PR 2026-08-30 · merge — |

## Qué pide el issue
En un stage recién cargado, el registro de consumer (`input:text`/`input:text:voice`/`input:voice`,
grupo `chat-ingestion`) nunca llega al server → todo `input:text` externo se dropea con "no consumer
registered" hasta el primer reconnect. Reporter hizo un diagnóstico forense con refs a archivo/línea.

## Causa raíz (confirmada)
`module:authenticated` pone `connected=true` + `flush()` **durante la fase `preparing`** de better-ws.
Ahí `Client.send()` devuelve `false` (solo acepta en `ready`), pero `send()`/`flush()` **ignoraban el
booleano**: `send()` iba por la rama directa y dropeaba; `flush()` limpiaba la cola incondicionalmente.
El `flush()` posterior de `onReady` ya no tenía nada. Regresión silenciosa desde la migración a
better-ws (#1989) — antes `send()` solo requería socket `OPEN`.

## Fix
Honrar el booleano: si `Client.send()` reporta no-enviado, **re-encolar**; `flush()` re-encola lo que el
transport aún rechaza. El `flush()` de `onReady` lo entrega. Arregla la causa raíz para **todos** los
sends tempranos, no solo el registro de consumers. `+67/−11`.

## Gate (calidad) — VERDE
- **vitest 14/14** (13 existentes + 1 regresión #2305).
- **Falla sin el fix** ✓ (`pendingSendCount=0` sin el cambio → mensaje perdido).
- **Por qué se escapó**: el `MockClient` del repo devolvía `send()===true` siempre → no modelaba
  `preparing`. Le añadí el estado `ready` (default true, sin romper los 13 tests). Buen hallazgo de
  higiene de test.
- **ESLint 0** · **filtro 0 IA** ✓.
- typecheck: no corre local (`isolated-vm`, infra) → CI.

## Commit
- `fix(stage-ui): deliver sends issued during the transport prepare phase` (identidad Jorge, sin trailer IA).

## Acción del accionista
PR #2415 bajo tu cuenta. Siguiente: responder review cuando llegue.

## Bitácora
- 2026-08-30: seleccionado #2305 (el reporter ya diagnosticó la causa con refs a línea; verifiqué el
  código: `send`/`flush` ignoran el `false` de `Client.send()`). Fix root-cause + regresión que falla
  sin el fix + mejora del mock (modela `preparing`). Gate verde, PR #2415. **Tercer PR en airi esta
  ronda** (tras #2413 feature, #2414 bug TTS).
- 2026-08-30: review de **Codex (P2)** — el repo exige bloque `// ROOT CAUSE:` en tests de regresión
  (usé comentario libre). Reformateé el comentario del test al bloque requerido (falla-antes/fix-después).
  Force-push + respuesta al review. 14/14 verdes.
