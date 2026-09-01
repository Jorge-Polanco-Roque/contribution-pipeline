# LEARNINGS.md — Ledger de aprendizajes (bien / mal)

> Registro vivo de qué se hizo bien y qué mal durante TODO el proceso, con causa raíz
> y la regla que resulta. Cada entrada alimenta algo concreto: filtro de `SOUL`,
> proceso de `CLAUDE`, un check del gate, o el catálogo del `arena`. Los aprendizajes
> duraderos y no obvios se espejan a memoria. Formato por entrada:
>
> **[fecha] Título** — Contexto · ✅ Bien · ❌ Mal · 🔎 Causa raíz · 🛠️ Regla/acción (→ a qué alimenta)

---

## 2026-08-29 — Semilla inicial (lo aprendido hasta arrancar el arena)

**Verificar los supuestos de plataforma antes de construir sobre ellos**
- Contexto: el plan original asumía Algora como board central de bounties.
- ✅ Bien: lo verifiqué **en vivo** (Playwright + curl) en vez de confiar en el doc.
- ❌ Mal: se habían escrito planes enteros sobre un supuesto sin revalidar; además
  gasté varias llamadas *adivinando URLs* de Algora antes de reportar el bloqueo.
- 🔎 Causa raíz: supuesto viejo tratado como verdad presente; brute-force en vez de
  revalidar temprano.
- 🛠️ Regla: revalidar toda dependencia externa antes de planear sobre ella; si el
  terreno cambió, **reportar temprano** en vez de insistir. (→ proceso CLAUDE)

**El falso negativo silencioso es el peor bug de un scanner de secretos**
- Contexto: el gate de secretos usaba `git grep` sin cubrir untracked ni no-git.
- ✅ Bien: `pipeline-lab/` cazó los 2 casos con fixtures deterministas antes de producción.
- ❌ Mal: la primera versión daba **verde con un secreto presente** (archivo sin
  `git add`, o carpeta que no es repo git). Y una versión previa leía el patrón
  `-----BEGIN` como opción de `git grep`.
- 🔎 Causa raíz: `git grep` solo mira trackeados y falla fuera de repo; el `|| true`
  se tragaba el error → verde en falso.
- 🛠️ Regla: en seguridad, **fallar cerrado, nunca abierto**; cubrir untracked +
  no-git; todo check nace con su fixture en el lab. (→ gate + pipeline-lab)

**Senior = delegar al repo, no imponer un pipeline genérico**
- Contexto: diseño del Plan maestro.
- ✅ Bien: la tesis quedó en "el pipeline corre los checks DEL repo; nosotros solo
  añadimos invariantes finos" → menos código propio, cero ruido en el diff ajeno.
- 🛠️ Regla: preferir la herramienta que ya vive en el repo; automatizar solo lo
  transversal (secretos, firma, "el test prueba el fix"). (→ Plan maestro / gate)

**El objetivo lo fija el accionista; los docs son la fuente de verdad**
- Contexto: pivote dinero → reputación a media construcción.
- ✅ Bien: reestructura limpia y trazable; nada se sobre-construyó antes del pivote.
- 🛠️ Regla: mantener SOUL/CLAUDE/DASHBOARD como verdad viva y no acoplarse a un
  objetivo que puede cambiar. (→ proceso CLAUDE)

---

## 2026-08-29 — Arena Ronda 001 (M0): ciclo completo en GitHub-mode

Repo `Testing_Pipelines`; bug seeded en `median()` (par); issue #1 → PR #2 → merge.

**El plumbing end-to-end funciona**
- ✅ Bien: cerró el ciclo entero — seed→issue→rama→gate→PR `Fixes #1`→CI Actions verde→
  merge→issue auto-cerrado. El **oráculo** (hidden test) falló en main y pasó tras el fix
  → validación objetiva, no "confía en mí". Gate verde a la primera; diff de 13 líneas sin scope creep.
- 🛠️ Regla: todo fix seeded se valida con oráculo antes/después; "gate verde" nunca basta solo. (→ arena/referee)

**Gate verde ≠ correcto — el oráculo es imprescindible**
- 🔎 El gate corre los tests del repo + los de B, no el oráculo de A. Un fix podría pasar el
  gate y aun así estar mal; solo el hidden test independiente lo cazaría.
- 🛠️ Regla: mantener el oráculo del referee **fuera del alcance de B** y correrlo siempre. (→ arena)

**Cobertura de seguridad incompleta en esta máquina**
- ❌ Mal: `cargo-audit`/`gitleaks`/`semgrep` ausentes → SCA/SAST omitidos; el verde de seguridad
  fue parcial (solo secretos por fallback).
- 🛠️ Regla: ejecutar Fase 0 (`bootstrap.sh`) antes de confiar el veredicto de seguridad. (→ gate/Fase 0)

**Colusión inevitable en M0 (honestidad)**
- ❌ Mal: yo cablé Reporter y Contributor, así que "conocía" el bug al arreglarlo. La prueba
  intelectual real de B (entender solo desde el texto del issue) aún no ocurrió.
- 🛠️ Regla: M3+ debe separar agentes en sub-agentes reales; B trabaja solo desde el issue,
  sin ver el seed ni el oráculo. (→ arena M3, rollout)

**Automatización pendiente**
- La ronda fue manual. `arena/run.sh` (M1) debe orquestar: crear issue → correr B → validar oráculo → score. (→ arena M1)

---

## 2026-08-29 — Arena Ronda 002 (M3): agentes separados, sin colusión

Repo `Testing_Pipelines`; Reporter y Contributor como **sub-agentes reales** (contextos
separados). Bug: `variance()` muestral (n-1) vs poblacional (n). Issue #3 → PR #4 → merge.

**La separación de agentes funciona — y es la validación que faltaba**
- ✅ Bien: el **Reporter eligió un bug que yo no diseñé** (sutil: muestral vs poblacional,
  latente porque el test existente usaba valores constantes). El **Contributor ciego**
  —solo con el issue + código— diagnosticó la causa raíz y la arregló con diff mínimo.
  Oráculo fail→pass, CI verde, gate a la primera. Esto sí prueba el pipeline de verdad.
- 🛠️ Regla: la demanda seeded la genera un agente independiente; el que arregla nunca ve
  el seed ni el oráculo. (→ arena, ya es el default M3+)

**El aislamiento por prompt es débil — hay que hacerlo estructural**
- ❌ Mal: el Contributor tenía acceso de filesystem a `arena/` (catálogo/oráculo); cumplió
  la prohibición por instrucción, pero confiar en "no mires" no es garantía real.
- 🛠️ Regla: correr al Contributor en un entorno **sin acceso** al oráculo (worktree/dir
  aislado que no incluya `test002/arena`), no solo pedírselo. (→ arena M4 / run.sh)

**Dificultad aún baja**
- ⚠️ Ambos bugs fueron fixes matemáticos de ~1 línea. No hemos probado issues difíciles
  (multi-archivo, ambiguos) ni un issue-**trampa** para ver si B sabe **declinar**.
