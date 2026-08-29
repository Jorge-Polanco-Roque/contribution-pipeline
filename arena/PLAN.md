# arena/PLAN.md — Simulación de dos agentes (Reporter ⇄ Contributor)

> Ejercicio **end-to-end** del pipeline completo (recon → código → gate → PR →
> review → merge) en un repo real, como un ciclo cerrado y **medible**. Dos agentes
> con contratos separados interactúan; de cada ronda salen métricas y aprendizajes
> que endurecen el pipeline. Es el test de integración del `Plan maestro` (CLAUDE.md).

---

## 0. Propósito y no-propósito

- **Propósito:** probar el pipeline de punta a punta con evidencia objetiva, en un
  ciclo repetible, y acumular aprendizajes que retroalimenten `SOUL`/`CLAUDE`/gate.
- **No-propósito:** NO es para inflar contribuciones falsas ni ensuciar el GitHub
  real de Jorge con ruido. La simulación vive en un **repo sandbox designado**.
  La reputación real se construye *después*, con el pipeline ya probado aquí.

## 1. Los agentes (roles y contratos)

### Agent A — Reporter ("el que levanta issues")
- **Misión:** simular la demanda. Genera issues realistas y accionables.
- **Entrada:** el código del repo + `arena/catalog/` (arquetipos de defecto).
- **Salida:** issue con título, síntoma, pasos de reproducción y **criterio de
  aceptación explícito**. Vía `gh issue create` (GitHub-mode) o `rounds/NNN/issue.md`.
- **Dos tipos de issue:**
  - **Seeded (verificable):** A introduce un defecto conocido y esconde un **test de
    aceptación** (fuera del alcance de B). Ground truth = ese test. El issue describe
    el *síntoma*, nunca el fix.
  - **Organic (realista):** A detecta una mejora genuina (validación faltante, edge no
    manejado, doc incorrecta). Se puntúa por gate + review (Agent C / LLM-judge).
- **Regla dura:** el Reporter **no conoce ni sugiere la implementación**. Solo el
  problema y el criterio. (Separación real; nada de colusión.)
- **Contrato de calidad del issue:** reproducible, acotado, criterio claro. A veces A
  emite un issue *malo* a propósito (vago/trampa) → B debe saber **declinarlo**.

