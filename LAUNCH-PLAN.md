# LAUNCH-PLAN.md — Afinar antes de colaborar en repos reales

> Plan de pre-lanzamiento. **Principio rector:** todo lo que falta se **afina y prueba en el
> sandbox `Testing_Pipelines` PRIMERO**; luego se ejerce en repos reales **en frío (solo leer)**;
> y solo entonces se abre el primer PR real, **supervisado**. La reputación real no se arriesga
> hasta que cada pieza esté ensayada. Ramp gradual: crawl → walk → run.

---

## 0. Estado — qué está listo vs qué falta

| Capa | Pieza | Estado |
|---|---|---|
| **Centro** (código+gate) | gate diff-aware (calidad+seguridad), risk-scan, "el test falla sin el fix" | ✅ probado (15/15, lab 10/10) |
| **Centro** | mecánica de PR (rama→gate→PR `Fixes #N`→merge) | ✅ probado en sandbox |
| **Frente** (selección) | elegir repo sano + issue accionable | ⚠️ recon.sh v1 hecho; rúbrica y shortlist pendientes |
| **Frente** | recon del repo objetivo (salud, convenciones) | ⚠️ v1 hecho; falta CI-parity + DCO + external-PR rate |
| **Centro→repo** | **paridad de CI** (correr el CI real del repo, no genérico) | ❌ no construido |
| **Centro** | diagnóstico en codebase grande y real | ❌ no ejercido |
| **Fondo** (social) | rondas de review, DCO/CLA, etiqueta, asignación | ❌ Agent C nunca corrió; 0 PRs reales |
| **Identidad** | firma de commits + sign-off bajo la cuenta de Jorge | ❌ no configurado |

**Conclusión:** el centro está listo; el **frente** y el **fondo** no se han estrenado. Este plan los cierra.

---

## 1. Los gaps (readiness items) — cada uno con su test y criterio

| # | Gap | Qué falta | Cómo se valida (test) | Criterio de aceptación |
|---|---|---|---|---|
| **G1** | Selección | rúbrica operacional + shortlist | T1 (recon accuracy) + revisión humana de la shortlist | ≥3 repos GO con issues cómodos, verificados a mano |
| **G2** | Recon | CI-parity parsing, DCO detect, external-PR merge rate en `recon.sh` | T1 sobre repos de estado conocido | veredictos correctos en ≥5 repos conocidos |
| **G3** | CI-parity del gate | modo que corre el CI *real* del repo (make/pre-commit/nox/workflow) | T2 en el sandbox (tiene ci.yml) | el gate reproduce el veredicto de GitHub Actions |
| **G4** | Diagnóstico real | práctica en codebase grande | T6 (dry-run real, sin PR) | fix correcto que pasa los tests del propio repo |
| **G5** | Capa social | Agent C (referee) + rondas de review + plantillas + DCO | T3 + T5 en el sandbox | ≥1 ronda de review resuelta; convenciones seguidas; trampa social declinada |
| **G6** | Identidad | firma SSH/GPG + sign-off; identidad de Jorge en lo real | T4 en el sandbox | commit del sandbox firmado + con `Signed-off-by` |

---

## 2. La herramienta de reconocimiento — `tools/recon.sh`

**v1 (hecho, read-only):**
- `recon.sh profile <owner/repo>` → salud + veredicto **GO / MAYBE / SKIP**. Señales: estrellas
  (filtro duro ≥100), archivado/fork (honeypot), último push, good-first-issue/help-wanted abiertos,
  CONTRIBUTING, nº de workflows de CI.
- `recon.sh find <lang> [min_stars]` → repos del nicho ≥estrellas con good-first-issues (por recencia).
- `recon.sh issues <owner/repo>` → los good-first-issue/help-wanted abiertos.

**v2 (a construir en R0):**
- **CI-parity:** parsear `.github/workflows/*.yml` + `.pre-commit-config.yaml` + `Makefile`/`justfile`/
  `noxfile` → listar los **comandos exactos** que corre su CI (para que el gate los reproduzca, G3).
- **Salud fina:** mediana de tiempo a primer review (vía `gh api` sobre PRs recientes), % de PRs de
  **externos** mergeados (¿aceptan gente de fuera?), detección de **DCO/CLA** (bot de CLA, `Signed-off-by`
  en commits recientes).
- **Comfort filter:** en `issues`, priorizar labels cómodos (`good first issue`, `documentation`,
  `E-easy`, `help wanted`) y descartar los que huelen a diseño/discusión larga.

---

## 3. Rúbrica de selección

**Filtros duros (si falla uno → SKIP):**
- ⭐ **≥100 estrellas** · no archivado · no es fork · licencia OSS presente.
- Maintainer activo (push ≤ ~60 días) · CI real · acepta PRs de externos (hay merges de fuera).

