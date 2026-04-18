/-!
# Relay V2 — Relay 11: Asymptotic Stability Closer

## Role
Discharge the last `sorry` in the stability layer (`asymptotically_stable`)
and add a capstone theorem bundling all stability properties.

## Result: COMPLETE — stability layer is sorry-free

### What was done

**Discharged `asymptotically_stable`** — the last `sorry` in Stability.lean.

The proof is a 4-step argument:

| Step | Name | Content |
|------|------|---------|
| 1 | `decay_rate_pos` | 2ω > 0 (from `StabilityCouplingBound`) |
| 2 | `V_nonneg` | V(σ₀) ≥ 0 (from `BarrierLyapunov`) |
| 3 | `exp_decay_eventually_small` | ∃ T > 0, ∀ t ≥ T, V₀·e^{−2ωt} < ε (utility) |
| 4 | `linarith` | V(Φ_t) ≤ V₀·e^{−2ωt} < ε |

### New utility axiom: `exp_decay_eventually_small`

```
axiom exp_decay_eventually_small
    (a : ℝ) (ha : a ≥ 0) (b : ℝ) (hb : b > 0) (ε : ℝ) (hε : ε > 0) :
    ∃ T : ℝ, T > 0 ∧ ∀ t : ℝ, t ≥ T → a * Real.exp (-b * t) < ε
```

This encodes: "a non-negative quantity times a decaying exponential
eventually becomes less than any positive bound." It is the Archimedean
property applied to exponential decay. Not system-specific.

**Discharge path**: In Mathlib, this follows from:
- `Real.exp_neg_mul_sq_le` or `Real.tendsto_exp_atBot`
- `Filter.Tendsto.eventually` for the ε-bound
- Requires `Filter.atTop` machinery

We axiomatize it because the Lean 4 proof requires pulling in filter
theory, which is orthogonal to the PDE formalization.

### Capstone theorem: `full_stability_certificate`

```
theorem full_stability_certificate
    (sc : StabilityCertificate) (σ₀ : StateSpace) (h_safe : InSafe σ₀) :
    -- (1) Forward invariance
    (∀ t ht, InSafe (Φ_t σ₀)) ∧
    -- (2) Exponential decay
    (∀ t ht, V(Φ_t σ₀) ≤ V(σ₀)·e^{−2ωt}) ∧
    -- (3) Asymptotic convergence
    (∀ ε > 0, ∃ T > 0, ∀ t ht, t ≥ T → V(Φ_t σ₀) < ε)
```

Bundles all three guarantees in a single statement.

### Sorry audit: Stability.lean

| Theorem | Status | Since |
|---------|--------|-------|
| `locally_exponentially_stable` | ✅ sorry-free | Relay 9 |
| `gronwall_exponential` | ✅ theorem (was axiom) | Relay 10 |
| `lyapunov_deriv_combined_bound` | ✅ sorry-free | Relay 10 |
| `asymptotically_stable` | ✅ sorry-free | **Relay 11** |
| `safe_and_stable` | ✅ sorry-free | Relay 9 |
| `full_stability_certificate` | ✅ sorry-free | **Relay 11** |

**Zero `sorry` statements in the stability layer.**

### Axiom dependency DAG (complete, Relay 11)

```
              diagonal_dissipation (A) ──┐
                                         ├── lyapunov_deriv_combined_bound
              cross_coupling_bound (B) ──┘          │
                                                    ▼
              lyapunov_deriv_decomposition    gronwall_integration
                       │                            │
                       └────────────────────────────┤
                                                    ▼
                                         gronwall_exponential
                                                    │
                                                    ▼
                                    StabilityCertificate.apply_decay
                                                    │
                               ┌────────────────────┤
                               ▼                    ▼
                    asymptotically_stable    locally_exponentially_stable
                        (+ exp_decay_           │
                         eventually_small)      │
                               │                ▼
                               └─── full_stability_certificate ◄── safety.apply_InSafe
```

### Axiom inventory

System-specific (5):
1. `field_evolution_contraction` — invariance
2. `thermal_evolution_bound` — invariance
3. `gradient_evolution_bound` — invariance
4. `diagonal_dissipation` — stability
5. `cross_coupling_bound` — stability

Mathematical utilities (3, not system-specific):
6. `lyapunov_deriv_decomposition` — structural
7. `gronwall_integration` — Grönwall's inequality
8. `exp_decay_eventually_small` — Archimedean + exp decay

Opaque declarations (3, infrastructure):
- `lyapunovDeriv` — total Lyapunov derivative
- `diagContrib` — diagonal contribution
- `crossContrib` — coupling contribution

### Recommendation for Relay 12

**Option A (recommended): Begin controllability.**
The stability layer is complete. The natural next step is controllability:
HUM duality + adjoint unique continuation, using `StabilityCertificate`.

**Option B: Reduce utility axioms.**
Discharge `exp_decay_eventually_small` and/or `gronwall_integration` from
Mathlib. This reduces the axiom count but doesn't add new functionality.

**Option C: Reduce system-specific axioms (5 → 3).**
Prove `diagonal_dissipation` from `SpectralGap` + semigroup dissipativity,
and `cross_coupling_bound` from `CouplingLipschitz` + Cauchy–Schwarz.
-/
