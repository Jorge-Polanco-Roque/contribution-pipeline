<div align="center">

# contribution-pipeline

**Un gate de calidad + seguridad *diff-aware* de primer nivel para contribuciones open-source,
validado por un arena de simulación de dos agentes.**

`bash · sin dependencias propias` &nbsp;•&nbsp; `seguridad diff-aware` &nbsp;•&nbsp; `12/12 rondas mergeadas` &nbsp;•&nbsp; `0 falsos verdes`

</div>

---

## En una frase

Cada cambio que sale bajo la cuenta del accionista debe ser **indistinguible del trabajo de un
maintainer del propio repo** — en estilo, calidad, pruebas y seguridad. Este repo contiene la
máquina que lo garantiza *antes* de que un humano mire el PR, y el banco de pruebas que la endurece.

Dos piezas:

| Pieza | Qué es |
|---|---|
| **El gate** (`tools/`) | Corre los checks del repo objetivo + una capa fina de invariantes (secretos, deps vulnerables, patrones riesgosos) **solo sobre lo que introduce el diff**. |
| **El arena** (`arena/`) | Simulación cerrada y medible: un agente *levanta issues* con defectos verificables, otro los *resuelve* con PRs — para probar el pipeline end-to-end. |

---

## Tesis de diseño

El error de junior es imponer un pipeline genérico y estricto a repos ajenos. Aquí se hace lo
contrario:

- **El repo objetivo manda.** El gate corre *sus* checks (`make test`, `.pre-commit`, su CI), no los nuestros.
- **Seguridad *diff-aware*.** Bloquea solo lo que introduce *nuestro* diff, nunca la deuda pre-existente del repo.
- **Fail-closed en secretos.** Un secreto siempre bloquea, sin excepción.
- **Menos código propio.** Delegar en la herramienta que ya vive en el repo (filosofía *ponytail*).

---

## El gate de calidad + seguridad — `tools/pre_submit.sh`

Autodetecta el stack y da luz verde solo si **todo** pasa.

| Etapa | Qué corre | Comportamiento |
|---|---|---|
| Formato · Lint · Build · Tests | el tooling del repo (`cargo`/`go`/`ruff`/`npm`…) | reproduce su CI |
| 🔐 Secretos | `gitleaks` (+ fallback grep) | **siempre bloquea** |
| 🔐 Dependencias (SCA) | `cargo-audit`/`pip-audit`/`govulncheck`/`npm audit` | bloquea **solo si el diff toca manifiestos/lockfiles** |
| 🔐 SAST | `semgrep --baseline-commit <base>` | bloquea **solo hallazgos nuevos** vs la base |

```bash
bash tools/bootstrap.sh                 # Fase 0: instala/verifica el tooling de seguridad
bash tools/pre_submit.sh <ruta_repo>    # gate completo (calidad + seguridad diff-aware)
bash tools/pre_submit.sh --security <r> # solo la etapa de seguridad
bash tools/pre_submit.sh --check        # self-test de detección de stack
```

> La deuda pre-existente del repo **no** bloquea (solo informa); lo que introduces, **sí**.
> Verificado con una vulnerabilidad real (`RUSTSEC-2020-0071`) en ambas direcciones.

---

## El arena — simulación de dos agentes

Un ciclo cerrado y *auto-verificable*: el Reporter siembra un defecto con un **hidden test**
(oráculo) fuera del alcance del Contributor; el fix se valida objetivamente — el oráculo debe
**fallar antes** y **pasar después**.

```
Agent A (Reporter)          referee            Agent B (Contributor)         referee
──────────────────    ───────────────────    ─────────────────────    ────────────────────────
levanta issue #N  ─▶  oráculo FALLA en main  ─▶  recon → fix → GATE  ─▶  oráculo PASA + CI + merge
+ hidden test         + worktree aislado         → PR "Fixes #N"          → issue cerrado + score
```

- **Aislamiento estructural:** el Contributor trabaja en un `git worktree` sin ningún puntero al oráculo.
- **Triaje:** resuelve issues válidos y **declina** los inválidos (issues-trampa) con justificación.
- **Paralelismo:** N Contributors concurrentes (un worktree cada uno) para issues en archivos disjuntos.

### Tres formas de correr una ronda

