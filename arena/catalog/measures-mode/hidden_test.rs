// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// mode() está documentada: devuelve el valor más frecuente y, ante empate en la
// frecuencia máxima, el MÁS PEQUEÑO. Los tests del módulo sólo usan datos con un
// único ganador (sin empate), donde la regla de desempate no se ejercita.
#[test]
fn measures_mode_hidden() {
    // 1 y 3 aparecen 2 veces cada uno: empate -> mínimo = 1.0
    let got = statkit::mode(&[3.0, 1.0, 3.0, 1.0, 2.0]);
    assert!((got - 1.0).abs() < 1e-9, "mode esperado 1.0, got {}", got);

    // 2 y 8 aparecen 2 veces: empate -> mínimo = 2.0
    let got2 = statkit::mode(&[8.0, 2.0, 8.0, 2.0, 5.0]);
    assert!((got2 - 2.0).abs() < 1e-9, "mode esperado 2.0, got {}", got2);

    // -5 y 10 aparecen 2 veces: empate -> mínimo = -5.0
    let got3 = statkit::mode(&[10.0, -5.0, 10.0, -5.0]);
    assert!(
        (got3 - (-5.0)).abs() < 1e-9,
        "mode esperado -5.0, got {}",
        got3
    );
}
