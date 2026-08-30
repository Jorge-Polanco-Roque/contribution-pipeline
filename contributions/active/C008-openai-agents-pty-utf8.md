# C008 — openai/openai-agents-python #4744 — corrupción UTF-8 en `collect_pty_output`

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#4774](https://github.com/openai/openai-agents-python/pull/4774)) — esperando review |
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

## Lección (al cerrar)
<pendiente del review/merge>
