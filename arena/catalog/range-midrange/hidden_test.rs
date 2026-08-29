// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// midrange() está documentada como el punto medio entre el mínimo y el máximo:
// (min + max) / 2. El síntoma sólo aparece cuando min != 0; los tests del
// módulo sólo usan datos anclados en cero (donde (max-min)/2 == (min+max)/2).
#[test]
fn range_midrange_hidden() {
    // min=2, max=8 -> (2+8)/2 = 5.0
    let got = statkit::midrange(&[2.0, 8.0, 5.0, 6.0]);
    assert!(
        (got - 5.0).abs() < 1e-9,
        "midrange esperado 5.0, got {}",
        got
    );

    // min=-4, max=10 -> (-4+10)/2 = 3.0
    let got2 = statkit::midrange(&[-4.0, 10.0, 0.0, 7.0]);
    assert!(
        (got2 - 3.0).abs() < 1e-9,
        "midrange esperado 3.0, got {}",
        got2
    );

    // min=100, max=104 -> 102.0
    let got3 = statkit::midrange(&[100.0, 102.0, 104.0]);
    assert!(
        (got3 - 102.0).abs() < 1e-9,
        "midrange esperado 102.0, got {}",
        got3
    );
}
