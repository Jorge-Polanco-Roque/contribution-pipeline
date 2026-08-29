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

## Repos objetivo (nicho fuerte)

| # | Repo | Nicho | Salud (maintainer/CI) | Issue candidato | Estado |
|---|---|---|---|---|---|
| — | *(pendiente definir 2–3)* | — | — | — | — |

## Próximo paso

1. Elegir 2–3 repos sanos en nicho (Rust / ML-CV / gamedev / infra-devtools).
2. Instalar tooling de seguridad opcional para el gate (`gitleaks`, `cargo-audit`/
   `govulncheck`/`pip-audit`, `semgrep`).
3. Primer issue acotado con causa raíz clara → `active/C001-slug.md` desde `_TEMPLATE.md`.
