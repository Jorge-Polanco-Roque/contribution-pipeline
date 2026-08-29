# playbook/quality-gate.md — Cómo se gana el merge (y la reputación)

> Un PR solo gana si el maintainer confía en él. La mayoría de los PR externos se
> rechazan por descuidados o inseguros. Nuestra ventaja es **calidad disciplinada
> + higiene de seguridad**: este es el proceso obligatorio antes de que el
> accionista envíe cualquier PR bajo su cuenta.

## Principio

**No competimos por ser los primeros; competimos por ser los que hacen merge.**
Un PR limpio, con tests, que respeta el estilo del repo, pasa su CI y no mete
secretos ni dependencias vulnerables, gana aunque llegue segundo. Filosofía
ponytail: **el diff más pequeño que resuelve el issue de raíz**, reutilizando lo
que ya existe en el repo.

## Flujo por contribución (obligatorio)

| Paso | Qué hago | Herramienta / skill |
|---|---|---|
| 0. Contexto | Leer el issue, `CONTRIBUTING.md` y 2–3 PR ya mergeados para copiar el estilo del maintainer | — |
| 1. Docs | Confirmar la API real de las libs que toco (no inventar firmas) | **Context7** (`mcp__context7`) |
| 2. Código | Diff mínimo que ataca la causa raíz; reutilizar helpers del repo | **ponytail** |
| 3. Test | Agregar **≥1 test que falla si el fix se rompe**, en el framework del repo | (tests del repo) |
| 4. Auto-review | Revisar mi propio diff: correctness + recortar bloat | **/code-review**, **/simplify** |
| 5. Seguridad | Etapa dura del gate: sin secretos, sin deps con CVE, sin patrones riesgosos | **pre_submit.sh** + **/security-review** |
| 6. Verificar | Confirmar que el fix REALMENTE cambia el comportamiento | **/verify** (o correr el ejemplo del repo) |
| 7. **Gate** | `bash tools/pre_submit.sh <repo>` → formato+lint+build+tests **+ seguridad** en **verde** | **pre_submit.sh** |
| 8. Igualar CI | Replicar exactamente los checks que corre el CI del repo | (ver `.github/workflows`) |
| 9. Entregar | PR con `Fixes #NNN`, resumen claro, tests listados → accionista revisa (~20 min) y envía | gate humano |
| 10. Seguimiento | Responder el review del maintainer rápido y con calidad hasta el merge | — |

**Regla dura:** si el paso 7 sale rojo (calidad **o** seguridad), el PR **no se
envía**. Sin excepción — un secreto filtrado bajo la cuenta del accionista destruye
más reputación que la que suma un merge.

## Cheat-sheet: qué corre el gate por stack

| Stack | Formato | Lint | Tests | Deps (seguridad) |
|---|---|---|---|---|
| Rust | `cargo fmt --all -- --check` | `cargo clippy --all-targets -- -D warnings` | `cargo test --all` | `cargo audit` |
| Go | `gofmt -l .` (vacío) | `go vet ./...` | `go test ./...` | `govulncheck ./...` |
| Python | `ruff check .` | `ruff check .` | `pytest -q` | `pip-audit` |
| Node | `npm run lint` | idem | `npm test` | `npm audit --audit-level=high` |
| C/C++ | (según repo) | (según repo) | replicar su CI a mano | (revisión manual) |

**Transversal a todo stack:** secretos (`gitleaks` o fallback grep) y SAST
(`semgrep --config auto`).

`tools/pre_submit.sh` autodetecta el stack y corre todo lo de arriba. Flags:
`--check` (self-test de detección), `--security <repo>` (solo la etapa de
seguridad). Herramientas de seguridad no instaladas = se omiten con aviso; hallazgos
reales = gate rojo.

## Qué anotar en el `CNNN-*.md` al terminar

- Salida del gate (verde/rojo, qué se corrió, qué se omitió por falta de tooling).
- Tests agregados y qué cubren.
- Cómo verifiqué el comportamiento (paso 6).
- Estilo/convención del repo que seguí (para reusar en la próxima contribución del mismo repo).
- Estado del seguimiento del review (paso 10) hasta el merge.
