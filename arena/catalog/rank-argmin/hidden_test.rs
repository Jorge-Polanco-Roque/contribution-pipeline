// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// argmin() está documentada: ante empate en el mínimo devuelve el PRIMER índice
// (el más bajo). Los tests del módulo sólo usan datos con un mínimo único, donde
// la regla de desempate no se ejercita. (argmax queda correcta; sólo argmin falla.)
#[test]
fn rank_argmin_hidden() {
    // mínimo 1.0 en índices 1 y 3 -> primero = 1
    assert_eq!(
        statkit::argmin(&[3.0, 1.0, 2.0, 1.0]),
        1,
        "argmin debe devolver el primer índice del mínimo"
    );

    // mínimo 0.0 en índices 0 y 2 -> primero = 0
    assert_eq!(statkit::argmin(&[0.0, 5.0, 0.0, 9.0]), 0);

    // mínimo -3.0 en índices 2 y 4 -> primero = 2
    assert_eq!(statkit::argmin(&[1.0, 2.0, -3.0, 4.0, -3.0]), 2);
}
