# C008 — openai/openai-agents-python #4744 — corrupción UTF-8 en `collect_pty_output`

| Campo | Valor |
|---|---|
| Estado | 🔴 **CERRADO sin merge** ([#4774](https://github.com/openai/openai-agents-python/pull/4774)) por @seratch (2026-08-30) — ver «Lección (al cerrar)» |
| Nicho | agentes (Python, SDK oficial de OpenAI) |
| Salud del repo | 29k★, muy activo · ⚠️ core-driven (5/30 externos) · **swarmed** (bugs tomados en horas) |
| Stack | Python (uv) |
| Issue URL | https://github.com/openai/openai-agents-python/issues/4744 |
| PR URL | **https://github.com/openai/openai-agents-python/pull/4774** |
| Política IA | ✅ sin política de IA (ni ban ni divulgación) |
| Estimación | P(merge) media (bug real, alto impacto, test que prueba el fix · repo saturado/core-driven) · +79 |
| Fechas | seleccionado 2026-08-29 · PR 2026-08-29 · merge — |

## Qué pide el issue
`collect_pty_output` decodifica cada ventana con `errors="replace"`. Como el output PTY se drena en
**ventanas repetidas sobre un deque persistente**, un carácter multi-byte partido entre ventanas → dos
secuencias parciales → ambas mitades a U+FFFD, texto silenciosamente corrupto. Helper compartido de 5
backends PTY (unix_local/docker/blaxel/daytona/modal).

## Solución
Helper `_incomplete_utf8_tail_len` + **re-encolar la cola UTF-8 incompleta** (`appendleft`) al deque salvo
en la ventana final (`is_done`, donde `replace` es correcto para truncación real). Local, sin cambios de
API/callers. Test de regresión (repro: "ö" partido) — pasa con el fix, **falla sin él**.

## Gate / verificación — VERDE
- `pytest tests/sandbox/test_pty_output.py` 3 passed; mi test falla sin el fix. `ruff`/`mypy`/`pyright` limpios.

## Lección de selección — el espacio de agentes está saturado
Barrí 6 frameworks de agentes ≥10k★ buscando un win limpio:
- **agno** (42k★): 100% swarmed — cada bug/ejemplo/provider ya tenía PR compitiendo (AI-farmers).
- **pydantic-ai** (19.5k★): gatekept (equipo chico, features van al Harness no al core).
- **autogen** (60k★): stale (último push abril).
- **crewAI** (57k★): 7/30 externos. **adk-python**: 0/30. **openai-agents-python**: 5/30, también swarmed.
- 🛠️ **Regla:** en repos hype/swarmed, filtrar por **PRs-compitiendo** es decisivo; el único hueco fue un bug
  **fresco (mismo día) que los farmers aún no habían tomado** — hay que ser rápido. Preferir bugs con causa
  raíz clara y testeable (frontera UTF-8) sobre features (más disputadas).
- ⚠️ Cuidado: varias entradas del search de "agent ≥10k★" tenían **★ inflados/falsos** (posibles honeypots) — descartadas.

## Acción del accionista
PR publicado bajo tu cuenta. Siguiente: responder al review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-29: seleccionado (único bug uncontested tras descartar 6 repos saturados/gatekept), fix verificado, PR #4774 abierto.
- 2026-08-30: 3 rondas de Codex con P1 sucesivos (decoder incremental → path de Modal → tail durable en cancelación),
  atendidos en 4 commits. @seratch **cerró** el PR.

## Lección (al cerrar) — 🔴 rechazo por duplicación + arquitectura
**Motivo (palabras de @seratch):** *"the split UTF-8 bug is real, but this implementation still loses the carried
prefix when the next collection is cancelled... The completion/finalizer ownership race also remains. We are
consolidating this lifecycle work in **#4738**... Closing this duplicate implementation."* (#4738 = PR abierto del
propio maintainer sobre el mismo subsistema).

- 🔎 **Causa raíz — selección/timing (2 señales ignoradas):**
  1. **"Maintainer lo trabaja él"** — un PR abierto (#4738) consolidaba el mismo ciclo de vida. No busqué PRs
     abiertos del subsistema antes de invertir.
  2. **Fix que exige rediseño de ownership, no diff localizable.** El whack-a-mole con Codex (P1 nuevo tras
     cada commit) era la señal de que la causa es arquitectónica.
- 🛠️ **Reglas → SOUL §5** (añadidas): `gh pr list --state open --search "<subsistema>"` antes de codear; vetar
  bugs que exigen reorganizar ownership; core-driven+swarmed sube el riesgo de resolución interna.
- ✅ **Bien:** respuestas técnicas/honestas a cada P1; cierre por arquitectura/duplicación, no por calidad. Relación
  preservada. Costo = *selección* (~4 commits en algo invendible). Detalle en LEARNINGS (2026-08-30).
