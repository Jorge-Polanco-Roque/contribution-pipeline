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
| [RustPython/RustPython #8610](https://github.com/RustPython/RustPython/pull/8610) | `RustPython/RustPython` | Give dict a CPython-style message for unhashable keys | 🟡 abierto |
| [uutils/sed #544](https://github.com/uutils/sed/pull/544) | `uutils/sed` | Implement GNU R (read one line from file) command | 🟡 abierto |
| [servo/rust-smallvec #500](https://github.com/servo/rust-smallvec/pull/500) | `servo/rust-smallvec` | Add try_with_capacity fallible constructor | 🔴 cerrado |
| [servo/rust-smallvec #496](https://github.com/servo/rust-smallvec/pull/496) | `servo/rust-smallvec` | Implement arbitrary::Arbitrary for SmallVec | 🟢 mergeado |

<sub>Actualizado automáticamente: 2026-08-30 (workflow semanal).</sub>
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
