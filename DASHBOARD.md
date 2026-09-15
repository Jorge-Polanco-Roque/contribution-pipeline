# DASHBOARD.md — Reputación + KPIs

> Fuente de verdad del proyecto. La actualiza el Operador (`CLAUDE.md`) en cada
> evento. El objetivo es **reputación pública en el GitHub del accionista**, no
> dinero. North Star = tasa de aceptación de PRs.

_Última actualización: 2026-09-15_

## Consolidado

| Métrica | Valor |
|---|---|
| ✅ PRs mergeados | **10** — smallvec#496 · airi#2408 · boa#5500 · onefetch#1853 · tract#2749 · findutils#857 · diplomat#1269 · git-cliff#1627 · foundry#16841 · [goauthentik#26111](https://github.com/goauthentik/authentik/pull/26111) 🟢 |
| 📤 PRs enviados (reales) | **46** (10 🟢 · 24 🟡 en review · 12 🔴 cerrados) + unavatar código mergeado vía #661 (sin crédito) |
| 🎯 Tasa de aceptación (North Star) | **45%** (10/22 resueltos; 24 en review) — cierres de foco/scope/política/duplicado, ninguno por calidad |
| 📦 Repos distintos con merge | **10** (+ goauthentik/authentik) |
| 🏅 GitHub Pull Shark | **10/16 para Bronze** (solo cuentan repos ajenos; faltan 6) |
| 🧠 GitHub Galaxy Brain | ✅ **CONSEGUIDO** 2026-09-15 (2 accepted answers: sqlx [#4232](https://github.com/launchbadge/sqlx/discussions/4232) · [#4325](https://github.com/launchbadge/sqlx/discussions/4325)) |
| ⭐ Estrellas / seguidores ganados | **0** |
| 🔥 Racha de actividad (semanas seguidas con ≥1 aporte) | **2** |
| ⏱️ Horas del accionista usadas | **0** |

## KPIs de operación

| KPI | Valor | Meta |
|---|---|---|
| PRs enviados | **46** | — |
| Merges ganados | **10** ✅ (+ unavatar código vía #661, sin crédito) | ≥1 en 2 semanas (gate F0) |
| **Tasa de aceptación** (North Star) | **45%** (10/22 resueltos) — cierres por *duplicado/política/declinado/demo/scope-maintainer/repo-inactivo*, no calidad | ≥ 50% |
| Repos distintos con merge | **10** | crecer sostenido |
| Contribuciones en `active/` | **22 en review** (airi #2414/#2415 + delta/mystmd/soldeer/harper/RustPython/sktime/aeon/image/statsforecast/coreutils/sed/numbat/jq/gum/Daft #7508/sail #2580/nushell #19021/foundry #16841 + **iggy #4173/conftest #1425/goauthentik #26111/woodpecker #7141/topgrade #2337/bat #4011 nuevos**); onefetch/tract/findutils/diplomat/git-cliff mergeados; AMICI/nannou/yq cerrados; OZ #6620 en espera; documenso/bevy/alacritty filtro-0/no-fix | en review |
| Higiene (secretos/deps vulnerables introducidas) | 0 | **0 siempre** (lo fuerza el gate) |

## Contribuciones (registro)

| ID | Repo #issue | Nicho | Estado | Merge? | Horas |
|---|---|---|---|---|---|
| C001 | servo/rust-smallvec #494 → [#496](https://github.com/servo/rust-smallvec/pull/496) | Rust/data-structures | 🟢 **MERGEADO** | ✅ | — |
| C002 | servo/rust-smallvec #416 → [#500](https://github.com/servo/rust-smallvec/pull/500) | Rust/data-structures | 🔴 cerrado (servo prohíbe IA) | — | — |
| C003 | uutils/sed #394 → [#544](https://github.com/uutils/sed/pull/544) | Rust/devtools | 🟡 review (tests añadidos p/ sylvestre) | — | — |
| C004 | RustPython #8610 (dict unhashable msg) | Rust/lenguajes | 🟡 review (rebase +28 → **CI verde** (CodSpeed re-midió limpio); **puesto en cumplimiento AI policy** 2026-09-03: template restaurado + trailers `Assisted-by` + disclosure; youknowone respondido. luantaraschi con feedback técnico positivo) | — | — |
| C005 | Automattic/harper #4253 (regla wary/weary) | Rust/devtools | 🟡 review (rebase→MERGEABLE; **testing con datos reales (GH code search) → afinado ToWary a `weary eye` singular, elimina falso positivo de "weary eyes"=tired**; test regresión; hippietrail atendido con transparencia) | — | — |
| C006 | moeru-ai/airi #2359 → [#2408](https://github.com/moeru-ai/airi/pull/2408) | TS/AI-companion | 🟢 **MERGEADO** | ✅ | — |
| C007 | uutils/coreutils #14232 → [#14264](https://github.com/uutils/coreutils/pull/14264) | Rust/devtools | 🟡 review (rebase +64 → **CI verde**; los rojos previos eran apt-403/flaky de infra, ajenos) | — | — |
| C008 | openai/openai-agents-python #4744 → [#4774](https://github.com/openai/openai-agents-python/pull/4774) | Python/agentes | 🔴 **cerrado sin merge** (@seratch: duplicaba su rediseño #4738 + carrera de ownership) → `passed/` | — | — |
| C010 | microlinkhq/unavatar → [#660](https://github.com/microlinkhq/unavatar/pull/660) | JS/avatars | 🟢 **código mergeado vía #661** (@Kikobeats re-creó; sin crédito a Jorge) | ~ | — |
| C012 | boa-dev/boa #3975 → [#5500](https://github.com/boa-dev/boa/pull/5500) | Rust/lenguajes | 🟢 **MERGEADO** (jedel1043) | ✅ | — |
| C013 | image-rs/image #2324 → [#3107](https://github.com/image-rs/image/pull/3107) | Rust/CV | 🟡 review (cargo-deny resuelto 2026-09-03: skip de `miniz_oxide` en `deny.toml` — dup transitivo png/exr(0.8) vs flate2(0.9), mismo patrón que ya usan para `syn`) | — | — |
| C014 | nannou-org/nannou #1095 → [#1096](https://github.com/nannou-org/nannou/pull/1096) | Rust/gráficos | 🔴 **cerrado por foco** (nosotros) 2026-09-11 — **repo inactivo**: último push 2026-07-15 (~2 meses), 0 PRs mergeados desde que abrí el mío, sin review. Maintainer efectivamente ausente → cierre de limpieza (reabrible). Fix correcto. | — | — |
| C015 | sonos/tract #2646 → [#2749](https://github.com/sonos/tract/pull/2749) | Rust/ML-inferencia | 🟢 **MERGEADO** (kali) 2026-09-08 — SimplifiedLayerNormalization→RMS norm (silent correctness bug); pulido de review: scale no unitario + corrección del bias | ✅ | — |
| C016 | sktime #10966 → [#10967](https://github.com/sktime/sktime/pull/10967) | Python/ML | 🟡 review (**bug real de Evilander corregido** 2026-09-03: instance-loss en `nested_univ` por round-trip lossy vía `pd-multiindex`; fix reconstruye preservando instancias vacías + test de regresión (11 pass); pusheado) | — | — |
| C017 | aeon #3722 → [#3773](https://github.com/aeon-toolkit/aeon/pull/3773) | Python/ML | 🟡 review (all-contributors) | — | — |
| C018 | Nixtla/statsforecast #1202 → [#1225](https://github.com/Nixtla/statsforecast/pull/1225) | Python/forecasting | 🟡 review (CLA firmado; all-contributors) | — | — |
| C020 | moeru-ai/airi #2255 → [#2413](https://github.com/moeru-ai/airi/pull/2413) | TS/AI-companion | 🔴 **cerrado** (feature ruby `needs-more-info` declinada) | — | — |
| C021 | moeru-ai/airi #2366 → [#2414](https://github.com/moeru-ai/airi/pull/2414) | TS/AI-companion | 🟡 review (Codex P1 atendido: fix movido a chunker activo) | — | — |
| C022 | moeru-ai/airi #2305 → [#2415](https://github.com/moeru-ai/airi/pull/2415) | TS/AI-companion | 🟡 review (Codex P2 atendido: bloque ROOT CAUSE) | — | — |
| C023 | moeru-ai/airi #2181 → [#2422](https://github.com/moeru-ai/airi/pull/2422) | TS/Electron-desktop | 🔴 **cerrado** ("Duplicated" por @nekomeowww) | — | — |
| C024 | moeru-ai/airi #2400 → [#2412](https://github.com/moeru-ai/airi/pull/2412) | TS/Electron-desktop | 🔴 **cerrado por autor** (2026-09-03): el fix era correcto (cap+scroll del drawer en ventana pequeña), pero nayounsang pidió video/GIF y el demo no logró mostrarlo fielmente en la app Electron real → cerrado por decisión del accionista | — | — |
| C025 | uutils/findutils #778 → [#857](https://github.com/uutils/findutils/pull/857) | Rust/devtools | 🟢 **MERGEADO** (cakebaker) 2026-09-09 — mindepth>maxdepth→vacío, compat GNU; test de integración pedido por sylvestre añadido | ✅ | — |
| C026 | Batch «10 quick wins / 10 repos» → [onefetch #1853](https://github.com/o2sh/onefetch/pull/1853) 🟢 · [numbat #888](https://github.com/sharkdp/numbat/pull/888) · [jq #3623](https://github.com/jqlang/jq/pull/3623) · [yq #2849](https://github.com/mikefarah/yq/pull/2849) 🔴 · [gum #1141](https://github.com/charmbracelet/gum/pull/1141) · [git-cliff #1627](https://github.com/orhun/git-cliff/pull/1627) 🟢 | multi | 🟢 **onefetch MERGEADO** (o2sh) 2026-09-08 · 🟢 **git-cliff #1627 MERGEADO** (orhun) 2026-09-13 — rehecho a 1 commit + 2º fixture #1369 tras su review. 🔴 **yq #2849 cerrado por foco** 2026-09-12 (mikefarah no mergea externos). Resto 🟡 abiertos: numbat/jq/gum | ✅ (2/6, 1🔴) | — |
| C027 | delta-io/delta-kernel-rs #2749 → [#3250](https://github.com/delta-io/delta-kernel-rs/pull/3250) | Rust/Delta-Lake (358★) | 🟡 review (**bug de correctitud**: decimales negativos zero-extended → row-group skipping poda filas; fix sign-extensión + test que falla sin fix; clippy/tests verdes; repo pro-IA) | — | — |
| C028 | rust-diplomat/diplomat #1126 → [#1269](https://github.com/rust-diplomat/diplomat/pull/1269) | Rust/FFI (901★) | 🟢 **MERGEADO** (tyler-zeromatter) 2026-09-09 — 2ª ronda de review: en vez de rechazar `None`, `char32_t` ahora default-init a `U'\0'` (como C struct); test `PrimitiveStruct(...,None,...)` pasa sin excepción. **Un ping oportuno tras atender el review lo destrabó.** | ✅ | — |
| C029 | AMICI-dev/AMICI #918 → [#3235](https://github.com/AMICI-dev/AMICI/pull/3235) | Python/ML-científico (144★) | 🔴 **cerrado sin merge** (dweindl) 2026-09-10 — no por calidad: *"easier for me to pick up directly than to review and iterate on"*, el subsistema MeasurementChannel (con/sin PEtab) tiene mucho contexto tácito difícil de transmitir en review. Lo había telegrafiado ("not that simple, requires more thought"). Código validado localmente estaba correcto. | — | — |
| C030 | jupyter-book/mystmd #2984 → [#3047](https://github.com/jupyter-book/mystmd/pull/3047) | TS/Jupyter-MyST (519★) | 🟡 review (Typst export rompía con glossary refs multi-palabra `<term-x y>` inválido; fix root-cause `label()` (empareja target), no slugify; test que falla sin fix; **verificado end-to-end** (tsc+71 tests+prettier+eslint, bun/turbo); changeset + disclosure IA; **+fix seguridad** escape de comillas tras review) | — | — |
| C031 | mario-eth/soldeer #236 → [#406](https://github.com/mario-eth/soldeer/pull/406) | Rust/Foundry-devtools (393★) | 🟡 review (maintainers lo pidieron: inferir subdir de fuentes `src`/`contracts` en remappings como forge; **restricción de beeb "no permanente" respetada** (el test que añadí cazó un defecto en la preservación → corregido); 161 tests + 2 nuevos verdes) | — | — |
| C032 | Eventual-Inc/Daft #5462 → [#7508](https://github.com/Eventual-Inc/Daft/pull/7508) | Rust+Python/ML-data (5.7k★) | 🟡 review (scouting 2026-09-13: repo que mergea externos en días, IA permitida) — bug: `@daft.func` ignoraba su firma de tipos → error opaco en runtime; fix valida en planning time como las exprs nativas; test que falla sin fix; 224 tests+clippy+ruff verdes. Aprovechó el PR abandonado #5470 (evitó el reorder del optimizer que lo hundió) | — | — |
| C033 | lakehq/sail #325 → [#2580](https://github.com/lakehq/sail/pull/2580) | Rust+Python/Spark-engine (3.4k★) | 🟡 review (scouting 2026-09-13: 31/31 últimos merges de externos) — good-first-issue: nombres de campo duplicados en structs nested; replica `deduplicateFieldNames` de Spark + **restore de nombres originales** vía metadata Arrow (schema físico único, cliente ve originales); tests Rust verdes (los de compat PySpark requieren Spark+servidor vivo → pedí CI) | — | — |
| C034 | marimo-team/marimo #6250 | Python+TS/notebooks (22.7k★) | ⚪ **evaluado → declinado** 2026-09-13 (NO cuenta como enviado): investigado a fondo, la pérdida de timezone es de **Postgres** (descarta el offset al almacenar en UTC), no de marimo; lo pedido es un feature request (config de tz), no un bug. Comentario con el diagnóstico dejado en el issue (aporta sin gastar un PR falso) | — | — |
| C035 | nushell/nushell #19003 → [#19021](https://github.com/nushell/nushell/pull/19021) | Rust/shell-CLI (40.5k★) | 🟡 review (scouting 2026-09-13: mergea externos en minutos) — good-first-issue: el default-error se revirtió (#19008, breaking), así que implementé el **flag opt-in `--fail-if-exists`** que el maintainer fdncred sancionó; error tipo coreutils sin romper el default; 3 tests + clippy/fmt verdes | — | — |
| C036 | foundry-rs/foundry #16812 → [#16841](https://github.com/foundry-rs/foundry/pull/16841) | Rust/EVM-devtools (10.6k★) | 🟢 **MERGEADO** 2026-09-14 — `forge lint --report-unused-suppressions` (spec del maintainer); tracking per-range + 3 integ tests. Scouting Solidity, IA con disclosure | ✅ | — |
| C037 | OpenZeppelin/openzeppelin-contracts #6620 | Solidity/smart-contracts (27.2k★) | ⏸️ **en espera (gated)** 2026-09-13 — fix listo local (helper `MessageHashUtils.domainBytes` + refactor ERC7739 byte-idéntico + tests + changeset), pero el issue del maintainer ernestognw exige un **segundo consumidor** antes de mergear ("a single call-site is not enough"). No abierto para evitar rechazo; se retoma si aparece otro consumidor. Repo pro-IA (tiene CLAUDE.md) | — | — |
| C038 | apache/iggy #4164 → [#4173](https://github.com/apache/iggy/pull/4173) | Rust+PyO3/streaming (4.9k★) | 🟡 review (scouting 2026-09-13: mergea externos a diario, IA permitida) — good-first-issue: el SDK Python de `update_user()` pasaba `default()`; expone `options` kwarg (patrón de `update_stream`); 53 tests + clippy/ruff verdes; DCO | — | — |
| C039 | open-policy-agent/conftest #1396 → [#1425](https://github.com/open-policy-agent/conftest/pull/1425) | Go/policy-as-code (3.3k★) | 🟡 review (scouting 2026-09-13: repo pro-agente, añade AGENTS.md) — SARIF `ruleId` genérico (`main/deny`) → deriva el nombre específico de `properties.query`; golden + unit tests; go test/vet/lint verdes; DCO | — | — |
| C040 | documenso/documenso #3365 | TS/e-signature (15k★) | ⚪ **filtro-0 (no external PRs)** 2026-09-13 (NO cuenta como enviado): fix listo local (fallback de fuente Caveat con Latin-extended, 219 tests) pero el CONTRIBUTING **pausó los PRs externos** por seguridad ("will be closed with a request to open an issue"). Comentario-spec con el diagnóstico dejado en el issue (lo que ellos piden ahora) | — | — |
| C041 | goauthentik/authentik #25476 → [#26111](https://github.com/goauthentik/authentik/pull/26111) | Go+Python/identidad-SSO (25.5k★) | 🟢 **MERGEADO** (BeryJu/Jens Langhammer, fundador) 2026-09-15 — `login_hint` loop "Not You?"; fix en `CancelView`. El fundador adoptó la rama (cleanup/refactor), aprobó y mergeó. **10º merge**; repo nuevo (nicho SSO). Lección: NO force-pushear cuando el maintainer commitea en tu rama | — | — |
| C042 | bevyengine/bevy #25473 | Rust/game-engine (48k★) | ⚪ **no-fix / issue mal caracterizado** 2026-09-13 (NO cuenta como enviado): investigado a fondo — no es el macro `bsn!` sino un overflow del trait-solver de rustc (blanket impl recursivo `IntoIterator for &Res<T>` enmascara el E0283). El "fix macro-local" que asume el label NO resuelve el síntoma (probado). Comentario con la causa raíz dejado para el maintainer | — | — |
| C043 | woodpecker-ci/woodpecker #6849 → [#7141](https://github.com/woodpecker-ci/woodpecker/pull/7141) | Go/CI-CD (7.9k★) | 🟡 review (scouting 2026-09-13: mergea externos el mismo día, dirección endosada por qwerty287) — credenciales de registry `host:port` nunca matcheaban (validación con `url.Parse` vs matcher con `reference.Domain`); valida vía `distribution/reference` (misma lib del matcher); tests que fallan sin el fix; go test/vet/golangci-lint verdes | — | — |
| C044 | topgrade-rs/topgrade #527 → [#2338](https://github.com/topgrade-rs/topgrade/pull/2338) | Rust/CLI-updater (4.5k★) | 🟡 review — toolbx vs openSUSE toolbox (`require_containers_toolbx` vía `toolbox --version`). **#2337 lo cerró un bot por no usar el PR template → reabierto como #2338 con el template lleno** (AI-involvement declarado + magic marker) | — | — |
| C045 | sharkdp/bat #1948 → [#4011](https://github.com/sharkdp/bat/pull/4011) | Rust/devtools (60k★) | 🟡 review (scouting 2026-09-13; doc-fix) — el README ya aclaraba `.tmTheme`, faltaba sincronizar el man page (lo que pidió el maintainer); verificado en el loader (syntect solo acepta `.tmTheme`); `bat.1.in` + CHANGELOG | — | — |
| C046 | alacritty/alacritty #9047 | Rust/terminal (66k★) | ⚪ **filtro-0 (anti-LLM en PR template)** 2026-09-13 (NO cuenta como enviado): fix listo local (min window size incluye padding, causa endosada por chrisduerr) pero el **PR template exige afirmar "No LLMs were used"** — no se puede firmar con honestidad usando IA. No abierto. Lección: revisar el PR template, no solo el CONTRIBUTING | — | — |
| C047 | astral-sh/ruff #28551 → [#28600](https://github.com/astral-sh/ruff/pull/28600) | Rust/Python-tooling (49.6k★) | 🔴 **cerrado por duplicado** (MichaReiser) 2026-09-15 — "Duplicate of #28571". Fix correcto (247 tests + clippy verdes) pero otro PR ya cubría el issue. **Lección: en repos hiperactivos verificar PRs abiertos/vinculados antes de codear, no solo el assignee del issue** | — | — |
| C048 | astral-sh/ruff #28011 → [#28601](https://github.com/astral-sh/ruff/pull/28601) | Rust/Python-tooling (49.6k★) | 🔴 **cerrado por duplicado** (MichaReiser) 2026-09-15 — "Duplicate of #28051" (PR previo ya existente). Fix correcto (83 tests + clippy verdes, snapshot preview) pero llegamos tarde. Misma lección de selección que C047 | — | — |

> ✅ **Nota de reputación:** **7 merges reales en 7 repos distintos** (~73k★ combinadas) — servo #496 (servo
> **veta IA**, vetado), **airi #2408** (48.5k★), **boa #5500** (7.5k★, motor JS en Rust), **onefetch #1853**
> (12k★), **tract #2749** (3k★, motor de inferencia ML de Sonos), **findutils #857** y **diplomat #1269**
> (901★, FFI). **34 PRs**, todos con política de IA verificada (filtro 0) y cada review atendido. Los 4 merges
> nuevos (07→09 sep) cerraron tras atender review a fondo: tract/onefetch por rework de review, findutils por el
> test pedido, **diplomat por un ping oportuno**.
>
> ✅ **Aceptación 41%** (7/17 resueltos). Los **10 cierres**, uno por uno, **ninguno por calidad del código**:
> - **airi #2413** — feature `needs-more-info` declinada por el maintainer.
> - **airi #2422** — cerrada como **"Duplicated"** por @nekomeowww.
> - **airi #2412** — fix correcto, **cerrado por el accionista** al no lograr un demo/GIF fiel (Electron).
> - **openai #4774** — @seratch: **duplicaba su rediseño** abierto #4738 + carrera de ownership.
> - **scikit-image #8306** y **servo #500** — **política anti-IA** del repo.
> - **AMICI #3235** — dweindl **prefiere tomarlo él** por el contexto tácito del subsistema MeasurementChannel.
> - **nannou #1096** — **cierre de foco propio**: repo inactivo ~2 meses (0 merges, sin review), maintainer ausente.
> - **yq #2849** — **cierre de foco propio**: mikefarah acumula PRs externos sin merge (baja P(merge) estructural).
>
> Los 3 últimos (AMICI/nannou/yq) son de **selección**, no de ejecución → el ajuste va en el filtro de SOUL §5.
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

## Galaxy Brain 🧠 (Discussions — accepted answers)

> Achievement independiente de Pull Shark: requiere **2 respuestas aceptadas** en
> GitHub Discussions (categorías *answerable*). North Star propio = respuestas
> aceptadas ÷ publicadas. **Aprendizajes clave:** (1) las preguntas con respuesta
> canónica se responden en horas por otros; hay que llegar primero. (2) Los repos
> **gigantes** (fastapi/next/pydantic) están **saturados de answer-farmers** (ventana
> de 0-2h, imposible de cazar en sesión puntual). (3) **La estrategia que funciona:**
> repos **medianos de nicho** (~1.5k-25k⭐, p.ej. sqlx/egui) con Q&A activas pero SIN
> farmers, donde una pregunta técnica puede quedar **días/meses sin responder** y una
> respuesta correcta tiene alta chance de aceptación.

| ID | Repo #discussion | Nicho | Estado | Aceptada? |
|---|---|---|---|---|
| G001 | [supabase #50335](https://github.com/supabase/supabase/discussions/50335#discussioncomment-18435346) | Postgres/pg_net (⭐~80k) | 🟡 publicada 2026-09-14 (1er comentario, 0 previos) — por qué el `REVOKE` de `net` no hace nada: `postgres` no es el grantor (owner=`supabase_admin`) + `ON SCHEMA` no cubre el `SELECT` de las tablas + upgrades re-aplican grants; recomendación: no guardar el token en la cola, resolverlo en runtime. Confianza alta en la mecánica | — |
| G002 | [supabase #50325](https://github.com/supabase/supabase/discussions/50325#discussioncomment-18435347) | Postgres/PostGIS (⭐~80k) | 🟡 publicada 2026-09-14 (1er comentario, 0 previos) — TEMP heredado de `PUBLIC` (revoke solo a nivel DB, riesgoso en hosted) + PostGIS `st_estimatedextent` SECURITY DEFINER (no revocable durablemente como `postgres`, upgrade re-aplica). Honesta sobre el límite del hosting; confianza media | — |
| G003 | [sqlx #4325](https://github.com/transact-rs/sqlx/discussions/4325#discussioncomment-18442131) | Rust/DB (⭐~15k) | 🟢 **ACEPTADA** 2026-09-15 07:19 — no hay API de duración en sqlx (solo logs/tracing); mídela con `Instant`; para tiempo server-side puro `EXPLAIN ANALYZE` | ✅ |
| G004 | [sqlx #4405](https://github.com/transact-rs/sqlx/discussions/4405#discussioncomment-18442132) | Rust/DB (⭐~15k) | 🟡 publicada 2026-09-15 (1er comentario) — `fetch()` es lazy a nivel API (1 `Row` a la vez) vs `fetch_all()`=Vec; **gotcha:** sqlx no abre cursor server-side, PG envía todo el resultset → pico de memoria puede acercarse al total; para cota dura usar `DECLARE ... CURSOR`. Confianza alta | — |
| G005 | [sqlx #4232](https://github.com/transact-rs/sqlx/discussions/4232#discussioncomment-18442133) | Rust/DB (⭐~15k) | 🟢 **ACEPTADA** 2026-09-15 06:50 — no hay switch propio; `#[sqlx::test]` expande a `#[test]` normal → filtrado libtest (`cargo test -- --skip`) o feature-gate del módulo (`#[cfg(feature="db-tests")]`) | ✅ |
| G006 | [egui #8091](https://github.com/emilk/egui/discussions/8091#discussioncomment-18442134) | Rust/GUI (⭐~24k) | 🟡 publicada 2026-09-15 (1er comentario) — double-borrow de `style_ui` vía Deref: sacar el contexto a su binding (`let ctx = ui.ctx().clone(); ctx.style_ui(ui, ...)`), `Context` es `Arc` barato. Confianza alta | — |

> **Estado:** 🧠 **ACHIEVEMENT CONSEGUIDO 2026-09-15** — **2/6 aceptadas** (G003 sqlx #4325 +
> G005 sqlx #4232, ambas aceptadas el mismo día por sus autores). Las 4 restantes (supabase
> ×2, sqlx #4405, egui #8091) siguen publicadas sin aceptar (bonus si caen).
> **Validación de la estrategia:** las 2 aceptadas fueron en **sqlx** (repo mediano de nicho,
> sin answer-farmers) — exactamente la hipótesis del pivote. Las de repos gigantes/policy
> (supabase) no cayeron. Para futuros achievements de Q&A: repos medianos de nicho, primero en llegar.

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
| 2026-09-03 | 🧹 **Día de saneamiento de la cartera** (sin PRs nuevos): rebase de coreutils(+64)/rustpython(+28)/git-cliff → **CI verde** (limpia flaky/infra/CodSpeed); **AMICI #3235 validado localmente** (build C++ + BNG, 3 tests pysb ✓); **sktime #10967** bug real de Evilander corregido; **image #3107** cargo-deny resuelto (skip `deny.toml`); **RustPython #8610 en cumplimiento AI policy**; **diplomat #1269** test pedido añadido. 🔴 **airi #2412 cerrado por autor** (demo/GIF no fiel). | 3 |
| 2026-09-05→07 | 🔧 **Ronda profunda de reviews atendidos:** soldeer·beeb (el fix superficial de expected values no bastó → **fix de lógica real**: inferir sufijo `src/` solo en install, no en update; los tests de regresión del maintainer lo destaparon); RustPython·youknowone (respuesta **en primera persona**, no IA, + drop de fn muerta); **git-cliff·orhun rehecho a 1 commit** (rebase, drop de lint no relacionado, **2º fixture para el caso relativo de #1369**); tract·czoli (scale no unitario + corrección del bias); AMICI/sktime/findutils con pings/comentarios. **delta #3250 rebasado** (BEHIND→0). | 3 |
| 2026-09-08 | 🟢🟢 **4º y 5º MERGE:** [onefetch #1853](https://github.com/o2sh/onefetch/pull/1853) (o2sh — reftable bail; **el fix del CI fue alinear el mensaje del test con el de gitoxide**, `--force-with-lease` evitó pisar un commit de spenserblack) + [tract #2749](https://github.com/sonos/tract/pull/2749) (kali — RMS norm). **Ping a tyler (diplomat)**, **8 nudges** a PRs con ≥7 días sin review. | **5** |
| 2026-09-09 | 🟢🟢 **6º y 7º MERGE:** [findutils #857](https://github.com/uutils/findutils/pull/857) (cakebaker) + [diplomat #1269](https://github.com/rust-diplomat/diplomat/pull/1269) (tyler — **el ping oportuno lo cerró**). **Tasa de aceptación 50%** (meta alcanzada). **sed #544:** test unitario in-process para recuperar `codecov/project` (codecov no cuenta cobertura de subprocesos/integración). | **7** |
| 2026-09-10 | ✅ **sed #544 codecov → verde** (el unit test in-process funcionó). 🔴 **AMICI #3235 cerrado** por dweindl — no por calidad: prefiere tomarlo él por el contexto tácito de MeasurementChannel (con/sin PEtab). Tasa 50%→**47%** (7/15). Lección de selección → SOUL §5 (issues en subsistemas *entangled* con "requires more thought" = baja P(merge) para externos). | **7** |
| 2026-09-12 | 🔧 **2 rounds de review profundos atendidos:** RustPython·youknowone (aplicar patrón de `pop` a `setdefault` + quitar `setdefault_entry` muerta) y **soldeer·beeb (review de 5 puntos)** — mi enfoque previo (sufijo solo en `Add`) era el bug; movida la inferencia al path compartido + heurístico endurecido (`.sol` real + case del dir). 🧹 **Poda de cartera:** cerrados **nannou #1096** (repo dormido ~2m) y **yq #2849** (mikefarah no mergea externos) por foco. Tasa **41%** (7/17). | **7** |
| 2026-09-13 | ✅ **delta #3250 APROBADO** por chiinlquah (el nudge lo destrabó) — 2 nits atendidos (tests de borde + PR body). 🎯 **Scouting + 3 issues en paralelo en repos nuevos** (>2k★, mergean externos, feedback rápido): 2 PRs abiertos — **Daft [#7508](https://github.com/Eventual-Inc/Daft/pull/7508)** (validación de firma `@daft.func`) y **sail [#2580](https://github.com/lakehq/sail/pull/2580)** (nombres duplicados nested); **marimo #6250 declinado** (tz es de Postgres, no de marimo) con comentario-diagnóstico. 2ª ronda de scouting → **nushell [#19021](https://github.com/nushell/nushell/pull/19021)** (flag `--fail-if-exists`, sancionado por el maintainer). **polars descartado (Filtro Cero): cierra PRs de agentes** ("Agents aren't allowed to make PRs") — verificar veto anti-agente *de facto*, no solo el CONTRIBUTING. Enviados 34→37; en review 20. | **7** |
| 2026-09-13 | 🎯 **3ª ronda de scouting (foco Solidity/EVM):** PR **foundry [#16841](https://github.com/foundry-rs/foundry/pull/16841)** (`forge lint --report-unused-suppressions`, spec del maintainer, con disclosure IA). **OZ #6620 en espera**: fix listo pero el maintainer lo tiene *gated* hasta un 2º consumidor del helper. **viem descartado** (cierra fixes de externos sin merge; CONTRIBUTING "humans, not bots"). Enviados 37→38; en review 21. | **7** |
| 2026-09-13 | 🟢 **8º MERGE: git-cliff [#1627](https://github.com/orhun/git-cliff/pull/1627)** (orhun) — cerró el ciclo tras el review (1 commit limpio + fixture del caso relativo #1369). 🔧 **Daft #7508**: CI `style`/mypy en rojo → arreglado (los `@overload` de `__call__` debían quedar pegados a la impl; el helper nuevo se había colado en medio); mypy del repo verde local. Pull Shark **8/16**. | **8** |
| 2026-09-13 | 🎯 **4ª ronda de scouting (diversificación):** 2 PRs — **iggy [#4173](https://github.com/apache/iggy/pull/4173)** (SDK Python, Rust/streaming) y **conftest [#1425](https://github.com/open-policy-agent/conftest/pull/1425)** (SARIF ruleId, Go/policy). **documenso filtro-0** (pausó PRs externos por seguridad) → dejé comentario-spec en #3365. Filtro acumulado: 5 vetos atrapados (marimo/polars/viem/documenso/OZ) antes de gastar PR. Enviados 38→40; en review 22. | **8** |
| 2026-09-13 | 🎯 **5ª ronda de scouting:** PR **goauthentik [#26111](https://github.com/goauthentik/authentik/pull/26111)** (bug confirmado `login_hint` loop; Go+Python/SSO — nicho nuevo). **bevy #25473 no-fix**: investigado, el issue está mal caracterizado (no es el macro sino un overflow del trait-solver de rustc) → comentario con la causa raíz para el maintainer. Enviados 40→41; en review 23. | **8** |
| 2026-09-13 | 🎯 **6ª-7ª ronda de scouting:** 3 PRs — **woodpecker [#7141](https://github.com/woodpecker-ci/woodpecker/pull/7141)** (registry host:port, Go/CI), **topgrade [#2337](https://github.com/topgrade-rs/topgrade/pull/2337)** (toolbx vs openSUSE, Rust/CLI), **bat [#4011](https://github.com/sharkdp/bat/pull/4011)** (doc-sync man page). **alacritty filtro-0**: fix listo pero su PR template exige afirmar "No LLMs were used" → no se puede firmar con honestidad. Filtro acumulado: ~7 vetos atrapados. Enviados 41→44; en review 26. | **8** |
| 2026-09-14 | 🟢 **9º MERGE: foundry [#16841](https://github.com/foundry-rs/foundry/pull/16841)** (forge lint unused-suppressions). 🟢 **goauthentik #26111 adoptado por el fundador** (Jens Langhammer commitea en la rama + aprueba → merge #10 encaminado; NO force-push). 🔧 **topgrade** reabierto como [#2338](https://github.com/topgrade-rs/topgrade/pull/2338) (un bot cerró #2337 por falta de PR template). 🔧 **bat #4011** CI arreglado (el changelog debe citar el nº del PR). Pull Shark **9/16**. | **9** |
| 2026-09-14 | 🧠 **Galaxy Brain — 1ers intentos:** 2 respuestas publicadas en Discussions de **supabase** (Postgres): [#50335](https://github.com/supabase/supabase/discussions/50335) (pg_net queue ACLs) y [#50325](https://github.com/supabase/supabase/discussions/50325) (PUBLIC TEMP + PostGIS SECURITY DEFINER), ambas como 1er comentario en preguntas frescas sin responder. **Aprendizaje:** el scouting de snapshot de Q&A no sirve (las buenas ya están respondidas por otros); la ventana es pregunta <48h aún sin respuesta. Sequía de matches limpios (el pool fresco es bug reports/spam). 0/2 aceptadas aún (depende de los autores). | **9** |
| 2026-09-15 | 🟢 **10º MERGE: goauthentik [#26111](https://github.com/goauthentik/authentik/pull/26111)** (BeryJu/Jens Langhammer, fundador) — `login_hint` loop; repo nuevo (SSO). Pull Shark **10/16**. 🧠 **GALAXY BRAIN CONSEGUIDO** (2 accepted answers: sqlx #4232 + #4325 — validó el pivote a repos medianos de nicho). 🔴 **ruff #28600/#28601 cerrados por duplicado** (MichaReiser: #28571/#28051 ya existían) → lección: verificar PRs abiertos/vinculados antes de codear en repos hiperactivos. 🟡 **nushell #19021**: respondido a fdncred (caso de uso: paridad POSIX + colisiones). 🟢 **aeon #3773**: MatthewMiddlehurst "seems fine and simple", espera a baraline. | **10** |
| 2026-09-15 | 🎯 **8ª ronda de scouting (repo pro-IA):** 2 PRs en **astral-sh/ruff** (49.6k★, trae skills de Claude Code/Codex → Filtro Cero PASS máximo, mergea externos a diario): **[#28600](https://github.com/astral-sh/ruff/pull/28600)** (nombres de regla en warnings del formatter, C047) y **[#28601](https://github.com/astral-sh/ruff/pull/28601)** (exec-builtin marca referencias, C048). Ambos con tests+clippy verdes, snapshots insta, disclosure IA. También rebase de nushell #19021 + coreutils #14264 (CONFLICTING→MERGEABLE). Enviados 44→46; en review 27. | **9** |
| 2026-09-15 | 🧠 **Galaxy Brain — 2º lote (pivote de estrategia):** los repos gigantes están saturados de answer-farmers → pivote a **repos medianos de nicho sin farmers**. 4 respuestas publicadas (1er comentario, preguntas sin responder desde hace días/meses): **[sqlx #4325](https://github.com/transact-rs/sqlx/discussions/4325)** (duración de query), **[sqlx #4405](https://github.com/transact-rs/sqlx/discussions/4405)** (memoria de `fetch`, gotcha cursor PG), **[sqlx #4232](https://github.com/transact-rs/sqlx/discussions/4232)** (skip sqlx::test), **[egui #8091](https://github.com/emilk/egui/discussions/8091)** (borrow de `style_ui`). Todas confianza alta. Galaxy Brain: 6 publicadas, 0 aceptadas aún. | **9** |

## Notas

- Gate F0: lograr **≥1 PR mergeado** en repo sano en ≤2 semanas. Si en 5 PRs no
  cae ninguno → revisar selección (SOUL §5), no meter más horas a ciegas.
- **Higiene = regla dura:** ningún PR sale con secretos ni deps vulnerables. Lo
  bloquea `tools/pre_submit.sh`.
- Pendiente humano: revocar OAuth de Algora y limpiar accesos en el GitHub del
  accionista (`github.com/settings/applications`).
