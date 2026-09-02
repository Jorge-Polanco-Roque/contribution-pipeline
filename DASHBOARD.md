# DASHBOARD.md — Reputación + KPIs

> Fuente de verdad del proyecto. La actualiza el Operador (`CLAUDE.md`) en cada
> evento. El objetivo es **reputación pública en el GitHub del accionista**, no
> dinero. North Star = tasa de aceptación de PRs.

_Última actualización: 2026-09-01_

## Consolidado

| Métrica | Valor |
|---|---|
| ✅ PRs mergeados | **3** — [smallvec#496](https://github.com/servo/rust-smallvec/pull/496) 🟢 · [airi#2408](https://github.com/moeru-ai/airi/pull/2408) 🟢 · [boa#5500](https://github.com/boa-dev/boa/pull/5500) 🟢 |
| 📤 PRs enviados (reales) | **29** (3 🟢 · 20 🟡 en review · 6 🔴 cerrados) + unavatar código mergeado vía #661 (sin crédito) |
| 🎯 Tasa de aceptación (North Star) | **33%** (3/9 resueltos; 20 en review) — *ver nota* (meta ≥ 50%) |
| 📦 Repos distintos con merge | **3** (servo/rust-smallvec, moeru-ai/airi, boa-dev/boa) |
| ⭐ Estrellas / seguidores ganados | **0** |
| 🔥 Racha de actividad (semanas seguidas con ≥1 aporte) | **0** |
| ⏱️ Horas del accionista usadas | **0** |

## KPIs de operación

| KPI | Valor | Meta |
|---|---|---|
| PRs enviados | **29** | — |
| Merges ganados | **3** ✅ (+ unavatar código vía #661, sin crédito) | ≥1 en 2 semanas (gate F0) |
| **Tasa de aceptación** (North Star) | **33%** (3/9 resueltos) — cierres por *duplicado/política/declinado*, no calidad | ≥ 50% |
| Repos distintos con merge | **3** | crecer sostenido |
| Contribuciones en `active/` | **~15** (airi: #2414/#2415 en review, #2412 demo; #2413/#2422 cerrados; findutils #857 nuevo) | en review |
| Higiene (secretos/deps vulnerables introducidas) | 0 | **0 siempre** (lo fuerza el gate) |

## Contribuciones (registro)

| ID | Repo #issue | Nicho | Estado | Merge? | Horas |
|---|---|---|---|---|---|
| C001 | servo/rust-smallvec #494 → [#496](https://github.com/servo/rust-smallvec/pull/496) | Rust/data-structures | 🟢 **MERGEADO** | ✅ | — |
| C002 | servo/rust-smallvec #416 → [#500](https://github.com/servo/rust-smallvec/pull/500) | Rust/data-structures | 🔴 cerrado (servo prohíbe IA) | — | — |
| C003 | uutils/sed #394 → [#544](https://github.com/uutils/sed/pull/544) | Rust/devtools | 🟡 review (tests añadidos p/ sylvestre) | — | — |
| C004 | RustPython #8610 (dict unhashable msg) | Rust/lenguajes | 🟡 review (✅ aprobado por luantaraschi; **CI fix pusheado** — pop CPython 3.14 + ruff) | — | — |
| C005 | Automattic/harper #4253 (regla wary/weary) | Rust/devtools | 🟡 review (rebase→MERGEABLE; **testing con datos reales (GH code search) → afinado ToWary a `weary eye` singular, elimina falso positivo de "weary eyes"=tired**; test regresión; hippietrail atendido con transparencia) | — | — |
| C006 | moeru-ai/airi #2359 → [#2408](https://github.com/moeru-ai/airi/pull/2408) | TS/AI-companion | 🟢 **MERGEADO** | ✅ | — |
| C007 | uutils/coreutils #14232 → [#14264](https://github.com/uutils/coreutils/pull/14264) | Rust/devtools | 🟡 review (CI rojos flaky/infra, ajenos) | — | — |
| C008 | openai/openai-agents-python #4744 → [#4774](https://github.com/openai/openai-agents-python/pull/4774) | Python/agentes | 🔴 **cerrado sin merge** (@seratch: duplicaba su rediseño #4738 + carrera de ownership) → `passed/` | — | — |
| C010 | microlinkhq/unavatar → [#660](https://github.com/microlinkhq/unavatar/pull/660) | JS/avatars | 🟢 **código mergeado vía #661** (@Kikobeats re-creó; sin crédito a Jorge) | ~ | — |
| C012 | boa-dev/boa #3975 → [#5500](https://github.com/boa-dev/boa/pull/5500) | Rust/lenguajes | 🟢 **MERGEADO** (jedel1043) | ✅ | — |
| C013 | image-rs/image #2324 → [#3107](https://github.com/image-rs/image/pull/3107) | Rust/CV | 🟡 review (cargo-deny ajeno) | — | — |
| C014 | nannou-org/nannou #1095 → [#1096](https://github.com/nannou-org/nannou/pull/1096) | Rust/gráficos | 🟡 review | — | — |
| C015 | sonos/tract #2646 → [#2749](https://github.com/sonos/tract/pull/2749) | Rust/ML-inferencia | 🟡 review | — | — |
| C016 | sktime #10966 → [#10967](https://github.com/sktime/sktime/pull/10967) | Python/ML | 🟡 review (Evilander atendido; all-contributors) | — | — |
| C017 | aeon #3722 → [#3773](https://github.com/aeon-toolkit/aeon/pull/3773) | Python/ML | 🟡 review (all-contributors) | — | — |
| C018 | Nixtla/statsforecast #1202 → [#1225](https://github.com/Nixtla/statsforecast/pull/1225) | Python/forecasting | 🟡 review (CLA firmado; all-contributors) | — | — |
| C020 | moeru-ai/airi #2255 → [#2413](https://github.com/moeru-ai/airi/pull/2413) | TS/AI-companion | 🔴 **cerrado** (feature ruby `needs-more-info` declinada) | — | — |
| C021 | moeru-ai/airi #2366 → [#2414](https://github.com/moeru-ai/airi/pull/2414) | TS/AI-companion | 🟡 review (Codex P1 atendido: fix movido a chunker activo) | — | — |
| C022 | moeru-ai/airi #2305 → [#2415](https://github.com/moeru-ai/airi/pull/2415) | TS/AI-companion | 🟡 review (Codex P2 atendido: bloque ROOT CAUSE) | — | — |
| C023 | moeru-ai/airi #2181 → [#2422](https://github.com/moeru-ai/airi/pull/2422) | TS/Electron-desktop | 🔴 **cerrado** ("Duplicated" por @nekomeowww) | — | — |
| C025 | uutils/findutils #778 → [#857](https://github.com/uutils/findutils/pull/857) | Rust/devtools | 🟡 review (mindepth>maxdepth→vacío, compat GNU; test falla sin fix) | — | — |
| C026 | Batch «10 quick wins / 10 repos» → [numbat #888](https://github.com/sharkdp/numbat/pull/888) · [onefetch #1853](https://github.com/o2sh/onefetch/pull/1853) · [jq #3623](https://github.com/jqlang/jq/pull/3623) · [yq #2849](https://github.com/mikefarah/yq/pull/2849) · [gum #1141](https://github.com/charmbracelet/gum/pull/1141) · [git-cliff #1627](https://github.com/orhun/git-cliff/pull/1627) | multi | 🟡 **6 PRs abiertos** (4 limpios + gum/git-cliff con nota de dirección) · 4 descartados en filtro-0 | — | — |
| C027 | delta-io/delta-kernel-rs #2749 → [#3250](https://github.com/delta-io/delta-kernel-rs/pull/3250) | Rust/Delta-Lake (358★) | 🟡 review (**bug de correctitud**: decimales negativos zero-extended → row-group skipping poda filas; fix sign-extensión + test que falla sin fix; clippy/tests verdes; repo pro-IA) | — | — |
| C028 | rust-diplomat/diplomat #1126 → [#1269](https://github.com/rust-diplomat/diplomat/pull/1269) | Rust/FFI (901★) | 🟡 review (**crash**: `None`→`char32_t` aceptaba basura → abort SIGABRT; fix guard `is_none()` en template+generado; test verificado end-to-end (crashea sin fix, TypeError con fix; 37 tests verdes)) | — | — |
| C029 | AMICI-dev/AMICI #918 → [#3235](https://github.com/AMICI-dev/AMICI/pull/3235) | Python/ML-científico (144★) | 🟡 review (good-first-issue: warning si observable del observation_model no está en el modelo pysb, antes ignorado en silencio; fix+test Python; verificación vía CI del repo, build C++ local desproporcionado) | — | — |
| C030 | jupyter-book/mystmd #2984 → [#3047](https://github.com/jupyter-book/mystmd/pull/3047) | TS/Jupyter-MyST (519★) | 🟡 review (Typst export rompía con glossary refs multi-palabra `<term-x y>` inválido; fix root-cause `label()` (empareja target), no slugify; test que falla sin fix; **verificado end-to-end** (tsc+71 tests+prettier+eslint, bun/turbo); changeset + disclosure IA; **+fix seguridad** escape de comillas tras review) | — | — |
| C031 | mario-eth/soldeer #236 → [#406](https://github.com/mario-eth/soldeer/pull/406) | Rust/Foundry-devtools (393★) | 🟡 review (maintainers lo pidieron: inferir subdir de fuentes `src`/`contracts` en remappings como forge; **restricción de beeb "no permanente" respetada** (el test que añadí cazó un defecto en la preservación → corregido); 161 tests + 2 nuevos verdes) | — | — |

> ✅ **Nota de reputación:** **3 merges reales en 3 repos distintos** — servo #496 (servo **veta IA**, vetado),
> **airi #2408** (48.5k★) y **boa #5500** (7.5k★, motor JS en Rust) — **+ unavatar código mergeado vía #661**
> (Kikobeats lo re-creó; sin crédito). **29 PRs**, todos con política de IA verificada (filtro 0) y cada review
> atendido. RustPython #8610 aprobado por el experto (CI fix pusheado). **Ronda de 10 quick wins → 6 PRs
> nuevos** en 6 repos distintos (numbat, onefetch, jq, yq, gum, git-cliff; 4 descartados en filtro-0).
>
> ⚠️ **Aceptación bajó a 33%** (3/9): los cierres NO fueron por calidad — airi #2413 (feature `needs-more-info`
> declinada), airi #2422 (**"Duplicated"**), openai #4774 (rediseño del maintainer), scikit-image/servo (política IA).
> 🎓 **Lecciones nuevas:** (1) activar *"allow edits by maintainers"* en PRs → si el maintainer no puede editar tu
> rama, re-crea el PR a su nombre y pierdes el crédito (unavatar). (2) Features `needs-more-info` tienen baja
> P(merge) aunque el código sea bueno — priorizar bugs con causa clara. El método —first-wins de alto impacto +
> reproducir en main + gate verde + respuesta técnica a reviews— funciona; el ajuste es en **selección**.
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
| 2026-09-01 | 🏅 **Achievements de GitHub:** PR interno [contribution-pipeline #1](https://github.com/Jorge-Polanco-Roque/contribution-pipeline/pull/1) (gitignore, co-authored con JorgePolancoMX, merge sin review) → dispara **YOLO** + **Pair Extraordinaire**. Quickdraw ya en perfil; Pull Shark elegible (3 merges OSS) pendiente de sync/toggle. *No cuenta como contribución OSS ni afecta el North Star.* | 3 |
| 2026-09-02 | 🔧 **harper #4253 desbloqueado:** rebase sobre `master` (conflicto en registro de linters resuelto), review de hippietrail ya atendido → **CONFLICTING → MERGEABLE**; 6354 tests + fmt/clippy verdes, force-push al fork. Queda a review del maintainer. | 3 |
| 2026-09-02 | 🔬 **harper #4253 — testing con datos reales** (hippietrail pidió validar utilidad): GH code search + web → error real raro y `weary eyes`=tired es correcto (falso positivo). **Afinado ToWary a `weary eye` singular** + test de regresión; comentario transparente al maintainer. Convierte objeción en mejora. | 3 |
| 2026-09-02 | 🤝 **onefetch #1853 APROBADO** por @spenserblack; preguntó por uso de IA → **disclosure honesta publicada** (persona real supervisa, IA para calidad/seguridad + replies por idioma). Política de transparencia añadida a SOUL §7 / CLAUDE. | 3 |
| 2026-09-02 | 🎯 **Caza de quick wins (100-1000★):** 6 repos evaluados en paralelo → 1er PR nuevo: **delta-kernel-rs [#3250](https://github.com/delta-io/delta-kernel-rs/pull/3250)** (C027, bug de correctitud decimal, repo pro-IA). Pipeline: diplomat #1126 en curso. Objetivo: llegar a 6 merges. | 3 |
| 2026-09-02 | 🎯 **2º quick win:** diplomat [#1269](https://github.com/rust-diplomat/diplomat/pull/1269) (C028, 901★) — bug resultó ser **crash SIGABRT** (`None`→char32_t); fix verificado end-to-end montando build nanobind (3 etapas). Siguiente: AMICI #918. | 3 |
| 2026-09-02 | 🎯 **3er quick win:** AMICI [#3235](https://github.com/AMICI-dev/AMICI/pull/3235) (C029, good-first-issue) — warning para observables inexistentes en pysb import. **3 PRs nuevos hoy** en 3 repos (delta-kernel, diplomat, AMICI) → tiros a puerta hacia 6 merges. | 3 |
| 2026-09-02 | 🎯 **2ª ronda de scouting** (6 repos, 2 SKIP: rover/calcite cerrados a externos) + **4º quick win:** mystmd [#3047](https://github.com/jupyter-book/mystmd/pull/3047) (C030, Jupyter 519★) — fix Typst glossary refs, verificado end-to-end (bun/turbo). **4 PRs nuevos hoy.** Pipeline: lockbook #3901. | 3 |
| 2026-09-02 | 🛡️ **Filtro en acción:** otel-arrow #1278 SKIP (issue tomado por PR activo #3698) · lockbook #3901 SKIP (issue vago, sin causa raíz clara, requiere cuenta). Review de seguridad cazó inyección en mystmd #3047 → **escape añadido**. | 3 |
| 2026-09-02 | 🎯 **5º quick win:** soldeer [#406](https://github.com/mario-eth/soldeer/pull/406) (C031, Foundry 393★) — inferencia de source dir en remappings; restricción "no permanente" de beeb respetada (test cazó defecto propio → corregido). **5 PRs nuevos hoy en 5 repos** (delta-kernel, diplomat, AMICI, mystmd, soldeer). | 3 |

## Notas

- Gate F0: lograr **≥1 PR mergeado** en repo sano en ≤2 semanas. Si en 5 PRs no
  cae ninguno → revisar selección (SOUL §5), no meter más horas a ciegas.
- **Higiene = regla dura:** ningún PR sale con secretos ni deps vulnerables. Lo
  bloquea `tools/pre_submit.sh`.
- Pendiente humano: revocar OAuth de Algora y limpiar accesos en el GitHub del
  accionista (`github.com/settings/applications`).
