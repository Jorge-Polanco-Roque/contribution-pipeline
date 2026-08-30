# C015 — sonos/tract #2646 — SimplifiedLayerNormalization debe ser RMS norm, no LayerNorm

| Campo | Valor |
|---|---|
| Estado | **PR abierto** ([#2749](https://github.com/sonos/tract/pull/2749)) — esperando review |
| Nicho | ML / inferencia de redes neuronales (Rust, runtime ONNX/TF) |
| Salud del repo | GO — 3k★, activo a diario, mergea externos (TarikAlHadethi, czoli1976 + kali) |
| Stack | Rust (tract-onnx) |
| Origen | issue #2646 (correctitud, sin asignar, sin comentarios, sin PR) |
| Política IA | ✅ **sin política de IA** (CONTRIBUTING sin ban/disclosure; sin DCO/CLA/template) → filtro 0 OK |
| Reto | alto-medio: correctitud en un compilador de NN; entender semántica RMS vs LayerNorm + reusar op existente |
| Estimación | P(merge) alta (bug de correctitud claro, fix reusa código probado, test numérico end-to-end que prueba el fix) · 2 archivos |
| Fechas | seleccionado 2026-08-30 · PR — · merge — |

## Qué pide
`SimplifiedLayerNormalization` (op contrib de onnxruntime) es **RMS normalization**: escala por la raíz-media-
cuadrática **sin restar la media**. tract lo lowereaba a `LayerNorm` (que **sí** centra) → activaciones
incorrectas en todo input con media ≠ 0; el modelo importa y corre pero da resultados mal, sin warning.

## Causa raíz + solución
`simplified_layer_norm.rs` construía `LayerNorm::new(...)`. El fix **delega a `rms_normalization`** (la op RMS
que tract ya tiene, usada correctamente por la variante Microsoft `SkipSimplifiedLayerNormalization`).

**Ponytail:** cero algoritmo nuevo — reuso la op RMS existente y probada. **Bonus:** el `LayerNorm::new` viejo
hardcodeaba `have_bias: false`, así que **descartaba el input de bias**; `rms_normalization` sí lo maneja →
el fix arregla dos bugs. Borré `LayerNorm::new` (quedó sin uso).

## Verificación (gate del repo, verde)
- ✅ Test end-to-end `simplified_layer_norm_is_rms_norm`: construye un modelo ONNX con el nodo, lo corre con
  input de media≠0 (`[1,2,3,4]`), y asevera salida ≈ RMS (`[0.365, 0.730, 1.095, 1.461]`).
- ✅ **El test prueba el fix:** con el LayerNorm viejo → salida `-1.342…` (centrada) → FAILED; con RMS → ok.
- ✅ `cargo fmt --check` limpio · `clippy` sin warnings nuevos · **suite tract-onnx: 30/30 verde**.

## Cómo se eligió (proyecto prometedor, tras vetar mucho)
Vetados: linfa (feature-heavy + maintainership incierta), macroquad (bugs platform/GPU), ndarray (maduro,
pocos bugs), plotters (semi-dormido). tract ganó: activo a diario, mergea externos, **AI-limpio**, y bugs
recientes reproducibles de ML. #2646 sin reclamar, correctitud clara, y el fix reusa op existente.

## Acción del accionista (2 gates)
1. **Abrir PR** bajo tu cuenta con "Closes #2646".
2. Responder review cuando llegue (yo redacto, tú publicas).

## Bitácora
- 2026-08-30: seleccionado; fix (delega a RMS) + borrado de dead code + test numérico e2e; gate verde.
- 2026-08-30: **PR #2749 abierto** bajo cuenta de Jorge. Esperando review.

## Lección (al cerrar)
<pendiente del review/merge>