**Señales positivas (suman):** CONTRIBUTING claro · good-first-issue/help-wanted abiertos · respuesta
a PRs recientes (<2 sem) · tests existentes · issue con criterio de aceptación explícito.

**Comfort profile — casos con los que empezamos (cómodos):**
1. **Docs/typo/ejemplo** — bajísimo riesgo, buena primera huella.
2. **Bug pequeño con repro/test que falla** ya provisto en el issue.
3. **`good first issue` con aceptación explícita** en Rust/Python/infra.
4. **Añadir un test** para comportamiento existente no cubierto.
5. **Utilidad bien especificada** (ej. implementar un flag documentado en `uutils/coreutils`).

**Evitar al principio:** rendimiento, `unsafe`/UB, async/concurrencia, refactors grandes, specs
ambiguas, features polémicas, y todo lo de seguridad sensible.

**Anti-patrones de selección (aprendidos en T6, descartar aunque estén etiquetados "good first issue"):**
- **"Improve code coverage"** en módulos platform/FFI/IO: casi nada es pure-testable; los paths obvios
  suelen estar ya cubiertos; el resto necesita fixtures o comparaciones flaky.
- Repos que **desactivan unit tests** (`grep -r 'test = false' Cargo.toml`) y solo prueban por
  integración: un unit test tuyo será rechazado. **Verifica la convención de test ANTES de codear.**
- Issues con verificación **imposible en local** (utils cross-platform que comparan contra GNU y en
  tu SO hay BSD): no podrás dar "gate verde" honesto; dependerás del CI del repo.

---

## 4. Los tests (todos en `Testing_Pipelines`, salvo T6 que es dry-run real sin PR)

| Test | Qué prueba | Cómo se corre | Aserción |
|---|---|---|---|
| **T1** Recon accuracy | veredictos de `recon.sh` | profile sobre repos de estado conocido (sandbox=SKIP, un sano=GO, un archivado=SKIP, un <100★=SKIP) | veredictos correctos |
| **T2** CI-parity | el gate reproduce el CI del repo | enriquecer el sandbox (ya tiene `ci.yml`); gate en modo parity corre `cargo fmt/clippy/test` detectados | resultado del gate == Actions |
| **T3** Rondas de review | Agent C pide cambios, B itera | ronda del arena con referee que solicita un cambio → B lo aborda → C aprueba+mergea | merge tras ≥1 ronda |
| **T4** DCO/firma | commits firmados + sign-off | configurar firma; PR del sandbox | commit con `Signed-off-by` (+ "Verified" si hay llave) |
| **T5** Convenciones + trampa social | seguir CONTRIBUTING/PR-template; declinar issue ambiguo | sembrar CONTRIBUTING + PR template + un issue vago "discutir antes de PR" | B sigue el template; declina/consulta el ambiguo |
| **T6** Dry-run real (sin PR) | diagnóstico en repo grande real | elegir un good-first-issue real; clonar; resolver; gate parity; PR **draft NO abierto** | tests del repo verdes; rama PR-ready; revisión humana |

> El sandbox se **enriquece** para T2–T5: añadir `CONTRIBUTING.md`, plantilla de PR, requisito de
> DCO, y un issue realista ambiguo — para que deje de ser "oráculo limpio" y modele un repo real.

---

## 5. La ruta gradual (crawl → walk → run)

| Rung | Objetivo | Qué se hace | Salida / gate para avanzar |
|---|---|---|---|
| **R0 — Afinar (sandbox)** | cerrar G2–G6 | recon v2 (CI-parity), gate en modo parity, Agent C + rondas de review en el arena, firma/DCO, enriquecer sandbox; correr T1–T5 | **T1–T5 todos verdes** |
| **R1 — Recon en frío (real, read-only)** | selección real | `recon.sh find/profile` por el nicho; puntuar; armar shortlist de 3–5 repos GO con issues cómodos | shortlist revisada **a mano** por el accionista |
| **R2 — Dry-run real (sin PR)** | diagnóstico real | T6: **un** issue real resuelto de punta a punta en local, gate parity verde, PR **draft** | rama PR-ready + revisión del accionista |
| **R3 — Primer PR real (supervisado)** | estrenar el fondo | abrir **ese** PR bajo la cuenta de Jorge; comentar el issue; atender review; iterar. Gate humano: Jorge revisa+envía | **1 resultado real** (merge o cierre gracioso) + lección |
| **R4 — Escalar despacio** | reputación compuesta | 1 → 2–3 en paralelo; **mismos repos primero** (la reputación compone); ampliar nicho | tasa de aceptación real ≥ meta en DASHBOARD |

**Kill/rollback por rung:** si en R1 no salen ≥3 repos cómodos → ampliar nicho, no bajar el estándar.
Si en R3 el primer PR se rechaza mal → volver a R1/R2 y recalibrar la selección (SOUL §5), no insistir.

