# SCOREBOARD — rondas del arena

| Ronda | Repo | Issue→PR | Tipo | Oráculo (antes→después) | Gate 1er intento | CI | Review rounds | Merge |
|---|---|---|---|---|---|---|---|---|
| 001 | Testing_Pipelines | #1→#2 | seeded (yo cablé ambos) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 002 | Testing_Pipelines | #3→#4 | seeded (**agentes separados, sin colusión**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 003 | Testing_Pipelines | #5→#7 | seeded (**aislado en /tmp**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 003 | Testing_Pipelines | #6 (**trampa**) | inválido | — | — | — | — | ⛔ declinado (correcto) |
| 004 | Testing_Pipelines | #8→#9 | seeded (**cross-módulo, vía harness M1**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 005 | Testing_Pipelines | #10→#14 | seeded (**paralelo · worktree**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 005 | Testing_Pipelines | #11→#13 | seeded (**paralelo · worktree**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 005 | Testing_Pipelines | #12→#15 | seeded (**paralelo · worktree**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 006 | Testing_Pipelines | #16→#20 | seeded (**paralelo vía `run.sh`**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 006 | Testing_Pipelines | #17→#21 | seeded (**paralelo vía `run.sh`**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 006 | Testing_Pipelines | #18→#19 | seeded (**paralelo vía `run.sh`**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 007 | Testing_Pipelines | #22→#25 | seeded (**Workflow one-command**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |
| 007 | Testing_Pipelines | #23→#24 | seeded (**Workflow one-command**) | fail→pass ✅ | ✅ | ✅ | 0 | ✅ |

**Agregado:** 12/12 bugs reales mergeados · gate verde a la primera 12/12 · 1/1 trampa declinada · 0 falsos verdes de seguridad · 0 secretos introducidos · Ronda 007: **ronda entera en UN comando** (`Workflow arena-round`) — seed→prep→fix∥→finalize, 5 agentes, no-regresión cruzada verde, score.json auto.
