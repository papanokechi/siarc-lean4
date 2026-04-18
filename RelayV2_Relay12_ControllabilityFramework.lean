/-!
# Relay V2 — Relay 12: Controllability Analyst (HUM + Adjoint System)

## Role
Build the mathematical framework for approximate controllability using
the Hilbert Uniqueness Method (HUM), mirroring how Relay 8 set up
the stability framework.

## Result: COMPLETE — controllability layer scaffolded

### What was done

Rewrote `Controllability.lean` from placeholder stubs to a fully structured
HUM + adjoint-system framework matching the rigor of the stability layer.

### Structures introduced (8)

| Structure | Section | Content |
|-----------|---------|---------|
| `ControlSpace` | §1 | Abstract Hilbert space U of control inputs |
| `ControlOperator` | §1 | Bounded B : U → X with ‖B u‖ ≤ M‖u‖ |
| `AdjointEvolution` | §2 | Backward evolution Ψ_t solving −dφ/dt = A*φ + κC*φ |
| `ObservationOperator` | §3 | Bounded B* : X → U with ‖B*σ‖ ≤ M(‖σ.field‖+‖σ.thermal‖) |
| `ObservabilityGramian` | §4 | Q(φ_T) = ∫‖B*Ψ_t φ_T‖²dt, positive-definite |
| `ObservabilityInequality` | §4 | ‖φ_T‖² ≤ C_obs·Q(φ_T) |
| `HUMFunctional` | §4 | J = ½Q − ⟨·, gap⟩, strictly convex + coercive |
| `ControllabilityCertificate` | §7 | Bundles stability + HUM + observability |

### Predicates introduced (2)

| Predicate | Content |
|-----------|---------|
| `ApproximatelyControllable` | ∀ σ₀ σ_target ε > 0, ∃ u, ‖Φ_T^u(σ₀) − σ_target‖ < ε |
| `SafeApproximatelyControllable` | Same, but σ₀, σ_target ∈ InSafe and trajectory stays safe |

### Axioms introduced (2)

| Axiom | Type | Content |
|-------|------|---------|
| `unique_continuation` | **System-specific #6** | B*φ ≡ 0 on [0,T] ⟹ φ_T = 0 |
| `forward_adjoint_duality` | Structural utility | ⟨Φ_t σ, φ⟩ = ⟨σ, Ψ_t φ⟩ |

### Key theorem (Relay 13 target)

```
theorem approximate_controllability_of_UCP
    (adj : AdjointEvolution) (U : ControlSpace) (cop : ControlOperator U)
    (obs : ObservationOperator U) (gram : ObservabilityGramian adj U obs)
    (h_ucp : UniqueContProp adj obs)
    (h_obs_ineq : ObservabilityInequality gram) :
    ApproximatelyControllable adj U cop := sorry
```

The proof outline (for Relay 13):
1. UCP → Q positive-definite (from gram.Q_pos_def)
2. Q pos-def + observability inequality → J coercive
3. J coercive + strictly convex on Hilbert space → unique minimizer φ_T*
4. Euler–Lagrange → u*(t) = B*Ψ_t(φ_T*)
5. Duality → ‖Φ_T^{u*}(σ₀) − σ_target‖ < ε

### Certificate hierarchy (complete)

```
SafetyCertificate (Relay 7)
  └── StabilityCertificate (Relay 8)
        └── ControllabilityCertificate (Relay 12)
              └── full_system_certificate (capstone)
```

Each extends the previous:
- Safety: barriers, forward invariance (5/5 discharged)
- Stability: Lyapunov, exponential decay, asymptotic convergence (0 sorry)
- Controllability: HUM, UCP, approximate steering (1 sorry: main theorem)

### Parallel structure across layers

| Aspect | Invariance | Stability | Controllability |
|--------|-----------|-----------|-----------------|
| Setup relay | 7 (framework) | 8 (framework) | **12 (framework)** |
| Physics axioms | 3 contraction | 2 dissipation | 1 UCP |
| Utility axioms | — | 3 (Grönwall etc.) | 1 (duality) |
| Assembly theorem | `forwardInvariant_of_triangular` | `gronwall_exponential` | `approximate_controllability_of_UCP` |
| Certificate | `SafetyCertificate` | `StabilityCertificate` | `ControllabilityCertificate` |
| Capstone | `safe_manifold_invariance` | `full_stability_certificate` | `full_system_certificate` |

### Full axiom inventory (6 system-specific + 4 utility)

System-specific:
1. `field_evolution_contraction` — invariance (Pazy Thm 4.3)
2. `thermal_evolution_bound` — invariance (Evans §6.4)
3. `gradient_evolution_bound` — invariance (Lieberman Ch. 7)
4. `diagonal_dissipation` — stability (Gearhart–Prüss)
5. `cross_coupling_bound` — stability (Henry §5.1)
6. `unique_continuation` — controllability (Carleman estimates)

Mathematical utilities:
7. `lyapunov_deriv_decomposition` — structural (bilinearity)
8. `gronwall_integration` — Grönwall's inequality (1919)
9. `exp_decay_eventually_small` — Archimedean + exp decay
10. `forward_adjoint_duality` — semigroup adjoint relation

### Recommendation for Relay 13

**Option A (recommended): Discharge `approximate_controllability_of_UCP`.**
The proof is the HUM optimization argument:
1. Show J is coercive from observability inequality
2. Apply direct method → minimizer exists
3. Euler–Lagrange → optimal control
4. Duality → approximate steering
This requires ~2 sub-axioms (Lax–Milgram, Riesz representation) or
one monolithic "HUM optimization" axiom.

**Option B: Supply concrete duality pairing.**
Replace `forward_adjoint_duality` with a concrete inner product
on the product space and prove the duality relation.

**Option C: Safe controllability.**
Prove `SafeApproximatelyControllable` by combining HUM with the
invariance certificate. This ensures controlled trajectories stay safe.
-/