---

## 6. Definición de "listo para lanzar" (checklist antes de R3)

- [x] `recon.sh` con **CI-parity** + **T1 verde (5/5)** + **salud fina v2** (PRs mergeados 30d,
      merges de externos, DCO, task-runner make/just/pre-commit). *(R0, 2026-08-29)*
- [x] Gate en **modo CI-parity** (`--parity`: corre los comandos de verificación del `.github/workflows`
      local, fallback a genérico si son matrix/templated); **T2 verde** — reproduce Actions del sandbox
      en ambos sentidos (main limpio → verde; violación de fmt → rojo). *(R0, 2026-08-29)*
- [x] **Agent C (referee) + rondas de review; T3 verde** — PR #33: request→atender→LGTM→merge,
      1 ronda de review real. Límite: con 1 sola cuenta el "approve" formal es un comentario (no `--approve`). *(R0, 2026-08-29)*
- [x] **Firma de commits (SSH) + sign-off; T4 verde** — commit firmado ("Good signature" local) +
      `Signed-off-by`. *(gate humano pendiente: subir la llave pública a la cuenta de Jorge para el badge "Verified")*. *(R0, 2026-08-29)*
- [x] **Convenciones + declinar ambiguo; T5 verde** — sandbox enriquecido (CONTRIBUTING + PR template);
      issue de diseño #34 **declinado** con petición de alcance, sin PR. *(R0, 2026-08-29)*
- [x] **Shortlist R1** de 5 repos **GO** (coreutils/fd/zizmor/brush/steel) — ver `contributions/PIPELINE.md`. *(R0/R1, 2026-08-29)*
- [x] **T6 ejecutado** (dry-run coreutils #9060): ciclo completo **local, cero huella externa**
      (clonar→entender→tests→build+test scoped 2/2 verde). **Resultado: NO submitir** — el issue no
      es cómodo (`[lib] test=false` → unit tests muertos para su CI; flags ya cubiertos; resto necesita
      fixtures utmp/comparación flaky). **El dry-run cazó la mis-selección ANTES de un PR real.** *(R2, 2026-08-29)*
- [x] **Re-selección verificada → T6 EXITOSO** en `servo/rust-smallvec` #494 (impl `arbitrary::Arbitrary`):
      dry-run completo, contribución limpia (build/test `--features arbitrary` verde, fmt limpio),
      commit local (Jorge + sign-off), **PR borrador SIN abrir, cero push**. Clon: `~/Desktop/AnatemaBot/t6-smallvec`.
      *(R2, 2026-08-29)* → **listo para R3 (gate humano: Jorge revisa el borrador y, si va, lo publica).**
- [ ] Guardrails activos (abajo).

## 7. Guardrails & no-negociables

- **≥100 estrellas** siempre (filtro duro de `recon.sh`); jamás forks/honeypots ni repos sin merges de externos.
- **El accionista revisa y envía CADA PR real** bajo su cuenta.
- **En repos reales, los agentes REDACTAN; el accionista PUBLICA.** Comentarios de issue/PR y el PR
  mismo se dejan como *borrador* para que Jorge los publique — no se escribe en repos ajenos bajo su
  identidad sin su acción. (En el sandbox `Testing_Pipelines` sí se publica: autorizado.)
- **Commits firmados + sign-off** bajo la identidad de Jorge en lo real (la identidad "Claude" fue solo del sandbox).
- **Un repo/PR a la vez hasta R4.** Declinar issues ambiguos. Cero secretos (lo fuerza el gate).
- **Registrar cada interacción real** (selección, review, resultado) en `LEARNINGS.md`.

---

## 8. Shortlist semilla (de la primera corrida real de `recon.sh find rust 100`)

Candidatos GO a perfilar en R1 (verificados vivos hoy; re-perfilar antes de tocar):

| Repo | ★ | Por qué encaja (comfort) |
|---|---|---|
| `uutils/coreutils` | ~24k | reescritura de GNU coreutils: utils **bien especificadas**, tests existentes, muy acogedor a novatos |
| `mattwparas/steel` | ~2.5k | intérprete Scheme en Rust; issues acotados |
| `reubeno/brush` | ~2.2k | shell POSIX en Rust; specs claras (comportamiento bash conocido) |
| `zizmorcore/zizmor` | ~6.4k | static analysis de GitHub Actions; nicho devtools/seguridad |
| `BurntSushi/ripgrep` | ~68k | maduro, `help wanted`=9, CONTRIBUTING claro (perfilado: **GO**) |

> Nota: `find` ordena por estrellas; en R1 se filtra además por *comfort profile* del issue y por
> salud fina (tiempo a review, merges de externos). `uutils/coreutils` es el candidato natural para
> el primer ensayo (T6): utilidades con contrato conocido = diagnóstico acotado y verificable.
