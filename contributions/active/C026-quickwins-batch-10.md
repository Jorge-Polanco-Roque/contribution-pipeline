# C026 — Ronda «10 quick wins / 10 repos nuevos» (batch)

| Campo | Valor |
|---|---|
| Estado | **6 PRs abiertos** (numbat #888 · onefetch #1853 · jq #3623 · yq #2849 · gum #1141 · git-cliff #1627) · 4 descartados en filtro-0 |
| Fecha | 2026-09-01 |
| Método | 10 sub-agentes en paralelo: filtro-0 IA → clonar a `qw-<name>/` → reproducir → fix mínimo + test que falla-sin-fix → gate → commit local como Jorge (sin push) → veredicto estructurado |
| Regla aplicada | commit/push solo con orden explícita **por operación** → todo quedó local |

> Nota: cuando un fix reciba orden de PR, se promueve a su propio `CNNN-*.md`. Este batch
> es el registro único del experimento (ponytail: un artefacto por ronda, no 10 dossiers).

## Resultado (6 READY · 4 descartados)

| Repo · issue | Veredicto | Rama local · commit | Caveat |
|---|---|---|---|
| **sharkdp/numbat #635** (`info USD` no carga divisas on-demand) | 🟡 **PR [#888](https://github.com/sharkdp/numbat/pull/888)** | `fix/info-currency-alias` · `04fe221` | **Enfoque endosado por el maintainer** en el issue. El más fuerte. |
| **o2sh/onefetch #1743** (HEAD reftable → crash opaco) | 🟡 **PR [#1853](https://github.com/o2sh/onefetch/pull/1853)** | `fix/head-ref-instantiation` · `7040697` | Fix endosado por autor de gitoxide + collaborator. |
| **jqlang/jq #3538** (`delpaths` con índices negativos mixtos) | 🟡 **PR [#3623](https://github.com/jqlang/jq/pull/3623)** | `fix/delpaths-negative-indices` · `49ce292` | Suite 553/553. Limpio. |
| **mikefarah/yq #2845** (`-i` no preserva permisos) | 🟡 **PR [#2849](https://github.com/mikefarah/yq/pull/2849)** | `fix/preserve-file-permissions-on-inplace` · `c7b4cfd` | ACL solo-Windows, verificado por mecanismo. |
| **orhun/git-cliff #1369** (`--workdir` raíz → salida vacía) | 🟡 **PR [#1627](https://github.com/orhun/git-cliff/pull/1627)** *(con nota)* | `fix/workdir-empty-output` · `37d0306` | Maintainer quiere refactor holístico + @o1x3 se ofreció. PR con nota que lo reconoce + ofrece cerrar. |
| **charmbracelet/gum #681** (tabla markdown larga rompe formato) | 🟡 **PR [#1141](https://github.com/charmbracelet/gum/pull/1141)** *(con nota)* | `fix/format-markdown-table-width` · `3e7d9c8` | Label `blocked`; maintainer prefiere ruta upstream. PR con nota que lo reconoce + ofrece cerrar. |
| procps #665 (whitespace en `ps`) | ⚪ BLOCKED | — | Mitad ya arreglada por #666 mergeado; resto necesita systemd-awareness (rediseño, Linux-only). |
| Textualize/textual #4968 (`@on` matchea subclases) | ⚪ BLOCKED | — | Cuestión de diseño **sin decidir** (willmcgugan defiende el comportamiento actual). |
| jesseduffield/lazygit #5906 (`index.lock`) | 🔴 VETOED | — | CONTRIBUTING: *"does not accept pull requests"* + veta IA. Además race profundo. |
| BurntSushi/ripgrep #3070 (glob + path absoluto) | 🔴 BLOCKED | — | BurntSushi lo triió **won't-fix** (refactor épico del crate `ignore`) + prohíbe agentes autónomos. |

## Ubicación de los fixes (working trees, no pusheados)
`/Users/antm/Desktop/AnatemaBot/qw-{numbat,onefetch,jq,yq,gitcliff,gum}` — cada uno con el commit en su rama.

## Acción del accionista
- **4 PRs abiertos** (numbat #888 · onefetch #1853 · jq #3623 · yq #2849), todos con *allow edits by maintainers* ✓.
  Revisar + enviar bajo tu cuenta; responder reviews cuando lleguen (yo redacto).
- **gum #681 / git-cliff #1369:** en local, en espera de tu decisión (caveat social).

## Bitácora
- 2026-09-01: ronda de 10 quick wins sobre 10 repos nuevos (no repetidos). 6 fixes verdes en local,
  4 descartados correctamente en filtro-0/reproducción. 3 de los 4 descartes ahorraron trabajo real
  (2 bans de IA/PR detectados antes de clonar; 2 «maintainer ya triió won't-fix / diseño sin decidir»).
- 2026-09-01: por orden del accionista, abiertos los **4 PRs limpios**: numbat #888, onefetch #1853,
  jq #3623, yq #2849. Fork + push + PR bajo `Jorge-Polanco-Roque`; los 4 con `maintainerCanModify: true`.
- 2026-09-01: por orden del accionista, abiertos los 2 con caveat social **con nota que reconoce la
  dirección del maintainer** y ofrece cerrar: gum [#1141](https://github.com/charmbracelet/gum/pull/1141)
  (label `blocked`, ruta upstream) y git-cliff [#1627](https://github.com/orhun/git-cliff/pull/1627)
  (refactor holístico + @o1x3). git-cliff: verifiqué que mis líneas cumplen su rustfmt nostable (≤`max_width`,
  sin imports nuevos) sin tener nightly local; lo noté en el PR. Ambos con `maintainerCanModify: true`. **6/6 PRs de la ronda abiertos.**
