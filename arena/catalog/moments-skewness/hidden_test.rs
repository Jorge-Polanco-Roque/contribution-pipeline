// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// skewness() es el coeficiente de Fisher–Pearson poblacional:
//   g1 = ( (1/n) * sum((x-mean)^3) ) / stddev^3.
// Los tests del módulo sólo usan datos simétricos (skew == 0), donde la suma de
// desviaciones al cubo es 0 y el factor 1/n omitido es irrelevante.
#[test]
fn moments_skewness_hidden() {
    // n=5, mean=2, m3=96, stddev=4 -> 96/64 = 1.5
    let got = statkit::skewness(&[0.0, 0.0, 0.0, 0.0, 10.0]);
    assert!((got - 1.5).abs() < 1e-9, "skewness esperado 1.5, got {}", got);

    // n=4, mean=3.5 -> 1.15470053838...
    let got2 = statkit::skewness(&[2.0, 2.0, 2.0, 8.0]);
    assert!(
        (got2 - 1.154_700_538_379_25).abs() < 1e-9,
        "skewness esperado ~1.1547, got {}",
        got2
    );

    // n=6, mean=2 -> 1.78885438...
    let got3 = statkit::skewness(&[1.0, 1.0, 1.0, 1.0, 1.0, 7.0]);
    assert!(
        (got3 - 1.788_854_381_999_83).abs() < 1e-9,
        "skewness esperado ~1.7889, got {}",
        got3
    );
}
