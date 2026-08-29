// Hidden acceptance test — oráculo independiente del arena (fuera del alcance de B).
// Se inyecta en tests/ al validar: debe FALLAR en main y PASAR tras el fix.
//
// Summary::of agrega varias medidas de un dataset. Sus campos q1/q3 están
// documentados como el 25º y 75º percentil, e iqr = q3 - q1 (>= 0 para
// cualquier dataset real). El síntoma sólo aparece a través de Summary: los
// tests directos de percentile() no cruzan este camino.
#[test]
fn summary_quartiles_hidden() {
    // n=5: q1 = percentile(25) = 2, q3 = percentile(75) = 4, iqr = 2.
    let s = statkit::Summary::of(&[1.0, 2.0, 3.0, 4.0, 5.0]);
    assert!((s.q1 - 2.0).abs() < 1e-9, "q1 esperado 2.0, got {}", s.q1);
    assert!((s.q3 - 4.0).abs() < 1e-9, "q3 esperado 4.0, got {}", s.q3);
    assert!((s.iqr - 2.0).abs() < 1e-9, "iqr esperado 2.0, got {}", s.iqr);

    // q1 <= q3 y iqr >= 0 deben cumplirse siempre.
    assert!(s.q1 <= s.q3, "q1 debe ser <= q3");
    assert!(s.iqr >= 0.0, "iqr no puede ser negativo, got {}", s.iqr);

    // Segundo dataset entre índices: q1=percentile(25) sobre [10,20,30,40]
    // r=0.25*3=0.75 -> 17.5 ; q3=percentile(75) r=2.25 -> 32.5 ; iqr=15.
    let t = statkit::Summary::of(&[10.0, 20.0, 30.0, 40.0]);
    assert!((t.q1 - 17.5).abs() < 1e-9, "q1 esperado 17.5, got {}", t.q1);
    assert!((t.q3 - 32.5).abs() < 1e-9, "q3 esperado 32.5, got {}", t.q3);
    assert!((t.iqr - 15.0).abs() < 1e-9, "iqr esperado 15.0, got {}", t.iqr);
}