### Agent B — Contributor (nuestro pipeline)
- **Misión:** resolver el issue con un PR mergeable, o declinarlo con justificación.
- **Flujo:** selecciona (filtro SOUL §5) → `recon.sh` → entiende el codebase →
  diff mínimo a la causa raíz + test → **gate** (calidad+seguridad+"el test falla sin
  el fix") → rama firmada → `gh pr create` con `Fixes #N` → registra en
  `contributions/active/CNNN.md`.
- **Regla dura:** gate rojo ⇒ no abre PR (idéntico a producción).
- **Puede declinar** issues vagos/trampa → eso también puntúa (buena selección).

### Agent C — Referee/Reviewer (fase avanzada, opcional)
- **Misión:** simular al maintainer. Corre el gate del repo, evalúa contra el criterio
  de aceptación, y **pide cambios o aprueba+mergea**.
- Para *seeded*: corre el **test escondido** → veredicto objetivo.
- Si pide cambios, B itera (rondas de review, con tope).

## 2. Sustrato: repo y cómo viven issues/PRs

| Modo | Cuándo | Issues | PRs |
|---|---|---|---|
| **GitHub-mode** | repo en GitHub + `gh auth` | `gh issue create/list` reales | rama + `gh pr create` reales |
| **Local-mode** | repo local/bare, sin red | `rounds/NNN/issue.md` | rama + `rounds/NNN/pr.md` + diff |

El orquestador autodetecta el modo (`gh repo view` responde ⇒ GitHub-mode). Local-mode
sirve para cablear el harness sin depender de red ni de una cuenta.

## 3. Protocolo de interacción (máquina de estados por ronda)

```
IDLE → A:file_issue → ISSUE_OPEN
ISSUE_OPEN → B:select → (DECLINED | CLAIMED)
CLAIMED → B:recon+code+gate → (GATE_RED → fix-loop | GATE_GREEN)
GATE_GREEN → B:open_PR → PR_OPEN
PR_OPEN → C:review → (CHANGES_REQUESTED → B:iterate → PR_OPEN | APPROVED)
APPROVED → C:merge → MERGED → score + learn → IDLE
```

- Tope de rondas de review (p. ej. 3) para evitar loops.
- Kill-switch y límite de tiempo/tokens por ronda.

## 4. Ground truth & scoring (cómo sabemos objetivamente que B lo hizo bien)

- **Seeded:** *hidden acceptance test* que A escribe y guarda **fuera del árbol que B
  ve** (rama de referee o `arena/catalog/<caso>/hidden_test`). Score = el test **falla
  antes** del fix y **pasa después**. Sin eso, el fix no cuenta (evita fixes cosméticos).
- **Métricas por ronda (`rounds/NNN/score.json`):**
  - `hidden_test`: pass/fail (seeded)
  - `gate_first_try`: ¿verde a la primera? · `gate_attempts`
  - `review_rounds`: hasta aprobar
  - `diff_size` vs mínimo esperado (detecta scope creep)
  - `security`: secretos/vulns introducidos (debe ser **0**)
  - `selection`: ¿declinó bien los issues-trampa?
  - `tokens`, `wall_time`
- Agregado → `arena/SCOREBOARD.md` y feed a `DASHBOARD.md` (tasa de aceptación
  simulada, rondas medias, higiene).

## 5. Layout de artefactos

```
arena/
  PLAN.md              este plan
  run.sh               orquestador (desde M1)
  catalog/             arquetipos seeded: defecto + hidden_test por stack
  agents/
    reporter.md        contrato/prompt de Agent A
    contributor.md     driver de Agent B (encadena recon + gate + PR)
    referee.md         prompt de Agent C
  rounds/
    round-001/
      issue.md         lo que A generó
      contribution.md  el CNNN de B (plan, salida del gate, link del PR)
      review.md        veredicto de C
      score.json       métricas de la ronda
  SCOREBOARD.md        agregado de rondas
LEARNINGS.md (raíz)    aprendizajes vivos (bien/mal) de TODO el proceso
```

## 6. Orquestación (cómo se ejecutan los agentes)

- Cada agente = **sub-agente** (herramienta Agent) con su prompt en `arena/agents/`.
- **Aislamiento:** un **git worktree por ronda** para trabajo paralelo sin choques.
- **Control determinista** (loops, condicionales, rondas, scoring): al escalar, un
  **Workflow** formaliza el pipeline de rondas; al inicio, orquestación manual o `run.sh`.
- Guardrails: kill-switch, tope de rondas, límite de tokens/tiempo.

## 7. El bucle de aprendizaje (registro vivo) — pedido explícito del accionista

- **`LEARNINGS.md`** (raíz): por evento/ronda, una entrada con **contexto · qué salió
  bien · qué salió mal · causa raíz · acción/regla resultante** (y a qué alimenta:
  filtro de SOUL / proceso de CLAUDE / check del gate / catálogo del arena).
- Aprendizajes **duraderos y no obvios** se espejan a memoria (cruzan sesiones).
- **Regla:** cada ronda cierra con ≥1 aprendizaje. Si no hubo, se anota "sin novedad"
  (señal de madurez del pipeline).

## 8. Rollout por milestones (crawl → walk → run)

- **M0 — Cableado local (sin red):** 1 seeded bug del catálogo, repo local,
  orquestación manual. B resuelve, gate corre, hidden test valida. Meta: el ciclo cierra una vez.
- **M1 — `run.sh` + scoring:** ✅ HECHO. `arena/run.sh` automatiza lo determinista
  (`prep`/`finalize`/`gate`/`oracle`/`selftest`); score.json auto. Los 2 agentes siguen
  siendo sub-agentes (seams entre `prep` y `finalize`). Full one-command → `claude -p`/Workflow (futuro).
- **M2 — GitHub-mode:** `gh` real en repo sandbox; issues y PR reales; `Fixes #N`.
- **M3 — Referee + rondas de review:** Agent C aprueba/pide cambios; B itera.
- **M4 — Multi-issue + paralelo:** ✅ HECHO (round-005): 3 Contributors en paralelo con
  worktrees, 3 PRs sin conflicto. **Generalizado en `run.sh`** (`prep-parallel`/`finalize-parallel`
  con no-regresión cruzada). Pendiente: mezcla seeded+organic, sandbox de OS.

Cada milestone: correr → registrar aprendizajes → endurecer el pipeline (igual que en `pipeline-lab/`).

## 9. Riesgos y guardrails

- **No contaminar el GitHub real de Jorge:** repo sandbox designado; jamás PRs a repos
  ajenos desde la simulación.
- **Identidad (DECIDIDO):** repo sandbox **bajo la cuenta de Jorge**; los commits de la
  simulación se **atribuyen a "Claude"** (autor + `Co-Authored-By`) para no mezclar con
  la reputación real. Límite conocido: `gh pr create` abre el PR con la cuenta
  autenticada (Jorge) — sin una 2ª cuenta GitHub para el bot, la separación total del
  *opener* no es posible; como es su propio sandbox, no cuenta como reputación pública.
- **Colusión A↔B:** contratos separados; el hidden test queda fuera del alcance de B.
- **Loops infinitos:** tope de rondas + kill-switch.
- **Secretos sintéticos** solo; nunca credenciales reales en fixtures.
- **Costo:** límite de tokens/tiempo por ronda.

## 10. Definición de «Hecho» de la simulación

- Una ronda seeded cierra completa: issue → PR → gate verde → hidden test pasa →
  (review) → merge, con `score.json` y ≥1 aprendizaje.
- El pipeline sobrevive N rondas **sin un solo falso verde de seguridad**.
- Los aprendizajes produjeron al menos un endurecimiento real del gate/proceso.

## 11. Decisiones

- ✅ **Repo:** GitHub-mode, sandbox bajo la cuenta de Jorge. *(Pendiente: la URL/nombre del repo.)*
- ✅ **Identidad:** commits atribuidos a "Claude"; PR abierto por la cuenta de Jorge (ver §9).
- ⏳ **Tipo de issue inicial:** recomiendo **seeded** (verificable) para M0–M1, luego mezclar con orgánicos.
- ⏳ **Agentes:** ¿sub-agentes reales desde el inicio, o primero cablo ambos roles y luego los separo?
