// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// running_max() está documentada como el máximo de prefijo: cada elemento i es
// el mayor valor visto en xs[0..=i], por lo que la secuencia es no decreciente y
// su último elemento es el máximo global. Los tests del módulo sólo usan datos
// monotónicos no decrecientes o un único valor tras el pico, donde comparar
// contra el elemento previo coincide con el verdadero máximo acumulado. El
// defecto aparece cuando un pico va seguido de dos o más valores menores.
#[test]
fn running_max_hidden() {
    // Tras el pico 5.0 vienen dos valores menores: el máximo debe arrastrarse.
    let got = statkit::running_max(&[1.0, 5.0, 2.0, 3.0]);
    assert_eq!(
        got,
        vec![1.0, 5.0, 5.0, 5.0],
        "running_max debe arrastrar el pico 5.0, got {:?}",
        got
    );

    // La secuencia siempre es no decreciente y termina en el máximo global.
    let seq = statkit::running_max(&[3.0, 1.0, 4.0, 1.0, 5.0, 9.0, 2.0, 6.0]);
    for w in seq.windows(2) {
        assert!(w[1] >= w[0], "running_max debe ser no decreciente, got {:?}", seq);
    }
    assert_eq!(
        *seq.last().unwrap(),
        9.0,
        "el último elemento de running_max debe ser el máximo global, got {:?}",
        seq
    );
}
