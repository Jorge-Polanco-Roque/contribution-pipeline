// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// percentile() está documentada como el método `linear` (numpy-default):
// rango virtual r = p/100 * (n-1); se interpola linealmente entre v[floor(r)]
// y v[ceil(r)] con peso frac = r - floor(r). Los casos que caen entre índices
// (interpolación real) revelan si la fracción se aplicó en la dirección correcta.
#[test]
fn percentile_interpolated_hidden() {
    let xs = [1.0, 2.0, 3.0, 4.0];
    // n=4 -> r = 0.25*3 = 0.75; entre v[0]=1 y v[1]=2 con frac=0.75 -> 1.75
    assert!((statkit::percentile(&xs, 25.0) - 1.75).abs() < 1e-9);
    // r = 0.50*3 = 1.5; entre v[1]=2 y v[2]=3 con frac=0.5 -> 2.5 (== mediana par)
    assert!((statkit::percentile(&xs, 50.0) - 2.5).abs() < 1e-9);
    // r = 0.75*3 = 2.25; entre v[2]=3 y v[3]=4 con frac=0.25 -> 3.25
    assert!((statkit::percentile(&xs, 75.0) - 3.25).abs() < 1e-9);

    // Percentil que cae entre índices en un dataset de 5 elementos.
    let ys = [10.0, 20.0, 30.0, 40.0, 50.0];
    // r = 0.90*4 = 3.6; entre v[3]=40 y v[4]=50 con frac=0.6 -> 46.0
    assert!((statkit::percentile(&ys, 90.0) - 46.0).abs() < 1e-9);
}
