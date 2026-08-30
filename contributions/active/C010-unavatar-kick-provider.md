# C010 — microlinkhq/unavatar — añadir provider de avatar de Kick

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#660](https://github.com/microlinkhq/unavatar/pull/660)) — esperando review |
| Nicho | avatars (Node.js, servicio de avatar unificado) |
| Salud del repo | GO — 1.5k★, **17/20 merges de externos** (muy welcoming), skill de naming documentada |
| Stack | JavaScript (Node) |
| Origen | veta "add a provider" (no un issue — servicio popular faltante que yo identifiqué) |
| PR URL | **https://github.com/microlinkhq/unavatar/pull/660** |
| Política IA | ✅ sin ban ni divulgación (repo usa `.agents/skills/` → AI-friendly) |
| Estimación | P(merge) alta (servicio grande faltante, endpoint verificado, patrón claro, repo abierto) · +3 archivos |
| Fechas | seleccionado 2026-08-30 · PR 2026-08-30 · merge — |

## Qué pide (implícito)
unavatar tiene 70+ providers (fetch del avatar de un servicio). **Kick** (streaming, competidor de Twitch
que ya está) faltaba. Añadir un provider = quick win self-contained.

## Solución
Provider minimal (mirror de `mastodon`, API-based): `got` → `kick.com/api/v2/channels/{user}` →
`body.user.profile_pic`. Registrado en `index.js` (tier `username` + map, alfabético). 3 tests
(happy path, sin foto → undefined, encoding). `standard` + suite verdes; pre-commit hook del repo pasó.

## Cómo se eligió (mayor P(merge))
Testeé endpoints de varios candidatos **antes de codear**: Kick (API 200 + `profile_pic` ✓), Last.fm/itch.io
(200 sin patrón obvio), Letterboxd (403), Lichess (sin avatares de usuario). **Kick ganó**: popular + endpoint
verificado desde servidor + patrón simple.

## Lección — vetas de "add a provider" como quick-win
Repos como unavatar (welcoming + patrón documentado + backlog de issues vacío) rinden quick wins **no vía
issues** sino identificando un elemento popular faltante. 🛠️ **Regla:** verificar el endpoint en vivo
(status + ruta exacta del JSON) ANTES de codear; elegir por popularidad × endpoint-que-funciona.

## Acción del accionista
PR publicado bajo tu cuenta. Siguiente: responder al review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-30: elegido Kick (mayor P(merge) tras testear endpoints), implementado + tests, PR #660 abierto.

## Lección (al cerrar)
<pendiente del review/merge>