- 🛠️ Regla: variar dificultad y meter un issue-trampa en las próximas rondas. (→ catálogo)

**Cobertura de seguridad sigue parcial** (cargo-audit/gitleaks/semgrep ausentes) → Fase 0 pendiente.

---

## 2026-08-29 — Arena Ronda 003 (M4): aislamiento real + issue-trampa

Repo `Testing_Pipelines`. Reporter creó un bug real (`percentile()`, peso de interpolación
invertido, #5) **y** una trampa (`variance()` vs Excel, #6). Contributor corrió **aislado**.

**Aislamiento estructural > aislamiento por prompt**
- ✅ Bien: el Contributor trabajó en `/tmp/arena-iso` con el gate en `/tmp/gate.sh` y **sin
  ninguna ruta a `test002/arena`**; el oráculo se eliminó del árbol antes de invocarlo.
  Resolvió el bug a ciegas igual → prueba que no dependía de ver el oráculo.
- ❌ Mal (cazado): al correr el oráculo para el ground truth, quedaron **fingerprints en
  `target/`** con el nombre "hidden_test". Un contribuidor curioso los vería.
- 🛠️ Regla: al aislar, limpiar artefactos de build (`target/`) y hacer `grep` de rastros
  antes de soltar al Contributor. El aislamiento incluye el caché, no solo el fuente. (→ arena/run.sh)
- 🔎 Caveat honesto: sigue sin ser sandbox de OS (un subagente puede leer cualquier ruta
  absoluta). Es aislamiento por **referencia + ausencia física**. El grado final sería
  permisos/contenedor. (→ deferido)

**La disciplina de declinar funciona — no cae en trampas**
- ✅ Bien: ante un issue inválido (pedía romper la varianza poblacional documentada para
  imitar a Excel), el Contributor **declinó** con rigor: citó docstring + test existente,
  distinguió población vs muestral, propuso `sample_variance()` como feature aparte. Cero
  falso PR. Esto valida el filtro de selección de SOUL en la práctica.
- 🛠️ Regla: un buen contribuidor gana reputación tanto por lo que arregla como por lo que
  **sabe no tocar**. Mantener trampas en el catálogo. (→ SOUL §5, catálogo)

**Dificultad subió a media, pero el fix seguía siendo ~1 línea de causa raíz**
- ⚠️ `percentile()` exigía leer y entender interpolación, aunque la corrección final fue
  puntual. Falta un caso genuinamente multi-archivo / de diseño.
- 🛠️ Regla: próximas rondas con bugs cross-módulo o que exijan refactor acotado. (→ catálogo)

---

## 2026-08-29 — M1: harness `arena/run.sh`

Automatizado todo lo determinista de una ronda (prep/finalize/gate/oracle/selftest) tras
probar el patrón 3 veces a mano.

**Bash no puede orquestar el razonamiento — sé honesto sobre el límite**
- 🔎 Los agentes (Reporter/Contributor) son sub-agentes de Claude; un script no los invoca.
  `run.sh` cubre el 90% determinista y deja 2 *seams* limpios para los agentes.
- 🛠️ Regla: para one-command real haría falta `claude -p` headless o un Workflow; el harness
  bash es el punto correcto de automatización sin fragilidad. (→ PLAN, futuro)

**El self-test cazó una fragilidad real del propio harness**
- ✅ Bien: dejé un `selftest` con estado vivo (oráculo de `percentile` debe PASAR en main
  tras #7). Falló a la primera → **`main` local estaba desactualizado** (el merge fue remoto).
- 🛠️ Regla: todo check contra `main` sincroniza primero (`pull`). Aplicado a `selftest` y
  `prep`. Un harness que lee estado remoto debe refrescarlo, no confiar en el checkout local. (→ run.sh)

---

## 2026-08-29 — Fase 0: tooling de seguridad + la SEGURIDAD debe ser DIFF-AWARE

`bootstrap.sh` instaló gitleaks, semgrep, osv-scanner, pip-audit, cargo-audit (govulncheck
omitido: sin Go). Al verificar el gate completo, la etapa de seguridad reveló el punto clave.

**Verificar con el tooling real destapó la falla que anticipaba la Fase 3**
- ❌ Mal: `semgrep --config auto` escanea TODO el repo y marcó `actions/checkout@v4` (tag
  mutable) de la CI — **deuda pre-existente del repo**, no algo nuestro. El gate se puso rojo.
  Sin arreglar, el gate sería **inusable en cualquier repo real** (casi todos usan `@vN`).
- ✅ Bien: lo cacé al verificar de verdad (no en teoría), y lo arreglé: SAST **diff-aware**
  con `semgrep --baseline-commit <merge-base>` → solo falla por hallazgos NUEVOS; en la rama
  por defecto informa sin bloquear.
- ✅ Verificado en ambos sentidos: deuda pre-existente (`checkout@v4`) NO bloquea; hallazgo
  nuevo (`subprocess.Popen(shell=True)`) SÍ bloquea (exit 1).
- 🛠️ Regla dura: **la seguridad bloquea solo lo que introducimos, nunca la deuda ajena.**
  Secretos son la excepción (siempre bloquean). (→ gate Fase 3, ya implementado para SAST)

**Detalles operativos aprendidos**
- `cargo-audit` vive en `~/.cargo/bin`, fuera del PATH por defecto → el gate ahora lo añade
  al PATH. Un tool instalado no sirve si el gate no lo encuentra.
- El post-check de `bootstrap.sh` marcó semgrep como fallido aunque quedó instalado (corrió
  antes de que `brew` enlazara). Verificar disponibilidad *después*, no en el mismo aliento.

**Deferido (siguiente):** SCA (`cargo audit`/`osv-scanner`) aún NO es diff-aware — una vuln
pre-existente en una dep que no tocamos bloquearía. Heurística pendiente: solo bloquear SCA
si el diff toca `Cargo.toml`/lockfile; si no, informar. → **HECHO abajo.**

---

## 2026-08-29 — SCA diff-aware (cierra la simetría de seguridad)

**El SCA ahora bloquea solo si tocamos las dependencias**
- ✅ Bien: extraje `diff_base()` compartido; el SCA usa `deps_touched` (¿el diff toca
  Cargo.toml/lock, package.json, go.mod, pyproject…?). Si sí → bloquea por vulns; si no →
  informa sin bloquear. Mismo principio que el SAST.
- ✅ Verificado con vuln REAL (`time 0.1.43`, RUSTSEC-2020-0071) en repo aislado con su
  propio `origin/main`: tocar solo `src` → informa, **GATE OK**; tocar `Cargo.toml` →
  **GATE FALLÓ**. Ambas direcciones correctas.
- 🛠️ Regla: la responsabilidad de seguridad se mide por el diff — introduces una dep
  vulnerable → tuyo; una vuln que ya estaba → del repo. Secretos siguen siendo la excepción
  (siempre bloquean). (→ gate, completo)

**Diseño que lo hizo limpio**
- Un solo `diff_base()` sirve a SAST (`--baseline-commit`) y a SCA (`deps_touched`). Menos
  código, una sola noción de "qué introdujo esta rama". (ponytail: no duplicar la base del diff)

---

## 2026-08-29 — Arena Ronda 004: bug cross-módulo, sistema completo ensamblado

Bug en 3 módulos (measures→bounds→summary): `Quartiles::of` invertía lower/upper; síntoma en
`Summary::of` (q1>q3, iqr<0). Issue #8 → PR #9 → merge, vía harness M1.

**El pipeline aguanta diagnóstico difícil (no solo fixes de 1 línea)**
- ✅ Bien: el Contributor **ciego** trazó del síntoma (summary) a la causa raíz (bounds) y
  arregló **ahí**, sin parchear el módulo del síntoma (que habría enmascarado el bug). El fix
  fue chico (2 líneas) pero **el diagnóstico exigió leer 3 archivos y seguir las llamadas**.
- 🔎 Insight: "dificultad" en contribuciones = dificultad de *diagnóstico*, no tamaño del diff.
  El valor del pipeline es encontrar la causa raíz, no teclear mucho.
- 🛠️ Regla: mantener en el catálogo bugs donde síntoma ≠ causa (cross-módulo) — son los que
  distinguen a un contribuidor senior. (→ catálogo)

**Primer end-to-end con TODO ensamblado**
- ✅ `run.sh prep` → agente Reporter → agente Contributor (aislado) → `run.sh finalize`, con
  gate diff-aware y CI real. El referee no se tocó a mano; mi trabajo se redujo a invocar los
  2 agentes. El sistema (harness + agentes separados + aislamiento + seguridad diff-aware) opera
  como una unidad. Score.json auto.
- 🛠️ Regla: este es el loop estándar de ahora en adelante para cada ronda. (→ arena)

---

## 2026-08-29 — Arena Ronda 005: multi-issue en paralelo con worktrees

3 bugs independientes (measures/range/normalize) → 3 Contributors EN PARALELO, cada uno en su
`git worktree` → 3 PRs (#13/#14/#15) mergeados sin conflicto. Issues #10/#11/#12 cerrados.

**El paralelismo seguro depende de la INDEPENDENCIA, garantizada al sembrar**
- ✅ Bien: el Reporter puso las 3 causas raíz en **archivos disjuntos** (`measures.rs`/`range.rs`/
  `normalize.rs`); `lib.rs` solo declara módulos y ningún fix lo tocó → 3 merges paralelos sin conflicto.
- 🔎 Insight: lo que habilita paralelizar no es la herramienta (worktrees), es el **diseño del
  trabajo en unidades disjuntas**. Acoplamiento entre archivos rompería el merge paralelo.
- 🛠️ Regla: antes de fan-out, verificar que las tareas tocan archivos disjuntos; si no, serializar. (→ arena)

**Worktrees: aislamiento eficiente para agentes concurrentes**
- ✅ Bien: `git worktree add --detach` por Contributor → working trees + ramas independientes
  sobre un `.git` compartido; 3 builds/tests/gates concurrentes sin interferencia; 3 push sin lock.
- ✅ Cada worktree se limpió (`target/`, sin rastro de oráculo) igual que el aislamiento de M4.
- 🔎 Caveat: a mayor escala, los push concurrentes sobre `.git` compartido podrían chocar en locks;
  con 3 no pasó. Clones separados serían más robustos pero menos eficientes. (→ deferido si escalamos)

**Verificación clave del merge paralelo: no-regresión cruzada**
- ✅ Bien: tras mergear los 3, corrí los **3 oráculos juntos en main** (todos PASS) → ningún fix
  rompió a otro. En paralelo esta comprobación combinada es obligatoria, no opcional.
- 🛠️ Regla: cerrar toda ronda paralela con los oráculos de TODOS los issues contra el main final. (→ run.sh futuro)

---

## 2026-08-29 — Fan-out paralelo generalizado en run.sh

Añadidos `prep-parallel <slug...>` y `finalize-parallel <slug:issue:pr>...`: loopean las ops
ya probadas (check_oracle, worktree, CI, merge) e incorporan la **no-regresión cruzada** y la
limpieza de worktrees. Los N Contributors siguen siendo el seam de agentes (una tanda de Agent).

**El smoke-test atrapó un bug de bash antes de una ronda real**
- ❌ Mal: `local slug="$1" wt="/tmp/wt-$slug"` en una línea → con `set -u` el shell expande
  `$slug` (aún sin asignar) al construir los argumentos de `local` → "unbound variable".
- ✅ Bien: dejé `cmd_selftest_parallel` (crea/limpia 2 worktrees con estado vivo); reveló el
  fallo de inmediato. Fix: separar en dos statements (`local slug=...; local wt=...`).
- 🛠️ Regla: cada lógica nueva del harness nace con su smoke-test de estado vivo; los gotchas de
  bash (expansión en `local`, `set -u`) se cazan ahí, no en producción. (→ run.sh)

---

## 2026-08-29 — Arena Ronda 006: ronda paralela real con los comandos generalizados

3 bugs (mode/skewness/argmin en archivos disjuntos) → `prep-parallel` → 3 Contributors en
paralelo → `finalize-parallel`. Issues #16/#17/#18 → PRs #20/#21/#19 → merge; no-regresión cruzada verde.

**Sin novedad = señal de madurez**
- ✅ La ronda entera corrió con **2 comandos del harness + 1 tanda de 3 agentes**, a la primera,
  sin intervención manual del referee. `prep-parallel`/`finalize-parallel` funcionaron tal cual
  se diseñaron; el gate diff-aware y el aislamiento por worktree se comportaron. No hubo bug
  nuevo que registrar — que es exactamente lo que se espera de un sistema ya endurecido.
- 🔎 Pequeño gap (deferido): `finalize-parallel` no emite `score.json` por-slug como la versión
  simple; el agregado vive en SCOREBOARD. Añadirlo si queremos scoring máquina por ronda paralela. (→ run.sh)
  → **CERRADO:** `finalize-parallel` ahora emite `score.json` por-slug (con campo `cross_regression`)
  vía el helper `write_score`, expuesto también como subcomando `score` (reutilizable + testeable;
  se usó para backfillear la ronda 006). JSON validado.

---

## 2026-08-29 — Ronda 007: one-command via Workflow (arena-round)

Un solo `Workflow` orquestó la ronda entera: Seed (Reporter) → Prep → Fix (2 Contributors ∥) →
Finalize. 5 agentes, ~177k tokens, ~6.5 min. Bugs weighted_mean #22→PR#25 y covariance #23→PR#24,
ambos mergeados, no-regresión cruzada verde, score.json auto. Guardado como workflow con nombre.

**El Workflow es el orquestador determinista correcto — con un límite de arquitectura**
- ✅ Bien: control de flujo en JS (phases, `parallel()` para el fan-out, schemas para salida
  estructurada), reusando el harness `run.sh` ya probado. La ronda salió a la primera.
- 🔎 Límite clave: **el script del Workflow no ejecuta bash** (sin FS/Node API); solo `agent()`.
  Por eso los pasos deterministas (prep/finalize) van envueltos en un agente-referee que corre
  `run.sh`. No es desperdicio: mantiene el harness como única fuente de verdad determinista y el
  Workflow como capa de orquestación. (→ arena)
- 🛠️ Regla: separación de capas — Workflow orquesta y parsea (schemas); `run.sh` hace lo
  determinista; los agentes razonan. Cada uno en su nivel. (→ arena, patrón estándar)

**Tres formas de correr una ronda, según cuánto control manual quieras**
- Manual: yo invoco Reporter/Contributors + `run.sh prep/finalize` (máximo control, para depurar).
- Semi: `run.sh prep-parallel` + tanda de Agent + `run.sh finalize-parallel` (referee automatizado).
- One-command: `Workflow({name:'arena-round', args:{n}})` (todo automatizado). (→ elegir según el caso)

---

## 2026-08-29 — Arena Ronda 008: sin novedad (madurez confirmada)

3 bugs (harmonic_mean/running_max/trimmed_mean, archivos disjuntos) → `prep-parallel` → 3
Contributors ∥ → `finalize-parallel`. PRs #29/#30/#31 mergeados, cross-regresión verde,
`score.json` emitidos automáticamente por el harness. **Sin intervención manual, a la primera.**

- ✅ Los 3 Contributors ciegos diagnosticaron su causa raíz (división invertida / prefix-max /
  divisor `n−2k`) solo desde el issue, con diff mínimo y test de regresión que falla sin el fix.
- 🔎 Ronda rutinaria: nada nuevo que arreglar en el sistema. El valor de registrarla es la
  **serie** — 15/15 bugs mergeados, 15/15 gate verde a la primera, 0 falsos verdes de seguridad.
  Un sistema maduro produce rondas aburridas; esa es la meta.

---

## 2026-08-29 — Iteración fuerte: 10 retos hyper-experto + auditoría de puntos ciegos

Diseñé 10 retos de nivel industria (`arena/CHALLENGES.md`), cada uno un defecto que **pasa el
gate naïve en verde** y aun así es incorrecto. Objetivo: auditar los puntos ciegos del pipeline,
no probar al Contributor. Testeé el gate empíricamente y lo endurecí.

**El hallazgo central: un gate estático es CIEGO a la correctitud no cubierta por tests**
- ✅ Verificado: un crate con `median` que **panica con NaN** (reto 2) y `checksum` **UB con slice
  vacío** (retos 4/5) pasó el gate completo en **VERDE** (fmt/clippy/build/test + seguridad). Los
  tests solo usaban datos limpios. El gate confía en los tests del repo; si no cubren el caso, no hay red.
- 🛠️ Regla: la defensa es **en capas** — gate (mecánico) + property/fuzz tests del repo (semántico)
  + deep-gate opt-in (miri/loom/semver/criterion) cuando el diff lo amerita. Ningún gate estático
  garantiza correctitud numérica, ausencia de UB, rendimiento ni semver por sí solo. (→ CHALLENGES.md)

**Mejora añadida: risk-scan del diff (advisory, diff-aware)**
- ✅ Nuevo stage en `pre_submit.sh`: surfacea construcciones riesgosas **nuevas** en el diff —
  `unsafe`, `unwrap/expect/panic!`, casts `as`, errores tragados (`let _`/`.ok()`/`unwrap_or_default`),
  `#[allow]`. Verificado: en el fixture flaggeó exactamente el `unwrap`, el `as u8` y el `unsafe`.
  No bloquea (a veces son legítimas) — pone el riesgo frente al revisor. Ataca 2,4,5,10.

**Bug real del pipeline cazado al testear #1: lockfile untracked → SCA en falso**
- ❌ Mal: `cargo build` genera `Cargo.lock` untracked; `changed_files` lo contaba y `deps_touched`
  incluía lockfiles → el SCA se activaba como "deps tocadas" **sin que tocáramos deps**.
- 🛠️ Fix: `deps_touched` keyea SOLO en el **manifiesto** (`Cargo.toml`/`go.mod`/`pyproject`/
  `package.json`), no en lockfiles generados. Ceiling: un `cargo update` solo-lockfile se pierde (raro).

**Bug real del pipeline cazado al testear #2: instalar tooling cambió el comportamiento**
- ❌ Mal: al instalar `gitleaks` (Fase 0), `secrets_scan` pasó de grep-fallback a gitleaks — que
  **allowlistea** la clave de ejemplo `AKIAIOSFODNN7EXAMPLE` que usaban los fixtures del lab.
  Resultado: 5/8 casos del lab pasaron a verde en falso; el lab dejó de probar detección.
- 🔎 Doble lección: (a) los fixtures usaban un secreto que las herramientas **ignoran a propósito**
  (peor test posible); (b) **la presencia de tooling cambia el comportamiento del gate** → revalidar
  el lab cuando cambia el tooling. Además: una **AWS Access Key ID (`AKIA…`) sola NO es secreto**
  (lo sensible es la *secret* key); gitleaks correctamente no la marca.
- 🛠️ Fix: fixtures del lab ahora usan secretos que gitleaks **y** el grep cazan (github-pat, slack,
  private-key) → lab 8/8 verde con o sin tooling, validando detección real.

**Mejoras de proceso/tooling**
- Contrato del Contributor: en cambios numéricos exige test de **propiedad/borde** (NaN/vacío/datos
  grandes) + `// SAFETY:` en `unsafe`. Ataca 1,2,9 a nivel proceso.
- `bootstrap.sh`: añade `cargo-semver-checks` (reto 6) y documenta el deep-gate opt-in.

**Bug real del pipeline cazado al testear #3 (al añadir el caso al lab): pip-audit roto + tool-crash ≠ finding**
- ❌ Mal: el caso `risk-clean` con un `pyproject.toml` nuevo activó pip-audit en modo bloqueante, y
  **pip-audit crashea en esta máquina** (Python 3.14 + `defusedxml` incompatibles). El gate lo trató
  como fallo → rojo. El gate **no distingue "la herramienta encontró una vuln" de "la herramienta crasheó"**.
- 🛠️ Fix inmediato (lab): el manifiesto va en el commit base (no tocado por la rama) → SCA advisory
  → un crash de la herramienta no tumba el gate. Lab 10/10.
- ✅ **pip-audit ARREGLADO** (misma sesión): la causa raíz NO era pip-audit sino Homebrew
  `python@3.14` — su `pyexpat.so` referencia el símbolo `_XML_SetAllocTrackerActivationThreshold`
  en `/usr/lib/libexpat.1.dylib` (sistema, viejo) que no lo tiene → cualquier `xml.parsers.expat`
  crashea. Fix: `brew uninstall pip-audit` + `uv tool install pip-audit --python python3.12` (queda
  en `~/.local/bin`, primero en PATH). Verificado: encuentra 23 CVEs reales en `requests==2.19.0`
  y corre bloqueante en el gate sin crash. `bootstrap.sh` ahora instala pip-audit vía uv/pipx, NO brew.
- 🔎 Gap que SIGUE deferido: en modo bloqueante, un crash de herramienta SCA (infra) se confunde
  con "vuln encontrada". Mitigación futura: distinguir crash vs finding por exit-code, o marcar la
  herramienta como no-saludable. (→ gate, deferido)
- 🛠️ Regla: para herramientas Python del pipeline, **preferir uv/pipx sobre brew** — brew engancha
  el python@3.14 roto. Un tool "instalado" que crashea es peor que ausente (rojo espurio en bloqueante).

**Nuevo caso permanente en el lab:** `risk-scan` (diff con unwrap/unsafe/`as` → surfacea) y `risk-clean`
(diff limpio → "sin construcciones riesgosas"). Requirió un helper `build_wt_repo` (repo con bare
origin+rama) para que `diff_base` del gate resuelva. Lab pasó de 8 a **10 casos**.

**Meta-lección:** *testear el pipeline con retos hyper-experto encontró 3 bugs reales del propio
gate* (lockfile untracked, allowlist de gitleaks, tool-crash≠finding) que las rondas "aburridas"
nunca habrían tocado. Los tests fáciles confirman; los tests difíciles descubren.

---

## 2026-08-29 — R0: recon CI-parity + gate en modo paridad (T1, T2 verdes)

Arrancó el pre-lanzamiento (`LAUNCH-PLAN.md`). Construido `tools/recon.sh` (profile/find/issues/ci/t1)
y el modo `--parity` del gate.

**recon acierta el veredicto (T1 5/5)** contra ground truth conocido: SKIP por <100★ (sandbox) y por
archivado (angular.js); GO en ripgrep/coreutils/bat. Read-only, seguro sobre repos reales.

**El gate reproduce el CI del repo (T2), con un límite honesto**
- ✅ `--parity` parsea el `.github/workflows` local, extrae los comandos de verificación
  (`cargo fmt/clippy/test` en el sandbox) y los corre → reproduce Actions en ambos sentidos
  (main limpio→verde; violación de fmt→rojo). Verificado.
- 🔎 Límite: solo corre comandos **portables** (whitelist de herramientas conocidas, sin
  `${{ }}`/matrix/infra). Un CI con templating (ej. ripgrep usa `${{ env.CARGO }}`) cae al
  **fallback genérico** — no se puede replayear un CI arbitrario localmente, y pretenderlo sería
  frágil. La paridad real total es responsabilidad de abrir el PR y ver su CI; el gate da el 90%.
- 🛠️ Regla: preferir el task-runner del repo (make/just/pre-commit) cuando exista; sobre workflows,
  extraer solo lo portable y ser explícito sobre el fallback. (→ recon v2: detectar make/just/pre-commit)

---

## 2026-08-29 — R0: recon v2 (salud fina) + T3 (Agent C + rondas de review)

**recon v2 — señales finas que sí distinguen repos**
- ✅ Añadidas a `profile`: PRs mergeados en 30d, **merges de externos** (¿aceptan de fuera?), DCO
  (Signed-off-by), y **task-runner** (make/just/pre-commit). Ejemplo real: `uutils/coreutils` = 410
  merges/30d + 22 de externos + Makefile+pre-commit → candidato ideal; `ripgrep` = 2 merges/30d
  (maintainer cuidadoso) — la señal lo refleja. T1 sigue 5/5.

**T3 — la capa social funciona (con un límite de identidad honesto)**
- ✅ Loop completo con Agent C real: Contributor→PR #33 → Referee pide un nit (comentario) →
  Contributor lo atiende (2º commit, gate verde) → Referee LGTM + merge. Issue #32 cerrado, oráculo
  pasa. 1 ronda de review real ejercida.
- 🔎 Límite real: con **una sola cuenta**, GitHub no deja *aprobar formalmente* el propio PR
  (`--approve` bloqueado) → el referee aprueba por **comentario**. El loop es idéntico; solo cambia
  el mecanismo. La separación total (aprobación formal) necesitaría una 2ª cuenta.
- 🔎 Nota operativa: el subagente referee disparó un **security warning** al comentar en el PR bajo
  la identidad de Jorge — esperado y aceptable en el sandbox `Testing_Pipelines` (autorizado), pero
  es justo la fricción que en repos reales exige el **gate humano** (el accionista revisa/envía).
- 🛠️ Regla: crear `arena/agents/referee.md`; toda ronda futura puede incluir la capa de review. (→ arena)

---

## 2026-08-29 — R0: T4 (firma/DCO) + T5 (convenciones + declinar ambiguo)

**T4 — el mecanismo de firma + sign-off funciona**
- ✅ Commit firmado con llave SSH efímera ("Good signature" verificada localmente vía allowedSignersFile)
  **y** con `Signed-off-by:` (DCO, `git commit -s`). Config: `gpg.format=ssh` + `user.signingkey` + `commit.gpgsign`.
- 🔎 Gate humano: el badge "Verified" en GitHub necesita subir la **llave pública a la cuenta de Jorge**.

**T5 — convenciones seguidas y ambigüedad declinada**
- ✅ Enriquecí el sandbox (CONTRIBUTING.md + PR template) para que deje de ser "oráculo limpio".
  Actualicé el contrato del Contributor: sign-off + seguir CONTRIBUTING + **declinar issues de diseño**.
- ✅ El Contributor declinó el issue de diseño #34 ("¿API más ergonómica?", 3 propuestas incompatibles,
  sin criterio) citando CONTRIBUTING, pidió API/aceptación concretas y sugirió un primer paso acotado.
  **Sin PR, sin código.** Juicio correcto: programar sobre spec vaga es peor que no programar.

**Patrón recurrente → guardrail nuevo: agentes REDACTAN, accionista PUBLICA**
- 🔎 Los subagentes referee (T3) y contributor (T5) dispararon **security warnings** al comentar en
  GitHub bajo la identidad de Jorge. En el sandbox está autorizado, pero es la señal clara para repos
  reales: el agente **redacta** el comentario/PR y **el accionista lo publica**. Añadido a §7 del LAUNCH-PLAN.
- 🛠️ Regla: en R3 (real), toda escritura outward-facing (comentarios, PR) es *borrador* hasta el gate humano.

---

## 2026-08-29 — R1/T6: el dry-run REAL evitó un PR que dañaba la reputación

R1: shortlist de 5 repos GO (coreutils/fd/zizmor/brush/steel) con `recon.sh`. T6: dry-run en
`uutils/coreutils` #9060 ("improve code coverage de who/unix.rs"), **sin abrir PR, cero huella externa**.

**T6 funcionó — y su valor fue DECIR QUE NO**
- ✅ Ciclo completo local: clonar (22M) → entender `who/unix.rs` → añadir tests → build+test
  scoped (`cargo test -p uu_who --lib` → 2/2 verde) → **nada pusheado**.
- ❌ Pero el issue **NO era cómodo**, y solo se ve tras diligencia real:
  1. Los flags obvios (`-d`/`--dead`, `-a`/`--all`, etc.) **ya están testeados**.
  2. `who/unix.rs` es platform IO (utmpx) + i18n (`translate!`) + stdout → casi nada es pure-testable.
  3. La única función pura (`idle_string`) sí la testeé y **pasa**… pero el crate tiene
     **`[lib] test = false`**: coreutils **desactiva los unit tests de los utils a propósito** y solo
     prueba por integración. Mi unit test es **código muerto** para su CI → un maintainer lo rechaza.
  4. La cobertura restante necesita **fixtures de utmp** o comparaciones contra GNU-`who` (muchos
     tests existentes van `#[ignore]` por flaky). En macOS ni siquiera se puede verificar (BSD `who`).
- 🎯 **Ese es exactamente el propósito de T6 / R2:** un dry-run con diligencia real cazó una
  mala selección **antes** de que un PR saliera bajo la cuenta de Jorge. Un junior habría enviado el
  unit test y cosechado un rechazo. Costo del hallazgo: cero reputación.

**Reglas nuevas (selección + gate)**
- 🛠️ "Improve code coverage" es un **anti-patrón de selección**, sobre todo en módulos platform/FFI/IO.
  Antes de aceptar un issue de tests: ¿los paths obvios ya están cubiertos? ¿el repo unit-testea o solo
  integración (`grep 'test = false'`)? ¿la cobertura restante necesita fixtures/comparación flaky? (→ comfort profile)
- 🛠️ El gate `cargo test --all` **no escala a monorepos** (coreutils es enorme) → hace falta test
  **scoped** (`-p <crate>`), y para utils cross-platform la **verificación real es el CI del repo**, no local. (→ gate futuro)
- 🛠️ Regla dura: el **primer** PR real debe ser **mecánico e inequívoco** (docs con links rotos, un bug
  con repro claro), en un repo cuyas **convenciones de test verifiqué**. Pivotar #9060 → algo así.

---

## 2026-08-29 — T6 (2º intento) EXITOSO: servo/rust-smallvec #494

Tras descartar #9060, re-selección verificada → `smallvec #494` (impl `arbitrary::Arbitrary`).
Dry-run completo: seleccionar→verificar→clonar→**implementar** (portar v1→v2 `SmallVec<T,const N>`,
feature-gated como serde)→gate scoped→commit (Jorge + sign-off)→**PR borrador**. **Cero push.**

**El pipeline produjo una contribución real, limpia**
- ✅ Compila `--features arbitrary`, `test_arbitrary` pasa (67+ verde), `cargo fmt --check` limpio.
- ✅ Las lecciones de selección FUNCIONARON: verifiqué comentarios (no en curso), `test=false` (no),
  freshness (creado hoy, 0 competencia). El anti-patrón de #9060 no se repitió.
- ✅ **Seguridad diff-aware sobre una dep REAL:** añadir `arbitrary` a Cargo.toml → SCA lo detectó
  como "deps tocadas" y corrió `cargo audit` sobre él (sin vulns) → verde. Exactamente su propósito.

**Hallazgo nuevo del gate: el clippy genérico NO es diff-aware (deuda de lint ajena)**
- ❌ `cargo clippy -D warnings` (genérico) falló con 5 errores… **todos en código PRE-EXISTENTE de
  smallvec** (líneas 198/204/295/300/2736), ninguno en mi diff. Causa: mi clippy local es más nuevo
  que el toolchain fijado por el CI de smallvec → marca lints que su CI no marca.
- 🛠️ Regla: la etapa de calidad/lint sufre el mismo problema que SAST/SCA — **no bloquear por deuda
  de lint pre-existente del repo**. Mitigación: usar `--parity` (comando del repo) y, para lints
  toolchain-dependientes, **la verdad es el CI del repo** (toolchain fijado). Futuro: clippy diff-aware
  (solo fallar por lints en líneas cambiadas). (→ gate)
- 🔎 Confirma el patrón de T6: el gate da ~90% local; la verificación final de utils/crates reales es
  su **CI** (toolchain/plataforma fijados). Mi cambio es limpio; el "rojo" de clippy es ruido ajeno.

---

## 2026-08-29 — Cerrados los 2 gaps de T6 en el gate (clippy diff-aware + feature-aware)

**clippy diff-aware** (`added_lines()` + `clippy_diff_aware()`)
- ✅ El lint corre sin `-D warnings` (lista todo), y **bloquea SOLO si un hallazgo cae en las líneas
  que introdujo el diff** (`comm` de las ubicaciones de clippy vs `added_lines`); la deuda pre-existente
  del repo se reporta como informativa. Verificado en smallvec: "tu diff limpio; 34 pre-existentes, no bloquean" → **GATE OK** (antes ROJO).
- 🛠️ Mismo principio que SAST/SCA: la seguridad Y la calidad son diff-aware; nunca bloquear por deuda ajena.

**feature-aware** (`diff_features()`) — y por qué NO `--all-features`
- ❌ Primer intento: `--all-features`. Rompió en smallvec porque activa features **nightly**
  (`specialization`, `may_dangle`) que no compilan en stable. `--all-features` es una **trampa** en
  repos con features nightly o mutuamente excluyentes.
- ✅ Fix correcto: `diff_features()` parsea el `[features]` del `Cargo.toml` en el diff y prueba SOLO
  con la feature que **nuestro cambio introdujo** (`arbitrary`). Así se compila/testea/lintea el código
  feature-gated que añadimos, sin tocar el resto. Verificado: build+test `--features arbitrary` verde.
- 🛠️ Regla: probar exactamente lo que el diff activa, no "todo". Menos y más preciso.

**No-regresión:** sandbox statkit (sin features → default) GATE OK; `pipeline-lab` 10/10.

---

## 2026-08-29 — Primer review real (smallvec #496): 3 nits → 3 reglas

El maintainer (@alejandro-vaz) revisó #496: **"looks good"** al impl, con 3 nits (CHANGES_REQUESTED,
no rechazo). Los atendí (rebase + cambios + comentario). Herramienta `pr_retrospective.sh` los surfaceó.

- 🔎 **Feature redundante:** declaré `arbitrary = ["dep:arbitrary"]` en `[features]`, pero una **dep
  opcional ya crea su feature homónima**. → No declarar `feature = ["dep:X"]` cuando la dep se llama X.
- 🔎 **Convención de test cambió bajo mis pies:** puse un unit test inline, pero el repo **acababa de
  mover TODO a tests de integración** (#495, mergeado justo antes). → Re-chequear la convención de test
  del repo **al momento de codear** (no asumir); aquí el patrón es `[[test]] required-features`.
- 🔎 **Orden de deps:** mantener el `[dependencies]` ordenado. Nit de estilo, fácil de respetar.
- 🛠️ Regla (→ contributor.md): antes de tocar Cargo.toml, mirar cómo el repo declara features/deps/tests
  **recientes** y copiar ese patrón exacto. "El repo manda" también en los detalles de empaquetado.
- 🎯 Meta: `pr_retrospective.sh` funciona para reviews, no solo rechazos — me avisó del review que no había visto.

## 2026-08-29 — 🟢 PRIMER MERGE (smallvec #496) + 🔴 cierre por POLÍTICA DE IA (#500)

Doble evento el mismo día, decisivo para la estrategia.

**✅ #496 (arbitrary::Arbitrary) — MERGEADO** por @alejandro-vaz (23:36 UTC). Primer merge real bajo la
cuenta del accionista → pasa el gate F0. Qué salió bien: selección de repo sano, impl pedido explícitamente,
atención rápida y limpia de los 3 nits del review.

**🔴 #500 (try_with_capacity) — CERRADO sin merge** (23:53 UTC), por DOS motivos:
- 🔎 **Causa raíz 1 — social/política (la grave):** *"AI contributions are not allowed in any @servo
  repository"* (book.servo.org/.../ai-contributions). **Servo prohíbe contribuciones de IA.** #496 alcanzó
  a mergear antes de que el maintainer lo notara; #500 lo cerró citando la política. → **Todo servo queda
  vetado.** Insistir ahí no suma reputación: la resta (riesgo de quedar marcado como cuenta que ignora reglas).
- 🔎 **Causa raíz 2 — código/correctitud:** mi `try_with_capacity` delegaba en `try_grow`, que reverifica
  estado (¿spilled?, ¿len?) innecesariamente. Lo correcto: asignar directo sabiendo que arranca vacío/inline.
  Lección técnica válida aunque el PR se cerró por la política.

**🛠️ Reglas resultantes:**
- **(→ SOUL §5 + `recon.sh`) Verificar la política de IA del repo/org ANTES de seleccionar.** Es ahora el
  PRIMER filtro duro (junto a archivado). `recon profile` añade el campo `🤖 política IA` y hace SKIP ante
  prohibición explícita. Limitación honesta: políticas en un *book*/URL externa (como servo) no se
  autodetectan → el campo fuerza verificación humana ("VERIFICAR la guía/book").
- **(→ selección) Preferir repos con política de IA *explícitamente permisiva*** (p.ej. uutils: *"AI-assisted
  contributions are allowed, but the same standards apply"* + no derivar de código GPL). Ahí la contribución
  suma sin ambigüedad.
- 🎯 El pivote a **uutils/sed** (C003) resultó ser el objetivo correcto: política pro-IA verificada, y la
  implementación se escribió desde el código propio (MIT) de uutils + comportamiento *documentado* de GNU,
  no de la fuente GPL → cumple la condición anti-GPL.

---

### 2026-08-30 · yt-dlp (patch-available #16865) — ❌ VETADO por NO AI/LLM policy (reincidencia del filtro 0)

Elegí el issue **#16865 (abcotvs: bajar hqMp4 720p si existe)** de la veta `patch-available` de yt-dlp
(187k★): patch limpio, uncontested, y **verificable en vivo** (6abc.com accesible). Lo implementé bien
(idiom `HEADRequest` de cbc.py en vez del probe GET del reporter) y lo **verifiqué en ambos casos**:
hqMp4 vivo (200) → ofrece 720p y descarga MP4 válido; hqMp4 muerto (403) → lo descarta, cae a 360p. ruff ✓.

**❌ Por qué NO se envía:** al armar el PR descubrí que **yt-dlp tiene "NO AI / NO LLM POLICY" estricta**
(CONTRIBUTING.md) y el template de PR **obliga a atestiguar** cumplimiento. Es el **caso servo otra vez**:
enviar trabajo asistido por IA marcando esa casilla = **atestación falsa** bajo la cuenta del accionista →
riesgo de flag/ban → **resta reputación**. Trabajo verificado y correcto, pero **inenviable por nuestro pipeline**.

- 🔎 **Causa raíz — proceso (no técnica):** verifiqué la política de IA **al armar el PR**, no **al seleccionar**.
  Perdí ~1 ciclo implementando algo invendible. El `recon profile` surfacea `🤖 política IA` pero **no lo corrí
  antes de clonar** — salté directo del issue al código por ser "quick win".
- 🛠️ **Regla dura reforzada:** para CUALQUIER repo nuevo, el **primer** paso — antes de clonar/leer código — es
  `grep -riE "\bAI\b|LLM|generated" CONTRIBUTING.md .github/` (o `recon profile`). Si prohíbe IA → **STOP inmediato**,
  ni se clona. yt-dlp añadido a la lista de veto en SOUL §5 (junto a servo).
- 🧭 **Señal de selección:** las vetas grandes y atractivas (yt-dlp `patch-available`) pueden estar **envenenadas
  por política**. Un repo puede ser welcoming a humanos y hostil a IA a la vez. Estrellas ≠ compatibilidad con el pipeline.

---

### 2026-08-30 · scikit-image #7921 (pyramid_laplacian) — 🔴 CERRADO por señal social/política (no calidad)

Implementé el fix Burt-Adelson **correcto** (reconstrucción a 1e-16, validado en gris/color/rectangular,
ruff verde). PR #8306 abierto con divulgación de IA. @stefanv (maintainer core) lo **cerró**: el issue es
"close to my heart", lo estudia con @elena-pascal, tienen su propia solución, y ya había **cerrado un PR
previo idéntico (#8274) por su política de IA** (exige entendimiento profundo, no PR asistido por IA en su
área personal). Repliegue cortés + cierre (goodwill con maintainer core > este merge).

- 🔎 **Causa raíz — selección (2 fallos):** (1) **no revisé PRs CERRADOS del issue** — #8274 (cerrado semanas
  antes, mismo enfoque, misma razón) era la señal exacta; solo miré PRs abiertos. (2) Leí "fix ASAP" de
  stefanv como "quiere contribución" cuando significaba "yo estoy en esto".
- 🛠️ **Reglas (→ SOUL §5 / filtro de selección):**
  - **Antes de codear: `gh pr list --repo R --search "#N" --state closed`** — un cierre reciente con el mismo
    enfoque = decisión del maintainer, no oportunidad.
  - **Señal "maintainer lo trabaja él":** "close to my heart", "studying with X", "we know how it should look"
    = área personal → NO tomar (como copper-rs #1255). "ASAP" de un maintainer ≠ "contribuye tú".
  - En repos con política de IA de "deep understanding" (scikit-image), preferir issues **mecánicos/objetivos**
    sobre los "de investigación" del maintainer.
- ✅ **Bien:** el repliegue fue inmediato y cortés (ofrecí el test de reconstrucción, reconocí el traslape) →
  preserva la relación para futuras contribuciones. La calidad del fix no estaba en duda; fue puramente social.

---

### 2026-08-30 · airi #2366 (TTS multi-byte) — 🟡 fix en ARCHIVO MUERTO, cazado por review de Codex

Arreglé el bug de corrupción de TTS (descarte de grapheme clusters `value.length > 1`) en
`packages/stage-ui/src/utils/tts.ts` con test que fallaba sin el fix (gate verde) y abrí PR #2414.
La review automática de **Codex (bot)** marcó P1: ese archivo **no lo importa nadie** — el chunker vivo
(el que usa `createSpeechPipeline` en Stage.vue) es `packages/pipelines-audio/src/processors/tts-chunker.ts`,
una **copia duplicada** con el mismo bug intacto. Mi PR no arreglaba nada del path real.

- 🔎 **Causa raíz — código/comprensión:** verifiqué la causa raíz y reproduje el bug (bien), pero **asumí que
  el archivo que edité era el activo** sin comprobar sus importadores. Había DOS chunkers casi idénticos
  (`chunkTTSInput` muerto vs `chunkTtsInput` vivo — hasta el nombre cambia por una letra).
- 🛠️ **Regla dura (→ ponytail / quality-gate):** antes de dar por bueno un fix, **`grep -rn "<símbolo>|from '<ruta>'"`
    de los importadores** para confirmar que el archivo tocado está en el **path vivo**. Un test que pasa sobre
    código muerto es un falso verde. "El test falla sin el fix" NO basta si el fix vive en código no ejecutado.
- 🛠️ **Señal:** monorepos con paquetes que se refactorizaron (aquí `stage-ui/utils` → `pipelines-audio`) dejan
    **duplicados legacy**. Nombre casi-idéntico = trampa. Buscar la copia viva por el consumidor real (Stage.vue),
    no por el nombre del símbolo.
- ✅ **Bien:** respuesta inmediata al review — moví el fix al chunker activo, revertí el muerto, test en su suite
    (17/17, falla sin fix), y agradecí el catch. El **review adversarial del bot agregó valor real** (como
    CodeRabbit en RustPython): no defenderse, verificar y corregir.

---

### 2026-08-30 · openai/openai-agents-python #4774 (UTF-8 en PTY) — 🔴 CERRADO por rediseño en curso del maintainer

Bug real (corrupción UTF-8 al partir un carácter multibyte entre ventanas de colección de PTY). Fix + test,
pero Codex marcó **P1 sucesivos**: decoder incremental → path de Modal sin cubrir → tail durable en
cancelación. Iteré **4 commits** persiguiendo cada uno. @seratch (maintainer) lo **cerró**: el fix aún perdía
el prefijo en cancelación y **la carrera de ownership completion/finalizer seguía**; y sobre todo, *"we are
consolidating this lifecycle work in **#4738**"* (su propio PR abierto). Cierre por **duplicación + arquitectura**.

- 🔎 **Causa raíz — selección/timing (2 señales que ignoré):**
  1. **"Maintainer lo trabaja él"** (como copper-rs #1255, scikit-image #8306): había un PR abierto (#4738,
     de @seratch) consolidando el **mismo subsistema**. No busqué PRs abiertos que lo tocaran antes de invertir.
  2. **Fix que exige rediseño de ownership, no diff localizable.** El bug no era el boundary UTF-8 sino el
     ciclo de vida (decoder state + completion + cancelación + remoción de entry) bajo un solo dueño. El
     **whack-a-mole con Codex** (P1 nuevo tras cada commit en la misma zona) *era* la señal de que la causa
     es arquitectónica y el patch no pertenece a esa capa.
- 🛠️ **Reglas (→ SOUL §5):**
  - Antes de codear un bug de subsistema: **`gh pr list --state open --search "<subsistema>"`** — un PR
    abierto del maintainer consolidando el área = **cerrarán tu duplicado**.
  - **Veto:** bug cuyo fix correcto reorganiza ownership/ciclo de vida de varios componentes. Si el bot sigue
    hallando P1 en la misma zona tras cada fix → **step back**, no seguir parcheando.
  - Reforzar señal de repo ya conocida (el propio C008 la marcó): **core-driven + swarmed** (5/30 externos,
    bugs tomados en horas) sube el riesgo de que el core ya lo esté resolviendo internamente.
- ✅ **Bien:** respuestas técnicas, honestas y rápidas a cada P1; el cierre fue por arquitectura/duplicación,
    **no** por calidad de comunicación ni de código superficial. Relación con OpenAI preservada. El costo fue
    de *selección* (~4 commits en algo invendible), exactamente lo que el North Star penaliza.

---

### 2026-09-01 · Ronda «10 quick wins / 10 repos» (batch C026) — 6 verdes, 4 descartados en filtro-0

Fan-out de 10 sub-agentes (uno por repo nuevo) con el mismo contrato: filtro-0 IA → reproducir →
fix mínimo + test que falla-sin-fix → gate → commit local (sin push). Resultado: **6 READY**
(numbat, onefetch, jq, yq limpios; git-cliff, gum con caveat social), **4 descartados**.

- ✅ **Bien — el filtro-0 pagó antes de clonar:** 2 de los 4 descartes se cazaron **leyendo CONTRIBUTING**
  antes de escribir una línea: **lazygit** (*"does not accept pull requests"* + veta IA) y **ripgrep**
  (prohíbe **agentes autónomos**, aunque permite IA como herramienta). El costo de descartarlos fue ~0.
- ✅ **Bien — «maintainer ya triió» como señal de descarte temprano:** **ripgrep #3070** (BurntSushi:
  *"working as intended... the fix is a massive refactoring"*) y **textual #4968** (diseño **sin decidir**,
  el owner defiende el comportamiento actual). Ambos: leer **el hilo completo del issue** reveló un
  veredicto del maintainer que hace P(merge)≈0. Un sub-agente que **no adivina** y reporta BLOCKED
  vale más que uno que produce un fix invendible.
- ✅ **Bien — endorsement previo del maintainer como señal verde:** los 2 fixes más fuertes (**numbat**,
  **onefetch**) tenían al maintainer/collaborator **ya proponiendo exactamente ese enfoque** en el hilo.
  Buscar "¿el maintainer ya dijo cómo lo quiere?" ordena la cola de P(merge) *antes* de codear.
- ❌ **Riesgo — caveat social no es caveat de código:** git-cliff y gum tienen fix correcto pero
  el maintainer tiene **dirección/dueño preferido** (refactor holístico + voluntario; label `blocked` +
  ruta upstream). Enviarlos sin reconocer eso quema reputación aunque el diff sea impecable.
- 🔎 **Causa raíz (de los 4 descartes):** todos evitables leyendo **CONTRIBUTING + hilo completo del issue**
  antes de seleccionar — que es justo el filtro-0 / SOUL §5. La ronda validó el filtro, no lo contradijo.
- 🛠️ **Reglas (→ SOUL §5 / plantilla de selección):**
  1. **Antes de clonar:** grep en CONTRIBUTING/README de `pull request` + `AI`/`autonomous`/`agent`.
     Distinguir **veta-IA total** vs **veta-agentes-autónomos** vs **exige-disclosure** (3 políticas distintas).
  2. **Antes de codear:** leer el **hilo entero** del issue → si el maintainer dijo "working as intended",
     "consolidando en #X", o "diseño sin decidir" → BLOCKED, no fix.
  3. **Ordenar la cola por endorsement:** issues donde el maintainer **ya propuso el enfoque** primero.
  4. **Caveat social explícito** en el PR cuando el maintainer tiene dirección/dueño preferido; o esperar.
- ✅ **Bien — disciplina de no-push:** los 6 fixes quedaron en local (rama+commit por repo), **0 PRs**
  hasta orden explícita por operación. El registro (C026) es **un** artefacto, no 10 dossiers (ponytail).
