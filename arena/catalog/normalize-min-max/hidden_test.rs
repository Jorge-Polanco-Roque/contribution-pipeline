// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// min_max() está documentada como reescalado a [0,1] vía (x - min)/(max - min).
// El síntoma sólo aparece cuando min != 0; los tests del módulo sólo usan datos
// anclados en cero (donde max - min == max y el bug queda oculto).
#[test]
fn normalize_min_max_hidden() {
    // min=10, max=30, span=20. (10->0, 20->0.5, 30->1)
    let out = statkit::min_max(&[10.0, 20.0, 30.0]);
    assert!((out[0] - 0.0).abs() < 1e-9, "esperado 0.0, got {}", out[0]);
    assert!((out[1] - 0.5).abs() < 1e-9, "esperado 0.5, got {}", out[1]);
    assert!((out[2] - 1.0).abs() < 1e-9, "esperado 1.0, got {}", out[2]);

    // El mínimo siempre mapea a 0 y el máximo a 1 para cualquier dataset real.
    let out2 = statkit::min_max(&[-5.0, 5.0, 0.0, 3.0]);
    let lo = out2.iter().cloned().fold(f64::INFINITY, f64::min);
    let hi = out2.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
    assert!(lo.abs() < 1e-9, "el mínimo normalizado debe ser 0, got {}", lo);
    assert!(
        (hi - 1.0).abs() < 1e-9,
        "el máximo normalizado debe ser 1, got {}",
        hi
    );

    // min=2, max=6, span=4. valor 4 -> (4-2)/4 = 0.5
    let out3 = statkit::min_max(&[2.0, 4.0, 6.0]);
    assert!((out3[1] - 0.5).abs() < 1e-9, "esperado 0.5, got {}", out3[1]);
}
