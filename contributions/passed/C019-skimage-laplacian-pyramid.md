# C019 — scikit-image #7921 — pyramid_laplacian reconstruible (Burt-Adelson)

| Campo | Valor |
|---|---|
| Estado | 🔴 **CERRADO** ([#8306](https://github.com/scikit-image/scikit-image/pull/8306)) — replegado: stefanv lo trabaja él con @elena-pascal (política IA) |
| Nicho | CV / procesamiento de imágenes (Python) |
| Salud del repo | GO — 6.6k★, activo, mergea externos diversos, acredita en CONTRIBUTORS |
| Stack | Python (numpy/scipy) |
| Origen | issue #7921 (bug de correctitud; @stefanv: "fix ASAP") — sin asignar |
| Política IA | ✅ **permitido con divulgación** — tag `Assisted-by:` en commit (incluido) + review línea-por-línea |
| Reto | alto-medio: correctitud de algoritmo (pirámide Laplaciana multi-escala) |
| Estimación | P(merge) alta (bug real maintainer-wanted, fix sigue el paper, reconstrucción exacta verificada) · 2 archivos |
| Fechas | seleccionado 2026-08-30 · PR 2026-08-30 · merge — |

## Qué pide
`pyramid_laplacian` no seguía el paper de Burt & Adelson: cada nivel era `G_i - smooth(G_i)` (high-pass a la
misma resolución) **sin residual de baja frecuencia** → la pirámide **no reconstruía** la imagen original.

## Causa raíz + solución
Reescrito a la pirámide Laplaciana real: `L_i = G_i - expand(G_{i+1})` (upsample del nivel Gaussiano más
grueso a la forma del fino + smooth) y el último nivel = el Gaussiano más chico (residual). Usa
`pyramid_gaussian` existente. Ambos APIs (`skimage` v1 re-exporta `_skimage2`) cubiertos con un solo cambio.

## Verificación
- ✅ **Reconstrucción a 1.11e-16** (gris/color/rectangular) vs ~0.80 antes.
- ✅ Conteo de niveles idéntico al viejo (6/5/4/3 según downscale) → tests de forma/count existentes intactos.
- ✅ Test nuevo `test_laplacian_pyramid_reconstruction`. `ruff check`/`format` limpios.
- ⚠️ No pude buildear scikit-image local (meson/Cython) → validé el algoritmo con los helpers reales; CI confirma.

## Filtro 0 (divulgación IA)
Política de scikit-image: AI permitido con **`Assisted-by:` tag** + entender línea-por-línea. Incluido en el
commit + cuerpo del PR. (Recomiendan consultar antes para uso significativo de LLM → listo para responder dudas.)

## Acción del accionista (2 gates)
1. PR abierto bajo tu cuenta con divulgación.
2. Responder review de stefanv/maintainers (yo redacto, tú publicas) — pueden preguntar sobre el enfoque.

## Bitácora
- 2026-08-30: seleccionado (CV, maintainer-wanted); fix Burt-Adelson + test; reconstrucción verificada. **PR #8306 abierto.**

## Lección (al cerrar) — 🔴 CERRADO por señal social/política, no por calidad
El fix era **correcto** (reconstrucción a 1e-16, validado). Pero @stefanv (maintainer core) lo cerró: dijo
que el issue es "close to my heart", lo estudia con @elena-pascal, tienen su propia solución en curso, y ya
había **cerrado un PR previo idéntico (#8274, 2026-08-12) por su política de IA** (quiere entendimiento
profundo, no PR asistido por IA en su área personal). Repliegue cortés + cierre (goodwill > este merge).

🔎 **Causa raíz — selección (2 fallos míos):**
1. **No chequeé PRs CERRADOS del issue** — #8274 (cerrado hace semanas, mismo enfoque, misma razón de IA)
   era la señal exacta de la postura del maintainer. Solo miré PRs abiertos.
2. **Malinterpreté "fix ASAP"** de stefanv como "quiere una contribución" cuando significaba "yo estoy en esto".

🛠️ **Reglas nuevas (→ SOUL/filtro de selección):**
- **Antes de codear, revisar PRs CERRADOS del issue** (`gh pr list --search "#N" --state closed`): un cierre
  reciente con el mismo enfoque = la decisión del maintainer, no una oportunidad.
- **Señal "maintainer lo trabaja él":** frases como "close to my heart", "studying with X", "we know how the
  solution should look" = área personal → NO tomar (como copper-rs #1255). "ASAP" de un maintainer puede
  significar "yo lo hago pronto", no "contribuye tú".
- En repos con política de IA de "entendimiento profundo" (scikit-image), preferir issues **mecánicos/objetivos**
  sobre los "de investigación" del maintainer.
