# Round 004 — review (dificultad+ cross-módulo)

- **Reporter** refactorizó `statkit` a 4 módulos (lib/measures/bounds/summary) y sembró un
  bug **cross-módulo**: `Quartiles::of` (bounds.rs) invertía el par (lower/upper); el síntoma
  emergía en `Summary::of` (summary.rs) como q1>q3 e iqr negativo. Cruza measures→bounds→summary.
  Latente: 13 tests verdes en main.
- **Contributor (ciego, aislado en /tmp)** — trazó del síntoma (summary) a la causa raíz
  (bounds), **sin parchear el módulo del síntoma** (no enmascaró). Fix mínimo de 2 líneas en
  `Quartiles::of` + 3 tests de regresión (incl. uno que ejercita el camino del síntoma y falla
  sin el fix). Gate verde: calidad + seguridad **diff-aware** (semgrep baseline, cargo audit).
- **Referee (harness `run.sh`):** oráculo fail→pass, CI verde, merge, issue #8 cerrado, score auto.

## Lo que probó esta ronda
- El pipeline funciona en un bug que **exige trazar entre archivos** (diagnóstico difícil,
  aunque el fix sea pequeño) — el Contributor no cayó en el parche fácil del módulo del síntoma.
- **Sistema completo ensamblado** por primera vez de punta a punta: harness (prep/finalize) +
  agentes separados + aislamiento estructural + gate diff-aware.
