export const meta = {
  name: 'arena-round',
  description: 'Ronda completa del arena en un comando: siembra N bugs independientes, los arregla en paralelo (worktrees) y mergea, con no-regresión cruzada',
  phases: [
    { title: 'Seed', detail: 'Reporter siembra N bugs independientes + issues + oráculos' },
    { title: 'Prep', detail: 'referee: run.sh prep-parallel (oráculos fallan + worktrees)' },
    { title: 'Fix', detail: 'N Contributors en paralelo, cada uno en su worktree aislado' },
    { title: 'Finalize', detail: 'referee: run.sh finalize-parallel (oráculo+CI+merge+cross-regresión+score)' },
  ],
}

const T = '/Users/antm/Desktop/AnatemaBot/test002'
const SANDBOX = '/Users/antm/Desktop/AnatemaBot/sandbox-Testing_Pipelines'
const RUN = `bash ${T}/arena/run.sh`
const N = (args && args.n) ? args.n : 2

const SEED_SCHEMA = { type:'object', additionalProperties:false, required:['bugs'], properties:{
  bugs:{ type:'array', items:{ type:'object', additionalProperties:false, required:['issue','slug','file'],
    properties:{ issue:{type:'number'}, slug:{type:'string'}, file:{type:'string'} } } } } }
const PREP_SCHEMA = { type:'object', additionalProperties:false, required:['ok'], properties:{ ok:{type:'boolean'}, detail:{type:'string'} } }
const FIX_SCHEMA  = { type:'object', additionalProperties:false, required:['decision'], properties:{
  decision:{type:'string'}, pr:{type:['number','null']}, branch:{type:'string'}, gate:{type:'string'}, root_cause:{type:'string'} } }
const FIN_SCHEMA  = { type:'object', additionalProperties:false, required:['merged'], properties:{
  merged:{type:'boolean'}, cross_regression:{type:'string'}, detail:{type:'string'} } }

// ---- Phase 1: Reporter siembra N bugs independientes ----
phase('Seed')
const seed = await agent(
`Eres Agent A (Reporter) del arena. Lee tu contrato: ${T}/arena/agents/reporter.md.
Sandbox: ${SANDBOX} (sincronízalo a main primero). GitHub: Jorge-Polanco-Roque/Testing_Pipelines.
Catálogo de oráculos: ${T}/arena/catalog/.
Siembra ${N} bugs INDEPENDIENTES en archivos DISJUNTOS (fixes en archivos separados; el único
compartido permitido es lib.rs solo para declarar módulos nuevos). Usa funciones/módulos NUEVOS;
NO reuses funciones ya arregladas antes (mean/median/variance/percentile/stddev/midrange/min_max/
Quartiles/mode/skewness/argmin). Cada bug: determinista, dificultad media, LATENTE (tests que
acompañen quedan verdes; el defecto no cubierto).
Para cada bug: introdúcelo, escribe su hidden test en el catálogo con slug propio (que FALLE con el
bug), y crea su issue con gh (solo síntoma + criterio de aceptación; sin revelar causa/fix/módulo).
Requisito duro: tras sembrar los ${N}, cargo test --all + cargo fmt --all -- --check + clippy
-D warnings VERDES en main. Verifícalo. Luego commit + git push origin main.
Devuelve el objeto {bugs:[{issue, slug, file}, ...]} con exactamente ${N} entradas.`,
  { schema: SEED_SCHEMA, label: 'reporter', phase: 'Seed' })

const bugs = (seed && seed.bugs) ? seed.bugs : []
if (bugs.length === 0) throw new Error('Reporter no devolvió bugs')
const slugs = bugs.map(b => b.slug)
log(`Sembrados ${bugs.length}: ${slugs.join(', ')}`)

// ---- Phase 2: Prep (referee, determinista vía run.sh) ----
phase('Prep')
const prep = await agent(
`Eres el referee del arena. Corre EXACTAMENTE este comando y NADA MÁS:
  ${RUN} prep-parallel ${slugs.join(' ')}
Verifica su salida: debe decir que cada oráculo FALLA en main y que se crearon los worktrees.
Devuelve {ok:true, detail:"..."} si todo salió bien (todos los oráculos fallaron + worktrees creados),
o {ok:false, detail:"qué falló"} si no.`,
  { schema: PREP_SCHEMA, label: 'prep(referee)', phase: 'Prep' })
if (!prep || !prep.ok) throw new Error('prep-parallel falló: ' + (prep && prep.detail))

// ---- Phase 3: Fix (N Contributors en paralelo, worktrees aislados) ----
phase('Fix')
const fixes = await parallel(bugs.map(b => () =>
  agent(
`Eres Agent B (Contributor) del arena. Lee tu contrato: ${T}/arena/agents/contributor.md.
Entorno AISLADO: trabajas EXCLUSIVAMENTE en /tmp/wt-${b.slug}. Gate: bash /tmp/gate.sh /tmp/wt-${b.slug}.
GitHub: Jorge-Polanco-Roque/Testing_Pipelines. Issue: #${b.issue}.
AISLAMIENTO (duro): única fuente = gh issue view ${b.issue} + el código en /tmp/wt-${b.slug}.
PROHIBIDO leer ${T}/arena/ o cualquier pista externa.
El worktree está en HEAD detached sobre origin/main. Crea rama fresca, localiza la causa raíz,
fix mínimo + test de regresión que falle sin el fix, corre el gate hasta VERDE, commit (identidad
Claude ya en config), git push -u origin <rama>, y gh pr create con "Fixes #${b.issue}". Gate rojo ⇒
NO abras PR. Solo tocas archivos de este issue.
Devuelve {decision:"fixed"|"declined", pr:<número o null>, branch:"...", gate:"...", root_cause:"..."}.`,
    { schema: FIX_SCHEMA, label: `fix:${b.slug}`, phase: 'Fix' })
    .then(r => r ? ({ ...r, slug: b.slug, issue: b.issue }) : null)
))
const merged = fixes.filter(Boolean).filter(f => f.decision === 'fixed' && f.pr)
log(`Fixes listos: ${merged.map(f => `${f.slug}#${f.issue}→PR${f.pr}`).join(', ')}`)
if (merged.length === 0) throw new Error('Ningún Contributor produjo PR')

// ---- Phase 4: Finalize (referee, determinista vía run.sh) ----
phase('Finalize')
const specs = merged.map(f => `${f.slug}:${f.issue}:${f.pr}`).join(' ')
const fin = await agent(
`Eres el referee del arena. Corre EXACTAMENTE este comando y NADA MÁS:
  ${RUN} finalize-parallel ${specs}
Verifica su salida: cada oráculo debe PASAR en su rama, CI verde, merge, issues cerrados, y la
no-regresión cruzada verde ("todos los fixes coexisten"). Devuelve {merged:true, cross_regression:"pass"|"fail",
detail:"..."} según el resultado.`,
  { schema: FIN_SCHEMA, label: 'finalize(referee)', phase: 'Finalize' })

return {
  seeded: bugs.length,
  slugs,
  fixed: merged.length,
  prs: merged.map(f => f.pr),
  finalize: fin,
}