```bash
# 1) Semi-automática (referee automatizado, agentes manuales)
bash arena/run.sh prep-parallel <slug1> <slug2> ...
#   → N sub-agentes Contributor en paralelo (uno por worktree)
bash arena/run.sh finalize-parallel <slug1:issue:pr> <slug2:issue:pr> ...

# 2) Un solo comando (Workflow que orquesta seed → prep → fix∥ → finalize)
Workflow({ name: 'arena-round', args: { n: 3 } })
```

`run.sh` automatiza todo lo determinista (ground-truth del oráculo, worktrees, CI, merge,
**no-regresión cruzada**, `score.json`); los agentes son el único razonamiento.

---

## Estructura del repositorio

```
SOUL.md            estrategia (qué contribuir, cuándo parar)
CLAUDE.md          operación (pipeline, criterios, Plan maestro)
DASHBOARD.md       KPIs (North Star: tasa de aceptación de PRs)
LEARNINGS.md       ledger vivo: qué salió bien/mal + causa raíz + regla
tools/
  pre_submit.sh    gate calidad + seguridad diff-aware
  bootstrap.sh     instala el tooling de seguridad (Fase 0)
pipeline-lab/      banco de no-regresión del gate (fixtures efímeros)
arena/
  PLAN.md          plan ultradetallado de la simulación
  run.sh           harness: rondas simple y paralela + scoring
  agents/          contratos de Reporter y Contributor
  catalog/         casos seeded (bug + hidden test) por slug
  rounds/          artefactos por ronda (issue/review/score.json)
  SCOREBOARD.md    agregado de rondas
.claude/workflows/arena-round.js   el Workflow one-command
playbook/quality-gate.md           proceso obligatorio antes de un PR
```

---

## Contribuciones reales

PRs bajo la cuenta del accionista (`Jorge-Polanco-Roque`) — estado **actualizado automáticamente** cada lunes:

