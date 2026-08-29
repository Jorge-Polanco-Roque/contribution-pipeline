# NOTES.md — Bitácora del laboratorio del pipeline

Cómo correr: `bash pipeline-lab/run.sh` (construye fixtures efímeros, corre el gate,
asevera exit/contenido, deja logs en `results/`). Secretos = ejemplos sintéticos.

---

## Iteración 1 — 2026-08-29

**Setup:** 8 fixtures (6 seguridad + 2 detección). En este Mac: git/cargo/npm/node/
python presentes; todo el tooling de seguridad ausente → secretos vía fallback grep,
SCA/SAST omitidos.

**Resultado:** 6/8 ok, **2 fallos** — ambos falsos negativos de seguridad (críticos):

| Caso | Esperado | Obtenido | Diagnóstico |
|---|---|---|---|
| `sec-untracked` | 🔴 rojo (secreto en archivo sin `git add`) | 🟢 verde | `git grep` por defecto **solo mira archivos trackeados** → ignora untracked |
| `sec-nongit` | 🔴 rojo (secreto en carpeta no-git) | 🟢 verde | `git grep` falla fuera de repo; el `\|\| true` **se traga el error** → pasa en falso |

**Por qué importa:** un pre-submit real corre sobre cambios *nuevos* (archivos recién
creados, aún no commiteados) y a veces sobre carpetas que no son el repo. En ambos
escenarios el gate daba luz verde con un secreto presente. El caso más peligroso
posible en un scanner de secretos: **el falso negativo silencioso.**

**Los 6 que pasaron** (útil como base de no-regresión): secreto commiteado en AWS key,
private key y GitHub token → rojo ✓; repo limpio → verde ✓; stack desconocido → exit 2 ✓;
multi-stack (python+node) detectado ✓.

**Fix decidido (causa raíz, un solo lugar):** en el fallback de `secrets_scan`:
1. Si es repo git → `git grep --untracked --exclude-standard` (cubre trackeados +
   untracked no-ignorados).
2. Si NO es repo git → `grep -rnIE` directo, saltando dirs pesados.
Patrón de secretos extraído a una sola variable `SECRET_RE` (DRY, sin duplicar).

**Deferidos (anotados, no urgentes):**
- `pytest -q` sin tests devuelve exit 5 → posible falso positivo en repos python sin
  suite corrida aún. Revisar en una iteración futura.
- `npm audit` sin lockfile falla → ruido; hacerlo advisory salvo vulnerabilidad real.
- Rama `gitleaks` no verificable aquí (ausente): idealmente escanear también el árbol
  de trabajo (`--no-git`), no solo el historial. Verificar al instalar gitleaks.

---

## Iteración 2 — 2026-08-29

**Fix aplicado** en `tools/pre_submit.sh` (`secrets_scan`):
- Patrón extraído a `SECRET_RE` (una sola definición, DRY).
- Repo git → `git grep --untracked --exclude-standard` (atrapa archivos nuevos sin `git add`).
- Carpeta no-git → `grep -rnIE` directo, saltando `.git/node_modules/target/dist/build/vendor/.venv`.
- Bonus (no verificable aquí): rama `gitleaks` ahora hace 2 pasadas — historial (`detect`)
  y árbol de trabajo (`detect --no-git`) — para cubrir cambios sin commitear.

**Resultado:** **8/8 ok, 0 fallos.** Los 2 falsos negativos quedaron cerrados y los 6
casos base no regresaron. `--check` del gate sigue verde.

**Estado del laboratorio:** `run.sh` queda como **suite de no-regresión** del pipeline.
Correrlo antes de tocar `pre_submit.sh` en el futuro. Próximos casos a añadir cuando
se instale tooling: SCA diff-aware (vuln introducida por nosotros vs pre-existente),
falso positivo de `pytest` exit 5, y `npm audit` sin lockfile.
