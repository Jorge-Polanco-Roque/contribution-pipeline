// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// root_mean_square() está documentada como sqrt((1/n) * sum(x_i^2)). El defecto
// centra los datos en su media antes de elevar al cuadrado (calcula la desviación
// estándar poblacional en vez del RMS). Ambas coinciden EXACTAMENTE cuando la media
// es cero, y los tests del módulo sólo usan datos simétricos respecto al origen, por
// lo que el bug queda latente. Con datos de media no nula el defecto se manifiesta.
#[test]
fn root_mean_square_hidden() {
    // RMS de [3, 4]: sqrt((9 + 16) / 2) = sqrt(12.5) ~ 3.535534.
    let got = statkit::root_mean_square(&[3.0, 4.0]);
    assert!(
        (got - (12.5_f64).sqrt()).abs() < 1e-9,
        "root_mean_square([3,4]) esperado sqrt(12.5) (~3.535534), got {}",
        got
    );

    // Datos constantes positivos: el RMS de [5,5,5] es 5 (no 0).
    let constant = statkit::root_mean_square(&[5.0, 5.0, 5.0]);
    assert!(
        (constant - 5.0).abs() < 1e-9,
        "root_mean_square([5,5,5]) esperado 5, got {}",
        constant
    );

    // Un solo valor: su RMS es su propia magnitud.
    let single = statkit::root_mean_square(&[-7.0]);
    assert!(
        (single - 7.0).abs() < 1e-9,
        "root_mean_square([-7]) esperado 7, got {}",
        single
    );

    // El RMS domina el valor absoluto de la media aritmética para cualquier dato.
    let xs = [1.0, 2.0, 3.0, 4.0];
    let rms = statkit::root_mean_square(&xs);
    let am = xs.iter().sum::<f64>() / xs.len() as f64; // = 2.5
    assert!(
        rms >= am.abs() - 1e-9,
        "root_mean_square debe ser >= |media aritmética| (2.5), got {}",
        rms
    );
}
