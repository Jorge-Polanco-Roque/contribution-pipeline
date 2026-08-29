# PIPELINE.md — Repos e issues objetivo

> Lista viva de repos sanos en nicho y sus issues candidatos, puntuados. Los
> mejores suben a `active/`; los descartados bajan a `passed/` con su razón.
> Objetivo: **reputación** (PRs mergeados en repos respetados), no dinero.

_Última actualización: 2026-08-29._

## Cómo se selecciona (resumen de SOUL §5)

`P(merge) × valor-de-reputación-del-repo ÷ horas`. Un merge en un repo respetado
vale más que tres en repos muertos. Prioridad: **salud del repo → issue con causa
raíz clara → nicho fuerte**.

## Realidad del terreno (aprendido)

- **No perseguir dinero ni "bounties":** Algora murió como board (pivoteó a
  reclutamiento) y su ecosistema atrae *honeypot forks* (forks falsos de repos
  famosos por usuarios random) y pozos inflados. **Nunca contribuir a un fork
  random ni a un repo sin historial de merges de externos.**
- **La reputación se gana en repos serios y activos:** maintainer que mergeó algo
  en <30 días, CI verde, `CONTRIBUTING.md` claro, y PRs de terceros aceptados.
- **`good first issue` / `help wanted`** son la puerta natural: el maintainer ya
  señaló que acepta ayuda externa ahí.

## Cómo cazar issues sanos (fuentes)

| Fuente | Qué da | Cómo |
|---|---|---|
| GitHub search | issues por label + recencia + repo activo | `label:"good first issue" state:open` en repos del nicho, filtrar por estrellas y actividad |
| `github.com/topics/<nicho>` | repos vivos por tema (rust, machine-learning, gamedev…) | ordenar por recién actualizados |
| Repos que ya usamos | contexto previo = ventaja | contribuir donde conocemos el codebase |

> El heredado `tools/scan_bounties.sh` (recencia + competencia) puede repurposarse
> a scan de issues cuando definamos los repos objetivo. Por ahora, YAGNI.

## Shortlist R1 (recon en frío, 2026-08-29) — perfilados con `recon.sh`, todos GO ≥100★

| # | Repo | ★ | Merges/30d · externos | Task-runner | Nicho | Por qué |
|---|---|---|---|---|---|---|
| 1 | **uutils/coreutils** | 24k | **410 · 22** | Makefile+pre-commit | infra/CLI | el más activo y acogedor; issues bien especificados (GNU = spec) → **target de T6** |
| 2 | sharkdp/fd | 44k | 11 · **18** | Makefile | infra/CLI | muy popular y acogedor a externos |
| 3 | zizmorcore/zizmor | 6.4k | **64** · 11 | Makefile | devtools/seguridad | muy activo, nicho afín |
| 4 | reubeno/brush | 2.2k | 25 · 9 | — | infra/shell | activo, specs claras (bash conocido) |
| 5 | mattwparas/steel | 2.5k | 6 · 9 | — | lenguajes/Rust | sano, más chico |

> Todos pasan el filtro duro (≥100★, no archivado, no fork, activo, merges de externos). Antes de
> tocar cualquiera: re-perfilar (`recon.sh profile`) y elegir issue del *comfort profile* (LAUNCH-PLAN §3).

## Candidatos T6 verificados (2026-08-29) — tras descartar #9060

Verificación aplicada a cada uno: mecánico? · sin asignar/no en curso (revisar comentarios)? ·
repo GO ≥100★? · **convención de test** (`grep 'test = false'`) · feasible en local?

| Candidato | Mecánico | Estado | Repo (salud) | test=false | Veredicto |
|---|---|---|---|---|---|
| **servo/rust-smallvec [#494](https://github.com/servo/rust-smallvec/issues/494)** — impl `arbitrary::Arbitrary` | ✅ patrón conocido, acotado | **creado hoy, 0 coment, sin asignar** | GO (1.7k★, 28/30d) | **no** (unit tests cuentan) | ⭐ **TARGET T6** |
| reubeno/brush [#183](https://github.com/reubeno/brush/issues/183) — warn en exit si hay jobs suspendidos | ~ (comportamiento bash, algo de matiz en comentarios) | sin asignar, 3 coment (discusión del alcance) | GO (2.2k★, 25/30d) | no | alterna |
| ~~zizmor #1252~~ (mensaje de error) | ✅ | ❌ **ya en curso** (PRs #1609/#1730, maintainer molesto) | GO | — | ⛔ SKIP |
| ~~coreutils #9060~~ (coverage) | ❌ | — | GO | **sí** (unit tests muertos) | ⛔ SKIP (T6 lo cazó) |

**Recomendación:** `servo/rust-smallvec #494` como nuevo **target de T6** — fresco, sin competencia,
repo sano, convención de test sana, y `Arbitrary` es un impl mecánico bien definido (feature-gated).

> Lección de selección aplicada: **revisar comentarios por "ya lo estoy trabajando"** (así se cazó
> zizmor #1252) y **`grep 'test = false'`** antes de codear (así se explica #9060). Docs-GFI puros
> escasean en los repos top ahora mismo — de ahí que el mejor candidato sea un impl acotado, no docs.

## Próximo paso

Ejecutar **T6** (tras visto bueno del accionista sobre el issue): resolver #9060 en local, gate en
modo `--parity`, dejar el PR **como borrador SIN abrir**, y que el accionista revise.
3. Primer issue acotado con causa raíz clara → `active/C001-slug.md` desde `_TEMPLATE.md`.
