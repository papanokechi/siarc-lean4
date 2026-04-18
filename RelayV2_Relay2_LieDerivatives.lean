/-!
# ═══════════════════════════════════════════════════════════════
# RELAY CHAIN v2 — RELAY 2 OUTPUT
# PDE / Lie-Derivative Analyst
# ═══════════════════════════════════════════════════════════════

## Author: Relay 2 (PDE / Lie-Derivative Analyst)
## Date: 2026-04-18
## Input: Relay 1 minimal model + provability map
## Method: Compute Lie derivatives symbolically, classify sign conditions

────────────────────────────────────────────────────────────────
## §0. NOTATION AND CONVENTIONS
────────────────────────────────────────────────────────────────

From Relay 1, the evolution equation on X = X₁ × X₂ × X₃ is:

  ∂σ₁/∂t = A₁(σ₁) + B₁·u                                    (field)
  ∂σ₂/∂t = A₂(σ₂) + κ·C₁₂(σ₁) + B₂·u                      (thermal)
  ∂σ₃/∂t = A₃(σ₃) + κ·C₂₃(σ₂) + B₃·u                      (structural)

where Bᵢ are the components of the control operator B = (B₁, B₂, B₃).

The safe set is M = { σ | gₖ(σ) ≥ 0, k=1,...,5 }.
Its boundary ∂Mₖ = { σ ∈ M | gₖ(σ) = 0 }.

For forward invariance via Nagumo, we need:

  L_f gₖ(σ) ≥ 0   on ∂Mₖ

where L_f gₖ = d/dt gₖ(σ(t))|_{t=0} = Dgₖ(σ) · f(σ,u) is the Lie derivative
of gₖ along the vector field f(σ,u) = A(σ) + Bu.

Convention: gₖ(σ) = threshold − quantity(σ), so gₖ = 0 on the boundary
means quantity = threshold. We need the quantity to not increase, i.e.,
d/dt(quantity) ≤ 0, equivalently L_f gₖ ≥ 0.

────────────────────────────────────────────────────────────────
## §1. LIE DERIVATIVE OF g₁ (FIELD STRENGTH)
────────────────────────────────────────────────────────────────

### Definition
  g₁(σ) = B_max − ‖σ₁‖_{L∞}

### Lie derivative computation

  L_f g₁ = −d/dt ‖σ₁(t)‖_{L∞}

