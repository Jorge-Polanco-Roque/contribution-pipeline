# C025 — uutils/findutils — `-mindepth` > `-maxdepth` imprime de más

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#857](https://github.com/uutils/findutils/pull/857)) — esperando review |
| Nicho | Rust / devtools (uutils, compat GNU) |
| Salud del repo | ✅ GO (recon) — 642★, activo, **25/30 externos** (muy welcoming) |
| Stack | Rust |
| Origen | bug #778 «find: when -mindepth greater than -maxdepth it outputs files, even if must not» (`good first issue`, 0 comentarios) |
| PR URL | **https://github.com/uutils/findutils/pull/857** |
| Issue | https://github.com/uutils/findutils/issues/778 |
| Política IA | ✅ uutils permisivo (solo prohíbe derivar de código GPL) |
| Estimación | P(merge) **alta** (good-first-issue, bug GNU-compat claro, test que falla sin fix, repo welcoming) · +30/−0 |
| Fechas | seleccionado 2026-09-01 · PR 2026-09-01 · merge — |

## Causa raíz (reproducida)
`process_dir` pasa `min_depth`/`max_depth` a `WalkDir`. Cuando `min > max`, `WalkDir` **no** produce el conjunto vacío — clampa el rango y aún yield-ea las entradas de max-depth. Repro: `find . -mindepth 2 -maxdepth 1` → `./a ./f0` (GNU: vacío).

## Solución
Guard en `process_dir`: si `config.min_depth > config.max_depth` → `return 0` (nada matchea, como GNU). +30/−0.

## Gate (calidad) — VERDE
- **Test** `find_mindepth_greater_than_maxdepth` → pasa; **FALLA sin el fix** (imprime las entradas de max-depth) ✓.
- **cargo fmt --check** OK · **clippy** sin warnings · **filtro 0 IA** ✓.
- Verificado empíricamente: min>max→vacío; casos normales (min1/max2, min==max) intactos.

## Selección (quick win)
Buscando quick wins tras pausar airi: findutils (uutils) tiene filón de bugs GNU-compat (mismo patrón que sed C003/coreutils C007). #778 = good-first-issue, sin reclamar, causa localizada, testeable. Backups: findutils #777/#780, procps #665.

## Commit
- `fix(find): output nothing when -mindepth exceeds -maxdepth` (identidad Jorge). PR con "allow edits by maintainers" (default de fork; lección unavatar #660).

## Acción del accionista
PR #857 bajo tu cuenta. Siguiente: responder review cuando llegue.

## Bitácora
- 2026-09-01: seleccionado #778 (quick win uutils/findutils). Reproducido el bug, fix (guard en process_dir),
  test de regresión que falla sin el fix, fmt/clippy limpios. PR #857 abierto. **Diversificación exitosa** a
  un repo nuevo con filón de quick wins.
