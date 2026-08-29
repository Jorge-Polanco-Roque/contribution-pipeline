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