Let x* ∈ M be a point where |σ₁(x*,t)| = ‖σ₁(t)‖_{L∞} (maximum point).
At x*, by the chain rule for the L∞ norm (cf. Danskin's theorem / envelope):

  d/dt ‖σ₁(t)‖_{L∞} = sgn(σ₁(x*)) · ∂σ₁/∂t(x*)
                       = sgn(σ₁(x*)) · [A₁(σ₁)(x*) + B₁u(x*)]

### Decomposition

  L_f g₁ = −sgn(σ₁(x*)) · A₁(σ₁)(x*)     [DISSIPATIVE]
           −sgn(σ₁(x*)) · B₁u(x*)          [CONTROL]

No coupling term — the field equation has no κ·C coupling in it.

### Sign analysis

**DISSIPATIVE term:** −sgn(σ₁(x*)) · A₁(σ₁)(x*)

  If A₁ is a dissipative operator (e.g., Maxwell with conductivity: A₁ = Δ − σ_cond),
  then at a maximum point x* of |σ₁|, the Laplacian satisfies:

    Δ|σ₁|(x*) ≤ 0  (maximum principle for the Laplacian)

  So sgn(σ₁(x*)) · Δσ₁(x*) ≤ 0, giving −sgn(σ₁(x*)) · A₁(σ₁)(x*) ≥ 0.

  More precisely, if A₁ generates a contraction semigroup (Lumer–Phillips), then:

    d/dt ‖S₁(t)σ₁‖ ≤ 0  ⟹  DISSIPATIVE ≥ 0  ✓

**CONTROL term:** −sgn(σ₁(x*)) · B₁u(x*)

  This is sign-indefinite. It can be made non-negative if the control u
  is chosen so that B₁u does not amplify the field at x*.
  Sufficient condition: B₁u ≡ 0 (no direct field control), or
  B₁u has the same sign as −σ₁ at the maximum (feedback damping).

### Verdict for g₁

  L_f g₁ = [≥ 0 by dissipativity] + [≥ 0 if control is safe]

  **PROVABLE** under:
  (P2) A₁ is dissipative (generates contraction semigroup)
  (U1) Control satisfies: sgn(σ₁(x*)) · B₁u(x*) ≤ 0 at the L∞-attaining point
       (or B₁ = 0, i.e., no direct actuation on the field component)

────────────────────────────────────────────────────────────────
## §2. LIE DERIVATIVE OF g₂ (THERMAL GRADIENT)
────────────────────────────────────────────────────────────────

### Definition
  g₂(σ) = ∇T_max − ‖∇σ₂‖_{L∞}

### Lie derivative computation

  L_f g₂ = −d/dt ‖∇σ₂(t)‖_{L∞}

Differentiate ∂σ₂/∂t = A₂(σ₂) + κ·C₁₂(σ₁) + B₂u, then apply ∇:

  ∂(∇σ₂)/∂t = ∇A₂(σ₂) + κ·∇C₁₂(σ₁) + ∇B₂u

For the heat operator A₂ = div(K∇·) with conductivity tensor K(x):

  ∇A₂(σ₂) = ∇div(K∇σ₂)

### Decomposition

  L_f g₂ = −d/dt ‖∇σ₂‖_{L∞}

  At the maximum point y* of |∇σ₂|:

  DISSIPATIVE: −sgn(∇σ₂(y*)) · ∇(div(K∇σ₂))(y*)
  COUPLING:    −sgn(∇σ₂(y*)) · κ·∇C₁₂(σ₁)(y*)
  CONTROL:     −sgn(∇σ₂(y*)) · ∇(B₂u)(y*)

### Sign analysis

**DISSIPATIVE:** For the heat equation on a compact manifold with K uniformly
  elliptic (K ≥ k₀ > 0), the Bernstein–Bochner technique gives:

    d/dt ‖∇σ₂‖²_{L²} = −2∫_M K|D²σ₂|² + lower order ≤ 0

  For L∞ of the gradient, a more refined argument is needed (Krylov–Safonov or
  Bernstein method): the maximum of |∇σ₂| satisfies

    d/dt ‖∇σ₂‖_{L∞} ≤ −c · ‖∇σ₂‖_{L∞}  (exponential decay)

  for uniform K. This requires uniform ellipticity of A₂.

  DISSIPATIVE ≥ 0  ✓  (under uniform ellipticity of K)

**COUPLING:** |κ · ∇C₁₂(σ₁)| ≤ |κ| · ‖∇C₁₂‖_{op} · ‖σ₁‖_{H^{s+1}}

  This is bounded but sign-indefinite. On ∂M₂ (where ‖∇σ₂‖ = ∇T_max), we need:

    |κ| · ‖∇C₁₂(σ₁)‖_{L∞} ≤ c · ∇T_max

  i.e., the coupling source gradient cannot exceed the dissipation rate.
  This is a SMALLNESS CONDITION on κ.

**CONTROL:** Similar to g₁ — controllable if ∇(B₂u) is bounded or zero.

### Verdict for g₂

  L_f g₂ = [≥ 0 by ellipticity of K] + [bounded by |κ|·C] + [control term]

  **PROVABLE** under:
  (E1) K is uniformly elliptic: K(x) ≥ k₀ · Id for k₀ > 0
  (P1) |κ| < κ₂* := k₀ · ∇T_max / (‖∇C₁₂‖ · ‖σ₁‖_{H^{s+1}})
  (U2) ‖∇(B₂u)‖_{L∞} bounded (e.g., B₂ smooth and u bounded)

  NOTE: This is the first barrier where small-κ enters non-trivially.
  The threshold κ₂* depends on the field norm (via g₁) and the gradient threshold.
  If g₁ is already controlled, ‖σ₁‖ ≤ B_max, so:

    κ₂* = k₀ · ∇T_max / (‖∇C₁₂‖ · B_max^{s+1})

  This is COMPUTABLE for a given system.

────────────────────────────────────────────────────────────────
## §3. LIE DERIVATIVE OF g₃' (CURVATURE PROXY)
────────────────────────────────────────────────────────────────

### Definition
  g₃'(σ) = C_curv − ‖Riem(σ₃)‖_{L∞}

### Lie derivative computation

  L_f g₃' = −d/dt ‖Riem(σ₃(t))‖_{L∞}

The Riemann curvature tensor of the structural metric g = g₀ + σ₃ satisfies
an evolution equation derived from ∂σ₃/∂t = A₃(σ₃) + κ·C₂₃(σ₂):

  ∂Riem/∂t = D_A₃(Riem) + Q(Riem) + κ · D_C₂₃(Riem, σ₂)

where:
  - D_A₃(Riem): the linearization of the curvature under the structural PDE
  - Q(Riem): quadratic curvature terms (Riem * Riem, standard in Ricci flow theory)
  - D_C₂₃: coupling-induced curvature change from thermal stress

### Decomposition

  STRUCTURAL: −d/dt ‖Riem‖ from the A₃ component
  QUADRATIC:  from Q(Riem) · Riem interaction
  COUPLING:   from κ · D_C₂₃(σ₂)

### Sign analysis — THIS IS THE HARDEST BARRIER

**STRUCTURAL:** Depends critically on the nature of A₃.

  Case (a): A₃ is wave-type (hyperbolic). Then there is NO maximum principle
  for ‖Riem‖. Energy estimates give:

    d/dt ∫ ‖Riem‖² ≤ C · ∫ ‖Riem‖²  (Gronwall-type, curvature can grow)

  Pointwise L∞ bound requires Sobolev embedding:
    ‖Riem‖_{L∞} ≤ C_S · ‖Riem‖_{H^s}, s > n/2

  So g₃' invariance reduces to H^s energy estimates for the structural PDE.
  These are available IF:
  - The structural PDE is well-posed in H^s (from LWP)
  - The H^s energy grows at most exponentially: ‖σ₃(t)‖_{H^s} ≤ C·e^{ωt}·‖σ₃(0)‖_{H^s}
  - On the time interval [0, T*], the Sobolev constant gives:
    ‖Riem(t)‖_{L∞} ≤ C_S · C · e^{ωT*} · ‖σ₃(0)‖_{H^s}

  This is bounded but GROWS with time. So g₃' is NOT invariant for all time —
  only on a finite interval determined by the initial data.

  Case (b): A₃ is quasi-static (elliptic). Then σ₃ is determined algebraically
  by σ₂ (solve A₃(σ₃) = −κ·C₂₃(σ₂)), and ‖Riem‖ is controlled by ‖σ₂‖_{H^{s+2}}.
  This gives g₃' invariance from g₄ (thermal bound) + elliptic regularity. MUCH EASIER.

**QUADRATIC:** |Q(Riem)| ≤ C_Q · ‖Riem‖². At the boundary ∂M₃ where
  ‖Riem‖ = C_curv, this is C_Q · C_curv². This is a constant — absorbable
  into the Gronwall estimate.

**COUPLING:** |κ · D_C₂₃(σ₂)| ≤ |κ| · ‖D_C₂₃‖ · ‖σ₂‖_{H^{s+2}}.
  Controlled by g₄ (thermal sup bound) + Sobolev interpolation.

### Verdict for g₃'

  **Case (a) — Hyperbolic A₃:**
  NOT invariant for all time. Invariant on [0, T*] where:

    T* = (1/ω) · ln(C_curv / (C_S · ‖σ₃(0)‖_{H^s}))

  This is finite but explicit. On [0, T*], the proof works.
  For longer times, need to argue that the trajectory stays in SafeManifold
  by combining with stability (the orbit approaches equilibrium before T*).

  **Case (b) — Quasi-static A₃:**
  PROVABLE directly from g₄ + elliptic regularity. ✓

  **Recommendation:** Relay 3 should decide between (a) and (b).
  Case (b) is dramatically simpler and physically justified in many applications.

────────────────────────────────────────────────────────────────
## §4. LIE DERIVATIVE OF g₄ (QUENCH TEMPERATURE)
────────────────────────────────────────────────────────────────

### Definition
  g₄(σ) = T_quench − ‖σ₂‖_{L∞}

### Lie derivative computation

  L_f g₄ = −d/dt ‖σ₂(t)‖_{L∞}

At the maximum point z* of |σ₂|:

  d/dt σ₂(z*,t) = A₂(σ₂)(z*) + κ·C₁₂(σ₁)(z*) + B₂u(z*)

### Decomposition

  DISSIPATIVE: −sgn(σ₂(z*)) · A₂(σ₂)(z*)
  COUPLING:    −sgn(σ₂(z*)) · κ·C₁₂(σ₁)(z*)
  CONTROL:     −sgn(σ₂(z*)) · B₂u(z*)

### Sign analysis

**DISSIPATIVE:** A₂ = div(K∇·) is the heat operator. At a maximum point z* of σ₂:

    A₂(σ₂)(z*) = div(K∇σ₂)(z*) ≤ 0  (maximum principle)

  So: −sgn(σ₂(z*)) · A₂(σ₂)(z*) = −(+1)(≤ 0) ≥ 0  ✓

  This is the CLASSICAL maximum principle for the heat equation.
  Requires: K uniformly elliptic, M compact, appropriate boundary conditions.

  DISSIPATIVE ≥ 0  ✓  (classical, no additional assumptions)

**COUPLING:** κ·C₁₂(σ₁)(z*) is the thermal source from the field.
  Physically: Joule heating, Q = σ_cond|E|². This is ALWAYS NON-NEGATIVE
  (heat is generated, not absorbed, by electromagnetic fields).

  So C₁₂(σ₁) ≥ 0 (non-negative source), which means:
    −sgn(σ₂(z*)) · κ · C₁₂(σ₁)(z*) ≤ 0  if σ₂(z*) > 0 and κ > 0

  THE COUPLING TERM HAS THE WRONG SIGN FOR g₄.

  This is physically correct: Joule heating RAISES the temperature,
  working against the quench barrier. The dissipation (heat conduction)
  must DOMINATE the coupling source.

  At the boundary ∂M₄ (where σ₂(z*) = T_quench), we need:

    |A₂(σ₂)(z*)| ≥ |κ · C₁₂(σ₁)(z*)|

  i.e., diffusion at the hottest point must exceed heat generation.

  Using the Laplacian estimate at the maximum:
    |A₂(σ₂)(z*)| ≥ k₀ · Δσ₂(z*)  [where Δσ₂(z*) ≤ 0 at max]

  We need a QUANTITATIVE maximum principle:
    −A₂(σ₂)(z*) ≥ c(M, K) · (‖σ₂‖_{L∞} − ‖σ₂‖_{L∞(∂M)})

  This is the Alexandrov–Bakelman–Pucci (ABP) estimate.
  If the boundary data is below T_quench, the interior maximum is controlled.

**CONTROL:** B₂u(z*) is the control input at the hot spot.
  Can be used to actively COOL: choose u so that B₂u(z*) < 0.
  This is the "safe control" condition — the controller acts to prevent quench.

### Verdict for g₄

  L_f g₄ = [≥ 0 max principle] + [≤ 0 Joule heating!] + [sign from control]

  **PROVABLE** under:
  (E1) K uniformly elliptic
  (P1) |κ| < κ₄* := c(M,K) · (T_quench − T_boundary) / (‖C₁₂‖ · B_max²)
       (diffusion dominates Joule heating)
  (U4) Control cools: B₂u(z*) ≤ 0 when σ₂(z*) = T_quench
  (BC) Boundary temperature < T_quench (Dirichlet condition)

  NOTE: κ₄* is the MOST RESTRICTIVE coupling bound in the system.
  The Joule heating term ∝ |σ₁|² ≤ B_max² (from g₁ bound), so:

    κ₄* ∝ diffusion_rate / B_max²

  This is small if the field is strong. Physical interpretation: strong
  electromagnetic fields generate a lot of heat, requiring either
  strong diffusion or active cooling.

────────────────────────────────────────────────────────────────
## §5. LIE DERIVATIVE OF g₅ (STRUCTURAL INTEGRITY)
────────────────────────────────────────────────────────────────

### Definition
  g₅(σ) = σ_yield − ‖VM(σ₃)‖_{L∞}

where VM(σ₃) is the von Mises stress (a nonlinear function of the strain
tensor ε(σ₃) = ½(∇σ₃ + (∇σ₃)ᵀ)):

  VM = √(3/2 · |dev(σ_stress)|²)
  σ_stress = λ tr(ε) Id + 2μ ε     (Hooke's law)

### Lie derivative computation

  L_f g₅ = −d/dt ‖VM(σ₃(t))‖_{L∞}

This is the most algebraically involved barrier because VM is a nonlinear
function of derivatives of σ₃.

Using the chain rule:

  d/dt VM(σ₃) = DVM(ε) · ∂ε/∂t = DVM(ε) · ε(∂σ₃/∂t)
              = DVM(ε) · ε(A₃(σ₃) + κ·C₂₃(σ₂))

### Decomposition

  STRUCTURAL:  DVM · ε(A₃(σ₃))
  COUPLING:    DVM · ε(κ · C₂₃(σ₂))
  CONTROL:     DVM · ε(B₃u)

### Sign analysis

**STRUCTURAL:** A₃ is the elasticity operator. For damped elasticity
  (A₃ = div(C:ε) − η·∂σ₃/∂t where η > 0 is viscosity):

  The elastic energy E = ½∫ C:ε:ε satisfies:

    dE/dt = −η ∫ |∂σ₃/∂t|² ≤ 0  (energy dissipation by viscosity)

  However, energy dissipation does NOT directly imply VM pointwise bound.
  The von Mises stress at a single point can increase even as total energy
  decreases (stress concentration).

  For POINTWISE bounds, need:
  - Korn's inequality: ‖∇σ₃‖_{L²} ≤ C_K · ‖ε(σ₃)‖_{L²}
  - Sobolev embedding: ‖VM‖_{L∞} ≤ C_S · ‖σ₃‖_{H^{s+1}}, s > n/2
  - H^{s+1} energy estimate for the structural PDE

  This gives: ‖VM(t)‖_{L∞} ≤ C_S · C_K · ‖σ₃(t)‖_{H^{s+1}}

  Under the structural PDE with dissipation η > 0:
    ‖σ₃(t)‖_{H^{s+1}} ≤ e^{−η₀t} · ‖σ₃(0)‖_{H^{s+1}} + coupling integrals

  So the structural term is DISSIPATIVE if η > 0.

  STRUCTURAL ≥ 0 ✓ (for DAMPED elasticity with η > 0)
  STRUCTURAL = 0 for UNDAMPED wave elasticity (energy conservation, no sign)

**COUPLING:** |κ · DVM · ε(C₂₃(σ₂))| ≤ |κ| · ‖DVM‖ · ‖C₂₃‖ · ‖σ₂‖_{H^1}

  The thermal stress source. Bounded by:
    |κ| · C_VM · ‖C₂₃‖ · (T_quench)  [using g₄ bound on ‖σ₂‖_{L∞}]

  Needs: thermal expansion coefficient × temperature bounded by yield stress.

**CONTROL:** B₃u is a direct structural actuator. Can be used to reduce stress.

### Verdict for g₅

  L_f g₅ = [≥ 0 if damped] + [bounded by |κ|·C] + [control term]

  **PROVABLE** under:
  (D1) Structural PDE has viscous damping: η > 0
  (P1) |κ| < κ₅* := η · σ_yield / (C_VM · ‖C₂₃‖ · T_quench)
       (viscous dissipation dominates thermal stress)
  (U5) Control does not increase stress: DVM · ε(B₃u) ≤ 0 at yield surface
  (KI) Korn's inequality constant C_K is computable (depends only on M geometry)

  **NOT PROVABLE for undamped wave elasticity** (η = 0). In this case,
  elastic energy is conserved, and stress concentration can occur.
  This confirms Relay 1's observation that the hyperbolic component is
  the hard part.

────────────────────────────────────────────────────────────────
## §6. LIE-DERIVATIVE FEASIBILITY TABLE
────────────────────────────────────────────────────────────────

| # | Barrier | Lie Derivative Structure | Dissipative? | Needs Control? | Needs Small κ? | Provable? |
|---|---------|-------------------------|-------------|----------------|----------------|-----------|
| 1 | g₁ field | −sgn·(A₁ + B₁u) at max | ✓ Lumer–Phillips | Only if B₁≠0 | NO | ✓ Cat A |
| 2 | g₂ ∇T | −sgn·∇(A₂ + κC₁₂ + B₂u) at max | ✓ Bernstein | Mild (∇B₂u bdd) | YES: κ < κ₂* | ✓ Cat B |
| 3 | g₃' curv | −d/dt‖Riem‖ via energy+Sobolev | Hyp: NO / QS: ✓ | No | YES: κ < κ₃* | Hyp: ✓[0,T*] / QS: ✓ |
| 4 | g₄ T_q | −sgn·(A₂ + κC₁₂ + B₂u) at max | ✓ max principle | YES: active cooling | YES: κ < κ₄* | ✓ Cat B |
| 5 | g₅ VM | −DVM·ε(A₃ + κC₂₃ + B₃u) at max | ✓ if η>0 | Stress relief | YES: κ < κ₅* | η>0: ✓ / η=0: ✗ |

### Legend
- "Hyp" = hyperbolic structural PDE, "QS" = quasi-static (elliptic)
- κₖ* = barrier-specific coupling threshold
- Cat A = provable without additional assumptions
- Cat B = provable with explicit parameter choices

────────────────────────────────────────────────────────────────
## §7. THE COUPLING THRESHOLD HIERARCHY
────────────────────────────────────────────────────────────────

Each barrier gives a bound on the coupling:

  κ₁* = ∞  (g₁ has no coupling term)
  κ₂* = k₀ · ∇T_max / (‖∇C₁₂‖ · B_max^{s+1})
  κ₃* = [complex: depends on Sobolev constant and structural energy]
  κ₄* = c(M,K) · (T_quench − T_bdy) / (‖C₁₂‖ · B_max²)
  κ₅* = η · σ_yield / (C_VM · ‖C₂₃‖ · T_quench)

The OVERALL coupling threshold for safe-set invariance is:

  κ* = min(κ₂*, κ₃*, κ₄*, κ₅*)

This is the number that replaces the meaningless "Axiom A2" from the
original scaffold. It is COMPUTABLE from the physical parameters.

Typically κ₄* is the most restrictive (Joule heating vs. diffusion),
unless the structural damping η is very small (then κ₅* dominates).

────────────────────────────────────────────────────────────────
## §8. MINIMAL ASSUMPTIONS SUMMARY
────────────────────────────────────────────────────────────────

For FULL safe-set invariance, we need exactly:

### Operator assumptions
  (P2)  A₁ is dissipative: Re⟨A₁x, x⟩ ≤ −α₁‖x‖² for some α₁ ≥ 0
  (E1)  A₂ = div(K∇·) with K ≥ k₀ > 0 (uniform ellipticity)
  (D1)  A₃ has viscous damping η > 0 (or A₃ is quasi-static)

### Coupling assumption
  (P1)  |κ| < κ* = min(κ₂*, κ₃*, κ₄*, κ₅*)  [computable threshold]

### Control assumptions
  (U1)  Field control safe: sgn(σ₁) · B₁u ≤ 0 at L∞ maximum
  (U4)  Thermal control cools: B₂u ≤ 0 at temperature maximum
  (U5)  Structural control relieves: DVM · ε(B₃u) ≤ 0 at yield surface

### Boundary assumptions
  (BC)  Boundary temperature < T_quench
  (BC2) Boundary displacement compatible with σ_yield

### Regularity
  (SR)  Initial data σ₀ ∈ H^s with s > n/2 + 2

────────────────────────────────────────────────────────────────
## §9. RECOMMENDATIONS FOR RELAY 3
────────────────────────────────────────────────────────────────

### 9.1 Which barriers are already sign-controlled
  g₁ — DONE. Dissipative A₁ gives L_f g₁ ≥ 0 directly. Category A.

### 9.2 Which require small coupling
  g₂, g₃', g₄, g₅ — ALL require |κ| < κₖ*. The threshold κ₄* (Joule
  heating vs. diffusion) is typically the tightest.

### 9.3 Which require structural assumptions
  g₃' — Requires either (a) finite-time argument + Sobolev embedding, or
         (b) quasi-static elasticity. Decision needed.
  g₅  — Requires viscous damping η > 0 in the structural PDE.
         Without damping, pointwise stress bounds are NOT available.

### 9.4 Which require control constraints
  g₁ (mild), g₄ (active cooling), g₅ (stress relief).
  These are DESIGN constraints on the control law, not mathematical obstacles.

### 9.5 Which barrier is the HARDEST
  **g₃' (curvature proxy)** under hyperbolic elasticity is the hardest.
  It requires H^s energy estimates + Sobolev embedding + finite-time horizon.
  Under quasi-static elasticity, it becomes trivial (elliptic regularity).

  **Recommendation:** Relay 3 should ADOPT the quasi-static assumption.
  This is justified whenever structural wave speeds are fast compared to
  thermal and electromagnetic time scales (standard in engineering).

### 9.6 What Relay 3 should do next
  1. **Decide:** hyperbolic vs. quasi-static structural PDE
  2. **Formalize** the Nagumo invariance theorem for the product space
  3. **Assemble** the five barrier Lie derivatives into the invariance proof
  4. **Compute** the explicit coupling threshold κ* for a specific parameter set
  5. **State** the safe control law conditions (U1, U4, U5) as a control design spec

────────────────────────────────────────────────────────────────
## §10. KEY MATHEMATICAL INSIGHT
────────────────────────────────────────────────────────────────

The invariance proof has a TRIANGULAR structure:

  g₁ → controls field norm → no coupling needed
  g₄ → controls temperature → needs g₁ (to bound Joule source) + small κ
  g₂ → controls ∇T → needs g₁ (field bound) + small κ
  g₃' → controls curvature → needs g₄ (temperature bound in structural source) + small κ
  g₅ → controls stress → needs g₄ (thermal stress source) + small κ + damping

This means the invariance proof should proceed IN ORDER: g₁ → g₄ → g₂ → g₃' → g₅.
Each barrier uses the already-established bounds of the previous ones.
This is the correct proof architecture.

────────────────────────────────────────────────────────────────
## END OF RELAY 2 OUTPUT
────────────────────────────────────────────────────────────────
-/
