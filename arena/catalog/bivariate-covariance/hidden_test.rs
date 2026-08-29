// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// covariance() está documentada como covarianza POBLACIONAL (divisor n), de modo
// que covariance(xs, xs) == varianza poblacional de xs. Los tests del módulo sólo
// verifican covarianza cero (datos no correlacionados/constantes), el signo, y la
// simetría en los argumentos: ninguno fija la MAGNITUD, así que el divisor no se
// ejercita.
#[test]
fn bivariate_covariance_hidden() {
    // cov(x, x) debe igualar la varianza poblacional de x.
    // x = [1,2,3,4,5]: media 3, sum((x-3)^2) = 10, /5 = 2.0
    let xs = [1.0, 2.0, 3.0, 4.0, 5.0];
    let got = statkit::covariance(&xs, &xs);
    assert!(
        (got - statkit::variance(&xs)).abs() < 1e-9,
        "covariance(x,x) debe igualar la varianza poblacional ({}), got {}",
        statkit::variance(&xs),
        got
    );
    assert!(
        (got - 2.0).abs() < 1e-9,
        "covariance esperada 2.0, got {}",
        got
    );

    // Magnitud exacta con dos series distintas.
    // x=[1,2,3], y=[2,4,6]: mx=2, my=4; sum = (-1)(-2)+0+ (1)(2) = 4; /3
    let a = statkit::covariance(&[1.0, 2.0, 3.0], &[2.0, 4.0, 6.0]);
    assert!(
        (a - (4.0 / 3.0)).abs() < 1e-9,
        "covariance esperada 4/3, got {}",
        a
    );
}
