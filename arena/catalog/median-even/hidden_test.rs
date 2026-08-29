// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
#[test]
fn median_even_hidden() {
    assert!((statkit::median(&[1.0, 2.0, 3.0, 4.0]) - 2.5).abs() < 1e-9);
    assert!((statkit::median(&[10.0, 2.0, 8.0, 4.0]) - 6.0).abs() < 1e-9);
}
