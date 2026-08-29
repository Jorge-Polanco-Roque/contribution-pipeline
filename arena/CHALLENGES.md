# CHALLENGES.md — 10 retos hyper-experto (auditoría de puntos ciegos del gate)

> Cada reto es un defecto de **nivel industria** que **pasa el gate naïve en verde**
> (formato + lint + build + tests de ejemplo) y aun así es incorrecto. El objetivo no es
> probar al Contributor, sino **exponer qué capa le falta al pipeline** — y endurecerlo.
> Regla de oro del terreno: *los tests de ejemplo del repo no son una red; solo cubren lo
> que alguien pensó en cubrir.*

## Los 10 retos

| # | Reto | Clase | Por qué pasa el gate naïve | Capa/herramienta que lo caza |
|---|---|---|---|---|
| 1 | **Cancelación catastrófica** | Estabilidad numérica | `Σx² − (Σx)²/n` da 0 precisión para media grande; los tests usan enteros chicos donde da exacto | Test de propiedad con datos desplazados (**proptest**); Welford |
| 2 | **Envenenamiento por NaN/Inf** | Robustez de entrada | `sort_by(partial_cmp().unwrap())` **panica** con NaN; los tests usan datos limpios | **Fuzz**/proptest con NaN·Inf; `clippy::unwrap_used`; **risk-scan del diff** |
| 3 | **Regresión O(n²) oculta** | Rendimiento | Un refactor vuelve O(n) en O(n²) (`Vec::remove` en loop, `contains` repetido); correctitud intacta | **Benchmark de regresión** (criterion); revisión de complejidad |
| 4 | **Overflow de enteros** | Aritmética | `(hi+lo)/2` o `len*stride` desbordan `usize`; debug panica, **release envuelve** → OOB silencioso | `overflow-checks` en release-test; `checked_*`; **risk-scan** (`as`) |
| 5 | **UB en `unsafe`** | Memoria/soundness | `get_unchecked` con off-by-one o `transmute` con lifetime/alineación mala; "funciona por suerte" | **`cargo miri`**; **risk-scan** exige `// SAFETY:` |
| 6 | **Ruptura de semver** | Compatibilidad API | Cambiar firma pública / quitar `pub` / enum no-exhaustivo; compila y testea, rompe downstream | **`cargo-semver-checks`** vs baseline publicado |
| 7 | **Data race / Send-Sync unsound** | Concurrencia | Paralelizar con `&mut` compartido vía unsafe, o `impl Sync` falso; los tests single-thread pasan | **`loom`** / ThreadSanitizer / miri |
| 8 | **Test flaky por no-determinismo** | Fiabilidad de suite | Test que depende de orden de `HashMap`, igualdad de floats o reloj; verde ahora, rojo en CI al azar | Correr tests **N veces** / `--shuffle`; detectar orden-dependencia |
| 9 | **Invariante de propiedad violado** | Correctitud oculta | `median != percentile(50)` para todo n; los ejemplos solo cubren casos bonitos | **proptest** del invariante; metamorphic testing |
| 10 | **Error tragado** | Manejo de fallos | `let _ = result;`, `.ok()`, `unwrap_or_default()` sobre `Result` esconden el camino de fallo | **risk-scan del diff**; `#[must_use]`; revisión |

## Mapa: qué le falta al gate actual

El gate actual (`pre_submit.sh`) corre: formato · lint · build · **tests del repo** · secretos · SCA · SAST — todo **diff-aware**. Cubre bien correctitud *cubierta por tests* y seguridad. **No** cubre, por diseño de un gate estático:

- **Correctitud no cubierta** (retos 1, 4, 8, 9): necesita *property/fuzz testing* — que es responsabilidad del **repo** y del **Contributor** (por eso el contrato exige un test que falle sin el fix, y ahora también un test de **borde/propiedad** en cambios numéricos).
- **Rendimiento** (3): necesita benchmarks del repo (criterion). Fuera del alcance de un gate de correctitud; se documenta.
- **UB / concurrencia** (5, 7): necesita `miri`/`loom`/nightly. Se corre **solo si el diff introduce `unsafe`/concurrencia** (diff-aware).
- **Semver** (6): `cargo-semver-checks` vs un baseline publicado — aplica a libs con API pública.

## Lo que SÍ añadimos al pipeline en esta iteración (ver LEARNINGS)

1. **Risk-scan del diff (advisory):** surfacea construcciones riesgosas *nuevas* — `unsafe`,
   `unwrap/expect/panic!`, casts `as`, `let _ =`/`.ok()`/`unwrap_or_default`, `#[allow]`.
   Ataca (parcial) los retos 2, 4, 5, 10 al ponerlos frente al revisor humano.
2. **Contrato del Contributor:** en cambios numéricos, exige un test de **propiedad/borde**
   (NaN, vacío, datos grandes/desplazados), no solo un caso de ejemplo. Ataca 1, 2, 9.
3. **`bootstrap.sh`:** añade `cargo-semver-checks` (reto 6) y documenta `miri` (5,7) como deep-gate opt-in.

> Honestidad: un gate estático **no puede** garantizar correctitud numérica, ausencia de UB o
> rendimiento por sí solo. La defensa real es en capas: gate (lo mecánico) + property/fuzz tests
> del repo (lo semántico) + deep-gate opt-in (miri/loom/semver) cuando el diff lo amerita.
