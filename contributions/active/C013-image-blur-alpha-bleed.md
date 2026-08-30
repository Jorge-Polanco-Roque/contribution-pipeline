# C013 — image-rs/image #2324 — blur RGBA sangra color de píxeles transparentes (premultiplied alpha)

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#3107](https://github.com/image-rs/image/pull/3107)) — esperando review |
| Nicho | CV / procesamiento de imágenes (Rust) |
| Salud del repo | GO — 5.9k★, activo (push 2026-08-28), issues maduran (no hiperactivo) |
| Stack | Rust |
| Origen | issue #2324 (kind:bug + kind:incorrect, sin asignar, sin PR) |
| Política IA | ✅ **sin política de IA** (CONTRIBUTING sin ban ni disclosure; sin DCO/CLA/template) → filtro 0 OK |
| Reto | medio-alto: correctitud de convolución + premultiplied alpha; maintainers ya bendijeron la dirección |
| Estimación | P(merge) alta (bug vivo reproducido, dirección bendecida, reusa utilidades del repo, test que prueba el fix) · 2 archivos |
| Fechas | seleccionado 2026-08-30 · PR — · merge — |

## Qué pide
`DynamicImage::blur` (Gaussian) sobre imágenes RGBA con zonas transparentes **sangra el color** de los
píxeles totalmente transparentes hacia los vecinos opacos. Reproducido en main: blanco opaco junto a rojo
transparente → el borde blanco se tiñe de rojo (`[255,175,175,175]` en vez de `[255,255,255,175]`).

## Causa raíz + solución
`gaussian_blur_dyn_image` convoluciona los subpíxeles RGBA **sin premultiplicar alpha** — a diferencia de
`resize`, que se arregló en #2639 (añadió premultiply). El fix: premultiplicar antes de la convolución y
des-premultiplicar después, **reusando** `premultiply_alpha`/`unpremultiply_alpha`/`has_constant_alpha` de
`resize.rs` (los hice `pub(crate)`). Se omite si el alpha es constante (nada que sangrar).

**Ponytail:** cero código nuevo de premultiply — reuso las utilidades que el repo ya tiene. Un solo `clone`
del input (blur ya asigna buffers, coste aceptable). El fix deja blur consistente con resize.

## Verificación (gate del repo, verde)
- ✅ Repro empírico: antes `[255,175,175,175]` (rojo sangra) → después `[255,255,255,175]` (blanco puro, solo alpha mezcla).
- ✅ Test nuevo `blur_does_not_bleed_color_from_transparent_pixels` (en memoria, sin features extra).
- ✅ **El test prueba el fix:** sin el cambio → FAILED (`red bled into white at x=10: [255,175,175,175]`); con el fix → ok.
- ✅ 52 tests de `imageops` (sample+resize) pasan · `cargo fmt --check` limpio · `clippy` 0 warnings.

## Cómo se eligió (tras vetar mucho — pivote de repos hiperactivos)
Vetados: copper-rs #1255 (del propio maintainer, dijo que lo arregla), sktime #8686 (ambiguo+reclamado),
#8715 (no reproduce en main), #8706 (ya arreglado en #8873). Aprendizaje: repos hiperactivos (boa/sktime)
→ bugs limpios tomados en días. Pivote a repos activos-no-hiperactivos (image, 5.9k). #2324: vivo,
maintainer-bendecido (kornelski/Shnatsel: premultiplied alpha), reproducible, nicho CV.

## Acción del accionista (2 gates)
1. **Abrir PR** bajo tu cuenta con "Closes #2324".
2. Responder review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-30: seleccionado tras pivote; fix implementado + reproducido + verificado; gate verde.
- 2026-08-30: **PR #3107 abierto** bajo cuenta de Jorge. Esperando review.

## Lección (al cerrar)
<pendiente del review/merge>
