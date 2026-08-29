// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// stddev() está documentada como desviación estándar POBLACIONAL:
// sqrt(sum((x-mean)^2) / n), consistente con variance() (divisor n).
// El síntoma sólo aparece con datos de spread no nulo; los tests del módulo
// sólo usan datos constantes (stddev = 0 bajo cualquier divisor).
#[test]
fn stddev_population_hidden() {
    // [1,2,3]: mean=2, sum sq dev = 2, n=3 -> sqrt(2/3).
    let got = statkit::stddev(&[1.0, 2.0, 3.0]);
    assert!(
        (got - (2.0_f64 / 3.0).sqrt()).abs() < 1e-9,
        "stddev poblacional esperado sqrt(2/3)={}, got {}",
        (2.0_f64 / 3.0).sqrt(),
        got
    );

    // [2,4,4,4,5,5,7,9]: mean=5, sum sq dev=32, n=8 -> sqrt(4)=2.0.
    let got2 = statkit::stddev(&[2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]);
    assert!(
        (got2 - 2.0).abs() < 1e-9,
        "stddev poblacional esperado 2.0, got {}",
        got2
    );

    // Debe coincidir con sqrt(variance) (ambas poblacionales).
    let xs = [3.0, 1.0, 4.0, 1.0, 5.0, 9.0, 2.0, 6.0];
    assert!(
        (statkit::stddev(&xs) - statkit::variance(&xs).sqrt()).abs() < 1e-9,
        "stddev debe ser sqrt(variance)"
    );
}
