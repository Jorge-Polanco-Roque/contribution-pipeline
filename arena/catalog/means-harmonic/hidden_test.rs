// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// harmonic_mean() está documentada como n / sum(1/x_i). Los tests del módulo
// sólo usan datos unitarios (todos 1.0), donde sum(1/x) == n y el resultado es
// 1.0 sin importar cómo se coloque el divisor. Con datos no unitarios el defecto
// (devolver la media de los recíprocos, sum(1/x)/n) se manifiesta.
#[test]
fn harmonic_mean_hidden() {
    // Media armónica de [1, 2, 4]: 3 / (1 + 0.5 + 0.25) = 3 / 1.75 = 12/7.
    let got = statkit::harmonic_mean(&[1.0, 2.0, 4.0]);
    assert!(
        (got - (12.0 / 7.0)).abs() < 1e-9,
        "harmonic_mean esperado 12/7 (~1.714286), got {}",
        got
    );

    // Caso clásico de velocidades: 60 y 30 -> 2 / (1/60 + 1/30) = 40.
    let speeds = statkit::harmonic_mean(&[60.0, 30.0]);
    assert!(
        (speeds - 40.0).abs() < 1e-9,
        "harmonic_mean([60,30]) esperado 40, got {}",
        speeds
    );

    // Relación AM >= GM >= HM (estricta para datos no constantes): la media
    // armónica debe ser menor que la aritmética (=2.0) para [1,2,4].
    let hm = statkit::harmonic_mean(&[1.0, 2.0, 4.0]);
    assert!(hm < 2.0, "harmonic_mean debe ser < media aritmética, got {}", hm);
}
