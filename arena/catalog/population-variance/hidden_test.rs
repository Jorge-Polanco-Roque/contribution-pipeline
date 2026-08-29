// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// variance() está documentada como varianza POBLACIONAL: sum((x-mean)^2) / n.
#[test]
fn variance_population_hidden() {
    // mean = 5; sum sq dev = 32; n = 8  ->  32/8 = 4.0
    assert!((statkit::variance(&[2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]) - 4.0).abs() < 1e-9);
    // mean = 2; sum sq dev = 2; n = 3  ->  2/3
    assert!((statkit::variance(&[1.0, 2.0, 3.0]) - (2.0 / 3.0)).abs() < 1e-9);
}