<!-- PRS:START -->
| PR | Repo | Cambio | Estado |
|---|---|---|---|
| [bootc-dev/bootc #2467](https://github.com/bootc-dev/bootc/pull/2467) | `bootc-dev/bootc` | feat(switch): add --target-imgref to decouple pull source from upgrade origin | 🟡 abierto |
| [rerun-io/rerun #12933](https://github.com/rerun-io/rerun/pull/12933) | `rerun-io/rerun` | Keep DebugLabels in release builds but ignore them for resource pooling | 🟡 abierto |
| [typescript-eslint/typescript-eslint #12890](https://github.com/typescript-eslint/typescript-eslint/pull/12890) | `typescript-eslint/typescript-eslint` | fix(ast-spec): narrow ImportAttribute key and value to StringLiteral | 🔴 cerrado |
| [cupy/cupy #10308](https://github.com/cupy/cupy/pull/10308) | `cupy/cupy` | Fix convolve/correlate method="direct" with non-contiguous in1 | 🔴 cerrado |
| [zalando/skipper #4267](https://github.com/zalando/skipper/pull/4267) | `zalando/skipper` | test: wait for OPA instance readiness in TestServerResponseFilter | 🟢 mergeado |
| [astral-sh/ruff #28601](https://github.com/astral-sh/ruff/pull/28601) | `astral-sh/ruff` | [flake8-bandit] Flag references to `exec` (S102) | 🔴 cerrado |
| [astral-sh/ruff #28600](https://github.com/astral-sh/ruff/pull/28600) | `astral-sh/ruff` | Show rule names alongside codes in formatter incompatibility warnings | 🔴 cerrado |
| [topgrade-rs/topgrade #2338](https://github.com/topgrade-rs/topgrade/pull/2338) | `topgrade-rs/topgrade` | fix(toolbx): don't mistake openSUSE's toolbox for containers toolbx | 🔴 cerrado |
| [sharkdp/bat #4011](https://github.com/sharkdp/bat/pull/4011) | `sharkdp/bat` | docs: clarify supported custom theme format in the man page | 🟡 abierto |
| [topgrade-rs/topgrade #2337](https://github.com/topgrade-rs/topgrade/pull/2337) | `topgrade-rs/topgrade` | fix(toolbx): don't mistake openSUSE's toolbox for containers toolbx | 🔴 cerrado |
| [woodpecker-ci/woodpecker #7141](https://github.com/woodpecker-ci/woodpecker/pull/7141) | `woodpecker-ci/woodpecker` | fix(server): accept host:port registry addresses so credentials can match | 🔴 cerrado |
| [goauthentik/authentik #26111](https://github.com/goauthentik/authentik/pull/26111) | `goauthentik/authentik` | flows: strip login_hint from next on cancel to prevent loop | 🟢 mergeado |
| [open-policy-agent/conftest #1425](https://github.com/open-policy-agent/conftest/pull/1425) | `open-policy-agent/conftest` | fix(sarif): use specific rule names in SARIF ruleId | 🟡 abierto |
| [apache/iggy #4173](https://github.com/apache/iggy/pull/4173) | `apache/iggy` | feat(python): expose update_user options | 🟢 mergeado |
| [foundry-rs/foundry #16841](https://github.com/foundry-rs/foundry/pull/16841) | `foundry-rs/foundry` | feat(lint): report unused inline suppressions | 🟢 mergeado |
| [nushell/nushell #19021](https://github.com/nushell/nushell/pull/19021) | `nushell/nushell` | feat(mkdir): add --fail-if-exists flag to error on existing directory | 🟢 mergeado |
| [lakehq/sail #2580](https://github.com/lakehq/sail/pull/2580) | `lakehq/sail` | feat: support duplicated field names in nested Spark struct schemas | 🔴 cerrado |
| [Eventual-Inc/Daft #7508](https://github.com/Eventual-Inc/Daft/pull/7508) | `Eventual-Inc/Daft` | fix: validate @daft.func input types at planning time | 🟡 abierto |
| [mario-eth/soldeer #406](https://github.com/mario-eth/soldeer/pull/406) | `mario-eth/soldeer` | feat(remappings): infer source directory suffix like forge | 🟡 abierto |
| [jupyter-book/mystmd #3047](https://github.com/jupyter-book/mystmd/pull/3047) | `jupyter-book/mystmd` | fix(myst-to-typst): use label() for cross-references whose identifier has spaces | 🟢 mergeado |
| [AMICI-dev/AMICI #3235](https://github.com/AMICI-dev/AMICI/pull/3235) | `AMICI-dev/AMICI` | Warn about observation-model observables absent from the PySB model | 🔴 cerrado |
| [rust-diplomat/diplomat #1269](https://github.com/rust-diplomat/diplomat/pull/1269) | `rust-diplomat/diplomat` | fix: reject None in the nanobind char32_t caster instead of crashing | 🟢 mergeado |
| [delta-io/delta-kernel-rs #3250](https://github.com/delta-io/delta-kernel-rs/pull/3250) | `delta-io/delta-kernel-rs` | fix: sign-extend negative decimal statistics in row-group skipping | 🟢 mergeado |
| [orhun/git-cliff #1627](https://github.com/orhun/git-cliff/pull/1627) | `orhun/git-cliff` | fix(args): resolve --workdir to a repo-relative include path | 🟢 mergeado |
| [charmbracelet/gum #1141](https://github.com/charmbracelet/gum/pull/1141) | `charmbracelet/gum` | fix(format): wrap markdown tables to terminal width | 🟡 abierto |
| [mikefarah/yq #2849](https://github.com/mikefarah/yq/pull/2849) | `mikefarah/yq` | Preserve file permissions on in-place edits | 🔴 cerrado |
| [jqlang/jq #3623](https://github.com/jqlang/jq/pull/3623) | `jqlang/jq` | Fix inconsistent `delpaths` behavior with mixed negative indices | 🟡 abierto |
| [o2sh/onefetch #1853](https://github.com/o2sh/onefetch/pull/1853) | `o2sh/onefetch` | Suggest reftable migration when HEAD can't be read | 🟢 mergeado |
| [sharkdp/numbat #888](https://github.com/sharkdp/numbat/pull/888) | `sharkdp/numbat` | Load currency units on demand for `info` and `list` commands | 🟡 abierto |
| [uutils/findutils #857](https://github.com/uutils/findutils/pull/857) | `uutils/findutils` | fix(find): output nothing when -mindepth exceeds -maxdepth | 🟢 mergeado |
| [moeru-ai/airi #2422](https://github.com/moeru-ai/airi/pull/2422) | `moeru-ai/airi` | fix(stage-tamagotchi): clamp restored main-window bounds onto an available display | 🔴 cerrado |
| [moeru-ai/airi #2415](https://github.com/moeru-ai/airi/pull/2415) | `moeru-ai/airi` | fix(stage-ui): deliver sends issued during the transport prepare phase | 🟡 abierto |
| [moeru-ai/airi #2414](https://github.com/moeru-ai/airi/pull/2414) | `moeru-ai/airi` | fix(pipelines-audio): preserve multi-code-unit grapheme clusters in TTS chunking | 🟡 abierto |
| [moeru-ai/airi #2413](https://github.com/moeru-ai/airi/pull/2413) | `moeru-ai/airi` | feat(stage-ui): support separate display text and TTS pronunciation via ruby annotations | 🔴 cerrado |
| [scikit-image/scikit-image #8306](https://github.com/scikit-image/scikit-image/pull/8306) | `scikit-image/scikit-image` | Fix pyramid_laplacian to build a reconstructable Laplacian pyramid | 🔴 cerrado |
| [Nixtla/statsforecast #1225](https://github.com/Nixtla/statsforecast/pull/1225) | `Nixtla/statsforecast` | docs: document both ConformalSeasonalPool interval thresholds and validate n_samples | 🟡 abierto |
| [aeon-toolkit/aeon #3773](https://github.com/aeon-toolkit/aeon/pull/3773) | `aeon-toolkit/aeon` | [BUG] Preserve input dtype in shift_scale_invariant zero-padding | 🟡 abierto |
| [sktime/sktime #10967](https://github.com/sktime/sktime/pull/10967) | `sktime/sktime` | [BUG] Fix get_slice handling of zero and omitted bounds | 🟡 abierto |
| [sonos/tract #2749](https://github.com/sonos/tract/pull/2749) | `sonos/tract` | onnx: lower SimplifiedLayerNormalization to RMS norm, not LayerNorm | 🟢 mergeado |
| [nannou-org/nannou #1096](https://github.com/nannou-org/nannou/pull/1096) | `nannou-org/nannou` | fix(draw): close the ellipse outline path so strokes don't leave a gap | 🔴 cerrado |
| [image-rs/image #3107](https://github.com/image-rs/image/pull/3107) | `image-rs/image` | fix(imageops): premultiply alpha in blur to prevent color bleed | 🟡 abierto |
| [boa-dev/boa #5500](https://github.com/boa-dev/boa/pull/5500) | `boa-dev/boa` | fix(ast): quote non-identifier object property keys in interned output | 🟢 mergeado |
| [microlinkhq/unavatar #660](https://github.com/microlinkhq/unavatar/pull/660) | `microlinkhq/unavatar` | feat(providers): add Kick avatar provider | 🔴 cerrado |
| [moeru-ai/airi #2412](https://github.com/moeru-ai/airi/pull/2412) | `moeru-ai/airi` | fix(stage-tamagotchi): keep expanded controls island reachable on small windows | 🔴 cerrado |
| [openai/openai-agents-python #4774](https://github.com/openai/openai-agents-python/pull/4774) | `openai/openai-agents-python` | fix(sandbox): don't corrupt a UTF-8 char split across PTY windows | 🔴 cerrado |
| [uutils/coreutils #14264](https://github.com/uutils/coreutils/pull/14264) | `uutils/coreutils` | ls: honor LC_NUMERIC for the -h decimal separator | 🟡 abierto |
| [moeru-ai/airi #2408](https://github.com/moeru-ai/airi/pull/2408) | `moeru-ai/airi` | fix(better-ws): publish the package so server-sdk installs | 🟢 mergeado |
| [Automattic/harper #4253](https://github.com/Automattic/harper/pull/4253) | `Automattic/harper` | Add a linter for confusing `wary` and `weary` | 🟡 abierto |

<sub>Actualizado automáticamente: 2026-09-21 (workflow semanal).</sub>
<!-- PRS:END -->

> Detalle por contribución en [`contributions/`](contributions/). Selección + pre-lanzamiento en [`LAUNCH-PLAN.md`](LAUNCH-PLAN.md).

---

## Resultados del arena (simulación)

| Métrica | Valor |
|---|---|
| Bugs reales sembrados y **mergeados** | **12 / 12** |
| Gate verde a la primera | **12 / 12** |
| Issues-trampa **declinados** correctamente | **1 / 1** |
| Falsos verdes de seguridad | **0** |
| Secretos introducidos | **0** |

Rondas probadas de 1 issue secuencial → 3 en paralelo (worktrees) → **una ronda entera en un comando**.
Detalle en [`arena/SCOREBOARD.md`](arena/SCOREBOARD.md); aprendizajes en [`LEARNINGS.md`](LEARNINGS.md).

---

## Licencia

[MIT](LICENSE) © 2026 Jorge Polanco

<div align="center">
<sub>Repositorio privado · el sandbox de pruebas vive aparte en <code>Testing_Pipelines</code>.</sub>
</div>
