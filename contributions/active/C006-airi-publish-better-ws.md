# C006 — moeru-ai/airi #2359 — publicar `@proj-airi/better-ws` (server-sdk roto en npm)

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#2408](https://github.com/moeru-ai/airi/pull/2408)) — esperando review |
| Nicho | infra/AI-companion (TypeScript monorepo, pnpm) |
| Salud del repo | GO — 48.5k★, MIT, muy activo (144 merges/30d) · ⚠️ solo 6/30 merges de externos |
| Stack | TypeScript (pnpm workspaces) |
| Issue URL | https://github.com/moeru-ai/airi/issues/2359 |
| PR URL | **https://github.com/moeru-ai/airi/pull/2408** |
| Etiquetas | bug · scope/engineering |
| Política IA | ✅ sin política de IA (ni ban ni divulgación) — seguro, sin etiqueta |
| Estimación | P(merge) alta (bug real de alto impacto, fix mínimo y verificado) · −1 línea |
| Fechas | seleccionado 2026-08-29 · PR 2026-08-29 · merge — |

## Qué pide el issue
`pnpm add @proj-airi/server-sdk` desde npm falla con 404 de `@proj-airi/better-ws`.

## Solución
`better-ws` tenía `"private": true` → el release (`pnpm publish -r --access public`) lo **omite**, pero
`server-sdk` (público) lo declara como dependencia runtime → install externo roto. Sus hermanos publicados
(`server-sdk`, `server-shared`) **no** son private y comparten la misma config `files`/`exports`. **Fix:
quitar `"private": true`** (−1 línea). No requiere changeset (no usan changesets).

## Gate / verificación
- JSON válido; `better-ws` conserva `name`/`version`/`files`/`exports`/build (`tsdown`) → publica limpio.
- Causa raíz verificada vía el workflow `release-pkg.yaml` (`pnpm publish -r` omite private) + comparación con hermanos.

## Estrategia (decisión del accionista)
airi es **48.5k★ pero difícil de mergear como externo** (6/30) + stack nuevo. Se eligió **first-win pequeño y
de bajo riesgo** (bug de empaquetado) para construir confianza antes de una feature grande (p.ej. #2255).

## Lección (selección)
- **Filtro "ya resuelto":** el candidato inicial #2297 (docs) **ya estaba corregido** en `main` (los 5 items) →
  un PR habría sido no-op. Siempre verificar el estado actual del archivo, no solo el texto del issue.
- **Filtro "PRs compitiendo":** #1477 (Fish Audio TTS) era un cementerio (1 abierto + 4 cerrados) → descartado.
- **Causa raíz > síntoma:** el bug no se arregla añadiendo la dep (ya estaba), sino quitando el flag que impide publicarla.

## Acción del accionista
PR publicado bajo tu cuenta. Siguiente: responder al review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-29: seleccionado (first-win tras descartar #2297 ya-resuelto y #1477 contestado), fix mínimo, PR #2408 abierto.

## Lección (al cerrar)
<pendiente del review/merge>
