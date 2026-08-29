// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// trimmed_mean(xs, frac) está documentada: ordena, descarta floor(frac*n)
// elementos de CADA extremo y promedia lo que queda. El núcleo tiene n - 2k
// elementos, así que el divisor correcto es (n - 2k). Los tests del módulo sólo
// usan casos donde k = 0 (frac = 0, o n pequeño que hace floor a 0), donde
// n - k y n - 2k coinciden. Con k >= 1 el defecto (dividir por n - k) infla el
// denominador y sesga el resultado.
#[test]
fn trimmed_mean_hidden() {
    // n = 10, frac = 0.1 -> k = 1. Se descartan 1.0 y 10.0; núcleo = 2..=9,
    // media = (2+3+4+5+6+7+8+9)/8 = 44/8 = 5.5.
    let xs = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
    let got = statkit::trimmed_mean(&xs, 0.1);
    assert!(
        (got - 5.5).abs() < 1e-9,
        "trimmed_mean(1..=10, 0.1) esperado 5.5, got {}",
        got
    );

    // Robustez: un outlier extremo se recorta y no debe afectar la media del
    // núcleo. n = 10, frac = 0.1 -> k = 1 recorta 0.0 y 1000.0; núcleo 1..=8,
    // media = (1+2+3+4+5+6+7+8)/8 = 36/8 = 4.5.
    let ys = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 1000.0];
    let robust = statkit::trimmed_mean(&ys, 0.1);
    assert!(
        (robust - 4.5).abs() < 1e-9,
        "trimmed_mean con outlier recortado esperado 4.5, got {}",
        robust
    );
}
