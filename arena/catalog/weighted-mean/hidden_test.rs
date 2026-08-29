// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// weighted_mean() está documentada: es sum(w_i*x_i) / sum(w_i), de modo que
// escalar todos los pesos por una constante no cambia el resultado y sólo la
// razón entre pesos importa. Los tests del módulo sólo usan pesos cuya suma
// coincide con n (todos 1, o [2,0,2,0], etc.), donde el divisor correcto y un
// divisor = n son indistinguibles.
#[test]
fn weighted_mean_hidden() {
    // Pesos [3, 1] suman 4 != n(=2). Correcto: (3*10 + 1*20)/4 = 12.5
    let got = statkit::weighted_mean(&[10.0, 20.0], &[3.0, 1.0]);
    assert!(
        (got - 12.5).abs() < 1e-9,
        "weighted_mean esperado 12.5, got {}",
        got
    );

    // Invariancia de escala: multiplicar los pesos por 10 no cambia el resultado.
    let a = statkit::weighted_mean(&[1.0, 2.0, 3.0], &[1.0, 2.0, 3.0]);
    let b = statkit::weighted_mean(&[1.0, 2.0, 3.0], &[10.0, 20.0, 30.0]);
    assert!(
        (a - b).abs() < 1e-9,
        "weighted_mean debe ser invariante a la escala de los pesos: {} vs {}",
        a,
        b
    );
    // Valor exacto: (1*1 + 2*2 + 3*3)/(1+2+3) = 14/6.
    assert!((a - (14.0 / 6.0)).abs() < 1e-9, "weighted_mean esperado 14/6, got {}", a);
}
