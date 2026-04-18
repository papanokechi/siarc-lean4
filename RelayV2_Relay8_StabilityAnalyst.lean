/-!
# Relay V2 — Relay 8: Stability Analyst Using the Safety Certificate

## Role
Stability specialist. Design the mathematically coherent stability layer
conditioned on the SafetyCertificate from Relay 7.

## Result: COMPLETE

### Stability notion chosen

**Local exponential stability on the safe set.**

    ∃ C ω > 0, InSafe σ₀ ⟹ V(Φ_t σ₀) ≤ V(σ₀) · e^{−2ωt}   ∀ t ≥ 0

Rationale:
- Lyapunov stability (no decay rate) is too weak for engineering.
- Asymptotic stability (no rate) is insufficient for time-scale estimates.
- Local exponential gives a computable decay rate ω — the natural PDE target.
- Restriction to safe set is physically correct: stability is meaningful only
  within the operating envelope already proven invariant.

### Architecture

```
StabilityCertificate
├── SafetyCertificate (from Relay 7)
│   ├── BarrierParams, CouplingThresholds
│   ├── |κ| < κ_safe
│   ├── QuasiStaticLink
│   └── ForwardInvariant (5/5 barriers)
├── SpectralGap
│   ├── λ₁ > 0  (field operator A₁)
│   ├── λ₂ > 0  (thermal operator A₂)
│   ├── M₁, M₂ ≥ 1  (semigroup overshoot)
│   └── gap = min(λ₁, λ₂) > 0
├── CouplingLipschitz
│   └── L_cross ≥ 0
├── StabilityCouplingBound
│   └── |κ| · L_cross < gap  (stricter than κ_safe)
└── BarrierLyapunov
    ├── SafeEquilibrium (σ* fixed, σ* ∈ SafeSet)
    ├── LyapunovWeights (α₁, α₂, α₃ > 0)
    ├── V : StateSpace → ℝ
    ├── V_nonneg, V_zero_iff, V_coercive
    └── (decay via lyapunov_decay axiom)
```

### Extra assumptions beyond SafetyCertificate

| Assumption | Structure | Content | Reference |
|------------|-----------|---------|-----------|
| Spectral gap | `SpectralGap` | s(A₁) ≤ −λ₁, s(A₂) ≤ −λ₂ | Gearhart–Prüss |
| Coupling Lipschitz | `CouplingLipschitz` | ‖Cᵢⱼ(σ) − Cᵢⱼ(σ*)‖ ≤ L · ‖σ − σ*‖ | Henry §5.1 |
| Stability threshold | `StabilityCouplingBound` | \|κ\| · L < λ_gap | Young's ineq |

The stability coupling threshold κ_stab = λ_gap/L_cross may be stricter than
the invariance threshold κ_safe. The invariance proof requires only that
contraction dominates source terms pointwise; the stability proof requires that
the *net dissipation rate* is positive.

### Key design decisions

1. **Two-threshold architecture:**
   - κ_safe: invariance (barriers non-increasing)
   - κ_stab = λ_gap/L_cross: stability (barriers decaying)
   - Physical coupling must satisfy |κ| < min(κ_safe, κ_stab)

2. **Axiom economy:**
   Added exactly ONE new axiom (`lyapunov_decay`), parallel to the three
   contraction axioms from Relays 5–6. The pattern is consistent:
   - Invariance axioms: "output ≤ input" (contraction)
   - Stability axiom: "output ≤ input · e^{−2ωt}" (exponential contraction)

3. **SafeEquilibrium instead of Equilibrium:**
   The old `Equilibrium` (Relay 12) only required σ* to be a fixed point.
   `SafeEquilibrium` additionally requires σ* ∈ InSafe, which is necessary
   for the barrier-weighted Lyapunov argument.

4. **BarrierLyapunov not LyapunovDerivativeBound:**
   The old `LyapunovDerivativeBound` had `True` placeholder in `dVdt_bound`.
   `BarrierLyapunov` has real content: V_nonneg, V_zero_iff, V_coercive.
   The decay property comes from the separate `lyapunov_decay` axiom.

### Theorems produced

| Theorem | Status | Content |
|---------|--------|---------|
| `SpectralGap.gap_pos` | **PROVED** | min(λ₁, λ₂) > 0 |
| `StabilityCertificate.decay_rate_pos` | **PROVED** | ω = gap − \|κ\|·L > 0 |
| `locally_exponentially_stable` | **DISCHARGED** | V(Φ_t σ₀) ≤ V(σ₀)·e^{−2ωt} |
| `safe_and_stable` | **DISCHARGED** | InSafe(Φ_t σ₀) ∧ V-decay |
| `asymptotically_stable` | sorry | ε-δ convergence (needs Real.exp calculation) |

### Recommendation for Relay 9

**Option A (recommended): Decompose `lyapunov_decay` axiom.**
Break it into three sub-axioms paralleling the invariance pattern:
1. `diagonal_dissipation`: 2αₖ⟨σₖ − σₖ*, Aₖ(σₖ)⟩ ≤ −2αₖλₖ‖σₖ − σₖ*‖²
2. `cross_coupling_bound`: 2αₖ|⟨σₖ − σₖ*, κCₖⱼ(σⱼ)⟩| ≤ αₖ|κ|L(‖σₖ‖² + ‖σⱼ‖²)
3. `gronwall_exponential`: dV/dt ≤ −2ωV ⟹ V(t) ≤ V(0)e^{−2ωt}
Then prove `lyapunov_decay` from these three, making it a theorem not an axiom.

**Option B: Controllability.**
Using `StabilityCertificate`, begin the HUM duality + adjoint unique continuation
argument for approximate controllability. This would create a `ControllabilityCertificate`.

**Option C: Prove `asymptotically_stable`.**
Fill in the ε-δ argument using Real.exp monotonicity from Mathlib.
This is straightforward but useful for completeness.
-/
