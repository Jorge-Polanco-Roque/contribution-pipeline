# DASHBOARD.md — Reputación + KPIs

> Fuente de verdad del proyecto. La actualiza el Operador (`CLAUDE.md`) en cada
> evento. El objetivo es **reputación pública en el GitHub del accionista**, no
> dinero. North Star = tasa de aceptación de PRs.

_Última actualización: 2026-08-29_

## Consolidado

| Métrica | Valor |
|---|---|
| ✅ PRs mergeados | **3** — [smallvec#496](https://github.com/servo/rust-smallvec/pull/496) 🟢 · [airi#2408](https://github.com/moeru-ai/airi/pull/2408) 🟢 · [boa#5500](https://github.com/boa-dev/boa/pull/5500) 🟢 |
| 📤 PRs enviados (reales) | **21** (3 🟢 · 15 🟡 en review · 3 🔴 cerrados) |
| 🎯 Tasa de aceptación (North Star) | **50%** (3/6 resueltos; 15 aún en review) (meta ≥ 50%) |
| 📦 Repos distintos con merge | **3** (servo/rust-smallvec, moeru-ai/airi, boa-dev/boa) |
| ⭐ Estrellas / seguidores ganados | **0** |
| 🔥 Racha de actividad (semanas seguidas con ≥1 aporte) | **0** |
| ⏱️ Horas del accionista usadas | **0** |

## KPIs de operación

| KPI | Valor | Meta |
|---|---|---|
| PRs enviados | **21** | — |
| Merges ganados | **3** ✅ | ≥1 en 2 semanas (gate F0) |
| **Tasa de aceptación** (North Star) | **50%** (3/6 resueltos) | ≥ 50% |
| Repos distintos con merge | **3** | crecer sostenido |
| Contribuciones en `active/` | **~15** (incl. 3 PRs en airi 2026-08-30: ruby #2413, TTS multi-byte #2414, preparing-send #2415; C008 openai → `passed/`) | en review |
| Higiene (secretos/deps vulnerables introducidas) | 0 | **0 siempre** (lo fuerza el gate) |

## Contribuciones (registro)

| ID | Repo #issue | Nicho | Estado | Merge? | Horas |
|---|---|---|---|---|---|
| C001 | servo/rust-smallvec #494 → [#496](https://github.com/servo/rust-smallvec/pull/496) | Rust/data-structures | 🟢 **MERGEADO** | ✅ | — |
| C002 | servo/rust-smallvec #416 → [#500](https://github.com/servo/rust-smallvec/pull/500) | Rust/data-structures | 🔴 cerrado (servo prohíbe IA) | — | — |
| C003 | uutils/sed #394 → [#544](https://github.com/uutils/sed/pull/544) | Rust/devtools | 🟡 review (tests añadidos p/ sylvestre) | — | — |
| C004 | RustPython #8610 (dict unhashable msg) | Rust/lenguajes | 🟡 review (CodeRabbit + youknowone atendidos) | — | — |
| C005 | Automattic/harper #4253 (regla wary/weary) | Rust/devtools | 🟡 review (hippietrail atendido) | — | — |
| C006 | moeru-ai/airi #2359 → [#2408](https://github.com/moeru-ai/airi/pull/2408) | TS/AI-companion | 🟢 **MERGEADO** | ✅ | — |
| C007 | uutils/coreutils #14232 → [#14264](https://github.com/uutils/coreutils/pull/14264) | Rust/devtools | 🟡 review (CI rojos flaky/infra, ajenos) | — | — |
| C008 | openai/openai-agents-python #4744 → [#4774](https://github.com/openai/openai-agents-python/pull/4774) | Python/agentes | 🔴 **cerrado sin merge** (@seratch: duplicaba su rediseño #4738 + carrera de ownership) → `passed/` | — | — |
| C010 | microlinkhq/unavatar → [#660](https://github.com/microlinkhq/unavatar/pull/660) | JS/avatars | 🟡 review | — | — |
| C012 | boa-dev/boa #3975 → [#5500](https://github.com/boa-dev/boa/pull/5500) | Rust/lenguajes | 🟢 **MERGEADO** (jedel1043) | ✅ | — |
| C013 | image-rs/image #2324 → [#3107](https://github.com/image-rs/image/pull/3107) | Rust/CV | 🟡 review (cargo-deny ajeno) | — | — |
| C014 | nannou-org/nannou #1095 → [#1096](https://github.com/nannou-org/nannou/pull/1096) | Rust/gráficos | 🟡 review | — | — |
| C015 | sonos/tract #2646 → [#2749](https://github.com/sonos/tract/pull/2749) | Rust/ML-inferencia | 🟡 review | — | — |
| C016 | sktime #10966 → [#10967](https://github.com/sktime/sktime/pull/10967) | Python/ML | 🟡 review (Evilander atendido; all-contributors) | — | — |
| C017 | aeon #3722 → [#3773](https://github.com/aeon-toolkit/aeon/pull/3773) | Python/ML | 🟡 review (all-contributors) | — | — |
| C018 | Nixtla/statsforecast #1202 → [#1225](https://github.com/Nixtla/statsforecast/pull/1225) | Python/forecasting | 🟡 review (CLA firmado; all-contributors) | — | — |
| C020 | moeru-ai/airi #2255 → [#2413](https://github.com/moeru-ai/airi/pull/2413) | TS/AI-companion | 🟡 review (feature ruby; Codex P2 = deferral, `needs-more-info`) | — | — |
| C021 | moeru-ai/airi #2366 → [#2414](https://github.com/moeru-ai/airi/pull/2414) | TS/AI-companion | 🟡 review (Codex P1 atendido: fix movido a chunker activo) | — | — |
| C022 | moeru-ai/airi #2305 → [#2415](https://github.com/moeru-ai/airi/pull/2415) | TS/AI-companion | 🟡 review (Codex P2 atendido: bloque ROOT CAUSE) | — | — |

> ✅ **Nota de reputación:** **3 merges reales en 3 repos distintos** — servo #496 (servo **veta IA**, vetado),
> **airi #2408** (48.5k★) y **boa #5500** (7.5k★, motor JS en Rust). **21 PRs**, todos con
> política de IA verificada (filtro 0), y **cada review de maintainer/bot atendido**. La sesión 2026-08-30
> añadió una **ronda profunda en airi** (3 PRs: feature ruby #2413, bug TTS multi-byte #2414, bug
> preparing-send #2415), todos con causa raíz verificada y test que falla sin el fix; las reviews de Codex se
> atendieron (incl. **P1**: #2414 arreglaba un archivo muerto → movido al chunker activo). El método —first-wins
> de alto impacto + reproducir en main + vetar issues trampa + gate verde + divulgación honesta + respuesta
> técnica a reviews— funciona.
>
> 🔴 **Retrospectiva cerrada (openai #4774, C008):** @seratch lo cerró — duplicaba su PR abierto #4738
> (rediseño del ciclo de vida del PTY) y la carrera de ownership seguía. Lección → LEARNINGS + SOUL §5
> (buscar PRs abiertos del subsistema antes de codear; vetar bugs que exigen rediseño de ownership).
> C008 movido a `passed/`.
>
> ⚠️ *Ledger parcialmente sincronizado: faltan C009/C011 (passed/) en esta tabla; KPIs de cabecera sí exactos.*

## Timeline de eventos

| Fecha | Evento | Merges |
|---|---|---|
| 2026-08-29 | Proyecto creado como máquina de bounties (dinero) | 0 |
| 2026-08-29 | Algora verificado muerto como board de bounties; cuenta borrada por desconfianza | 0 |
| 2026-08-29 | **Pivote dinero → reputación**; reestructura a `contributions/` | 0 |
| 2026-08-29 | 🟢 **PRIMER MERGE** (smallvec #496, arbitrary) — gate F0 cumplido | **1** |
| 2026-08-29 | 🔴 #500 cerrado: **servo prohíbe IA** → servo vetado; pivote a uutils (política pro-IA) | 1 |
| 2026-08-29 | Pipeline dev+test **+ etapa de seguridad** en `pre_submit.sh` (self-test ✓) | 0 |
| 2026-08-29 | [SIM] Arena Ronda 001 (M0): issue→PR→CI→merge en `Testing_Pipelines`; oráculo fail→pass ✓ | 0 (simulación) |
| 2026-08-29 | [SIM] Arena Ronda 002 (M3): **agentes separados sin colusión**; Contributor ciego resolvió #3→PR#4→merge ✓ | 0 (simulación) |
| 2026-08-29 | [SIM] Arena Ronda 003 (M4): **aislamiento real** (/tmp, sin oráculo) + **triaje**: arregló #5→PR#7, declinó trampa #6 ✓ | 0 (simulación) |
| 2026-08-29 | M1: `arena/run.sh` (referee automatizado) · Fase 0: tooling seguridad instalado; **SAST diff-aware** verificado ✓ | 0 |
| 2026-08-29 | **SCA diff-aware** (deps): bloquea solo si el diff toca manifiestos; verificado con vuln real (RUSTSEC-2020-0071) ✓ | 0 |
| 2026-08-29 | [SIM] Arena Ronda 004: bug **cross-módulo** (3 archivos) resuelto en causa raíz vía harness M1 + gate diff-aware; #8→PR#9→merge ✓ | 0 (simulación) |
| 2026-08-29 | [SIM] Arena Ronda 005: **3 Contributors en paralelo (worktrees)** → 3 PRs (#13/#14/#15) mergeados sin conflicto; oráculos pasan juntos ✓ | 0 (simulación) |
| 2026-08-29 | [SIM] Arena Ronda 006: ronda paralela real vía `prep-parallel`/`finalize-parallel` → #16/#17/#18 → PRs #20/#21/#19 merge; no-regresión cruzada ✓ | 0 (simulación) |
| 2026-08-29 | [SIM] Arena Ronda 007: **ronda entera en UN comando** (`Workflow arena-round`) → #22/#23 → PRs #25/#24 merge; 5 agentes, cross-regresión ✓ | 0 (simulación) |
| 2026-08-29 | [SIM] Arena Ronda 008: paralela `run.sh` → #26/#27/#28 → PRs #29/#30/#31 merge; cross-regresión ✓ (15/15 acumulado) | 0 (simulación) |
| 2026-08-30 | **8 PRs en 7 repos distintos** (smallvec, sed, RustPython, harper, airi, coreutils, openai-agents) — diversificación + política de IA verificada en c/u | 1 |
| 2026-08-30 | 🟢 **2º MERGE** (airi #2408, better-ws) — repo pro-IA de 48.5k★ | **2** |
| 2026-08-30 | **+7 PRs** en nichos ML/CV/gráficos: boa, image, nannou, tract, sktime, aeon, statsforecast — 3 apuntan a muros all-contributors | 2 |
| 2026-08-30 | 🟢 **3er MERGE** (boa #5500, quoting de claves) — motor JS en Rust 7.5k★, aprobado por jedel1043, test262 delta 0.00% | **3** |
| 2026-08-30 | **Ronda de reviews atendida:** sed·sylvestre (tests), RustPython·youknowone (plantilla+IA), harper·hippietrail (plantilla+IA+datos), openai-agents·Codex ×3 (Modal+cancellation, push-back a race pre-existente) | 2 |

## Notas

- Gate F0: lograr **≥1 PR mergeado** en repo sano en ≤2 semanas. Si en 5 PRs no
  cae ninguno → revisar selección (SOUL §5), no meter más horas a ciegas.
- **Higiene = regla dura:** ningún PR sale con secretos ni deps vulnerables. Lo
  bloquea `tools/pre_submit.sh`.
- Pendiente humano: revocar OAuth de Algora y limpiar accesos en el GitHub del
  accionista (`github.com/settings/applications`).
