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

## Review recibido (Codex bot) + lección técnica — OIDC trusted publishing
Un bot de revisión (chatgpt-codex-connector) marcó un **P1 válido**: el workflow `release-pkg.yaml` publica
por **OIDC trusted publishing** (`id-token: write`, sin `NODE_AUTH_TOKEN`). npm solo acepta OIDC si el paquete
**ya existe** en npm con su *trusted publisher* configurado → un paquete **nunca publicado** (como `better-ws`,
404) **no puede** publicarse por OIDC en su primer release. Verifiqué el workflow: es OIDC-only, el bot tiene razón.

- 🔎 **Lección:** "quitar el bloqueador de código" (el `private: true`) es **necesario pero a veces no suficiente**
  cuando el despliegue depende de un paso de **ops que solo el mantenedor puede dar** (aquí: bootstrap inicial =
  publish autenticado + configurar trusted publisher). El fix de código sigue siendo correcto; la parte de ops no
  cabe en el PR de un externo.
- 🛠️ **Regla (→ recon/selección):** para issues de *publicación/release*, chequear el método de auth del workflow
  (OIDC vs token) y si el paquete existe ya en npm; si el arreglo real necesita credenciales del org, el PR entrega
  el prerrequisito y lo declara explícitamente, sin prometer que resuelve solo el 100%.
- **Respuesta publicada** (yo redacté, se publicó bajo la cuenta): reconoce el punto, defiende la necesidad del
  cambio, aclara que el bootstrap es acción de mantenedor. https://github.com/moeru-ai/airi/pull/2408#issuecomment-5466127165

## Acción del accionista
PR publicado + respuesta al review publicada. Siguiente: esperar decisión del mantenedor (mergear el prerrequisito
de código + hacer el bootstrap de ops de `better-ws` en npm).

## Bitácora
- 2026-08-29: seleccionado (first-win tras descartar #2297 ya-resuelto y #1477 contestado), fix mínimo, PR #2408 abierto.
- 2026-08-29: review P1 de Codex (OIDC/bootstrap) — verificado y válido; respuesta publicada aclarando el alcance.

## Lección (al cerrar)
<pendiente del review/merge>
