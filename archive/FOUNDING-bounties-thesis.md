# PROJECT_002 — Bounties de código por cripto

| Campo | Valor |
|---|---|
| **Estado** | 🟢 ACTIVO — F0 (aprobado por accionista 2026-08-29) |
| **Gate humano** | ✅ Aprobado. Siguiente gate: ganar ≥1 bounty en ≤2 semanas |
| **Presupuesto tope (efectivo)** | **$0** (esta es la gran ventaja: no se invierte, se cobra) |
| **Créditos Higgsfield** | 0 (no aplica) |
| **Tu tiempo** | ~45 min una vez (cuentas + KYC) + ~20 min por bounty (revisar y aprobar el PR) |
| **Fecha** | 2026-08-29 |

---

## 1. Tesis de dinero

Empresas fondean issues reales de sus repos open-source con recompensas de
**$50–$2,500**. Yo escribo la solución; tú revisas y la enviamos bajo tu GitHub.
Al hacer merge, pagan en **1–3 días** en USDC/USDT/ETH **directo a tu wallet**
(o banco), comisión de plataforma ~10%. **Inversión de efectivo: $0.** El dinero
entra por trabajo entregado, no por audiencia ni por suerte.

Plataformas: **Algora** (principal), **Opire**, **OnlyDust**, **IssueHunt**.

## 2. El problema real y nuestra ventaja

**El problema no es encontrar bounties — es que un bounty fresco jala 8–158 PRs
en horas.** Ganar al azar es perder. Nuestra ventaja de CEO no es velocidad
bruta, es **selección**:

- **Cazar nichos, no lo popular.** Bounties en stacks donde tú/yo pegamos fuerte
  y hay pocos PRs competentes: **Rust, Elixir, ML/visión por computadora,
  gamedev, gráficos/3D, infra**. Ahí 158 juniors no compiten.
- **Dificultad media-alta.** Los $50 triviales atraen manada; los issues que
  exigen leer el codebase filtran a la mayoría. Yo leo codebases rápido.
- **Primer movimiento vigilado.** Monitoreo el feed de bounties nuevos y ataco
  los que caen en nuestro nicho antes de que se saturen.
- **Calidad de merge.** Muchos PRs se rechazan por descuidados (sin tests, rompen
  CI). Un PR limpio con tests gana aunque no sea el primero.
- **Reputación compuesta.** Tras 2–3 merges, los maintainers **asignan directo**
  (sin competencia). Ese es el activo escondido de este proyecto.

## 3. Hipótesis + gate de validación (barato)

> **Hipótesis:** puedo seleccionar y resolver bounties donde ganamos el merge,
> a costo de efectivo $0.

**Gate F0 (≤ 2 semanas, $0):** ganar **≥ 1 bounty pagado ($50+)**.

| Métrica | Umbral para ESCALAR | Si no |
|---|---|---|
| PRs enviados | 3–5 (solo en nuestro nicho) | Revisar criterio de selección |
| Merges ganados | **≥ 1** | Ajustar nicho/dificultad o CERRAR |
| $ cobrado | ≥ $50 | Falla la tesis → cerrar barato |
| Tasa de aceptación | ≥ 25% de PRs mergeados | Estamos eligiendo mal, no compitiendo mal |

Si en 5 PRs no ganamos ni uno → la tesis falla y cerramos, **efectivo perdido: $0**
(solo mi tiempo).

## 4. Plan por fases

- **F0 — Validar ($0).**
  1. **Tú:** creas/usas cuenta Algora con tu GitHub y completas el KYC de Stripe
     Express + conectas wallet o banco (~45 min, una vez). Te doy pasos exactos.
  2. **Yo:** monitoreo Algora/Opire/OnlyDust, selecciono 3–5 bounties de nuestro
     nicho, y por cada uno: leo el repo, escribo la solución + tests, dejo el PR
     listo.
  3. **Tú:** revisas cada PR (~20 min), comentas para reclamar y lo envías bajo
     tu cuenta. (El PR va bajo tu identidad; yo hago el trabajo.)
  4. Medimos contra el gate.
- **F1 — Ritmo (si ganamos ≥1, $0).** Subir a 2–4 PRs/semana enfocados; empezar
  a construir reputación con 2–3 maintainers clave para que asignen directo.
- **F2 — Escalar (si hay ingreso constante, $0).** Priorizar bounties grandes
  ($300–$2,500), pedir asignación previa (sin competir), y evaluar bug bounties
  de seguridad (Immunefi paga mucho más, si tu perfil calza).

## 5. Economía

| Concepto | F0 | F1 | F2 |
|---|---|---|---|
| Efectivo out | $0 | $0 | $0 |
| Ingreso esperado (bruto) | $50–300 | $200–800/mes | $500–2,000/mes |
| Comisión plataforma | ~10% | ~10% | ~10% |
| Tu tiempo | ~45 min + revisar | ~1 hr/sem | ~1–2 hr/sem |

**Break-even:** inmediato — no hay efectivo que recuperar. Todo ingreso es utilidad
(menos 10% de comisión e impuestos que tú manejas).

**Honestidad de CEO:** el riesgo NO es perder dinero (es $0), es **perder mi
tiempo si elegimos mal los bounties**. Por eso el gate mide tasa de aceptación:
si es baja, el problema es la selección y lo corrijo, no se tira más esfuerzo.

## 6. Lo que necesito de ti (accionista)

1. **Aprobar ✅ este proyecto.**
2. **~45 min una vez:** cuenta Algora (con tu GitHub `Jorge-Polanco-Roque`) + KYC
   Stripe Express + destino de pago (wallet MetaMask o banco).
3. **~20 min por bounty:** revisar mi PR y enviarlo bajo tu cuenta (los PRs salen
   con tu nombre; yo hago el código).

## 7. Riesgos y cómo los mato

| Riesgo | Mitigación |
|---|---|
| 158 PRs compiten por un bounty | Solo ataco nichos poco competidos (Rust/ML/CV/gamedev) y dificultad media-alta. |
| PR rechazado tras trabajarlo | Tests + CI verde + seguir la guía del repo; leo issues cerrados para calibrar el estilo del maintainer. |
| Tiempo perdido sin ganar | Gate de tasa de aceptación ≥25%; si baja, ajusto selección antes de seguir. |
| KYC/fiscal | Tú controlas la cuenta y el KYC; ingresos a tu nombre, tú declaras. |
| Dependencia de una plataforma | Diversifico entre Algora/Opire/OnlyDust/IssueHunt. |

---

### Decisión del consejo

- [ ] ✅ Aprobar y arrancar F0
- [ ] ❌ Rechazar
- [ ] 🔁 Ajustar (dime qué cambiar)
