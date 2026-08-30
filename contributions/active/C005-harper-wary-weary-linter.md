# C005 — Automattic/harper #4234 — regla de lint `wary` vs `weary`

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#4253](https://github.com/Automattic/harper/pull/4253)) — esperando review |
| Nicho | infra/devtools (Rust, grammar checker) |
| Salud del repo | GO — 14.8k★, Automattic, muy activo, `justfile`, merges de externos |
| Stack | Rust |
| Issue URL | https://github.com/Automattic/harper/issues/4234 |
| PR URL | **https://github.com/Automattic/harper/pull/4253** |
| Etiquetas | good first issue |
| Política IA | ✅ sin política de IA (ni ban ni divulgación) — objetivo seguro, sin etiqueta |
| Estimación | P(merge) media-alta (regla pedida; riesgo = subjetividad de patrones/falsos positivos) · +16 + 3 archivos |
| Fechas | seleccionado 2026-08-29 · PR 2026-08-29 · merge — |

## Qué pide el issue
Regla que cace la confusión entre `wary` (cauto) y `weary` (cansado). El reporter dudó de la
detectabilidad (ambos "wary of"/"weary of" son válidos).

## Solución
Regla `WaryWeary` bidireccional espejando `hop_hope` (`merge_linters!` de dos `ExprLinter`).
Para evitar falsos positivos, solo dispara en **idioms de alta confianza**:
- `weary eye/eyes` → `wary eye` (ojo cauto/vigilante)
- `bone/world wary` → `bone/world weary` (agotamiento)
Deja intacto lo ambiguo (`weary of`) — con test que lo verifica. Registrada en el lint group y
añadida a los **dos configs en sync**: `default_config.json` (lo exige el test
`curated_default_config_lists_every_registered_rule`) y el `package.json` del vscode-plugin.

## Gate (calidad + seguridad) — VERDE
- 8 tests nuevos (5 correcciones + 3 no-falsos-positivos). Suite completa `harper-core`: **6323 passed, 0 failed**.
- `cargo fmt --check` limpio · clippy sin hallazgos.

## Lección (selección)
- **Tests de invariante del repo:** harper exige que cada regla registrada esté en `default_config.json`
  (test dedicado) y mantiene en sync el `package.json` del vscode-plugin → "el repo manda": buscar y
  actualizar TODOS los configs derivados, no solo el código.
- **Reglas de gramática = riesgo de subjetividad:** el maintainer puede pedir más/menos patrones. Estrategia:
  arrancar conservador (idioms bulletproof) y ofrecer ampliar en el PR.
- Política IA verificada ANTES de codear (filtro 0 de SOUL §5): harper sin política → seguro y sin etiqueta.

## Acción del accionista
PR publicado bajo tu cuenta. Siguiente: responder al review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-29: seleccionado (recon GO, uncontested, sin ban IA), implementado, gate verde, PR #4253 abierto.

## Lección (al cerrar)
<pendiente del review/merge>
