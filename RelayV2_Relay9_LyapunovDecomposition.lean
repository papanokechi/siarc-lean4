/-!
# Relay V2 — Relay 9: Lyapunov Decay Decomposition Specialist

## Role
Decompose the monolithic `lyapunov_decay` axiom into three independent,
mathematically meaningful sub-axioms, mirroring the invariance decomposition.

## Result: COMPLETE

### What was done

Replaced ONE monolithic axiom (`lyapunov_decay`) with THREE decomposed axioms:

| Axiom | Content | Reference | Invariance analogue |
|-------|---------|-----------|---------------------|
| `diagonal_dissipation` | dV_diag/dt ≤ −2λ_gap·V | Gearhart–Prüss | `field_evolution_contraction` |
| `cross_coupling_bound` | \|dV_cross/dt\| ≤ 2\|κ\|L·V | Henry §5.1 | coupling bounds in invariance |
| `gronwall_exponential` | V(t) ≤ V(0)·e^{−2ωt} | Gronwall (1919) | `le_trans` in invariance |

Plus a theorem:
- `lyapunov_decay_of_components`: proves the old `lyapunov_decay` from `gronwall_exponential`

### Parallel structure with invariance

The decomposition is *exactly* parallel:

| Layer | Invariance (Relays 5–6) | Stability (Relay 9) |
|-------|-------------------------|---------------------|
| Diagonal | `field_evolution_contraction` | `diagonal_dissipation` |
| Coupling | (absorbed into contraction) | `cross_coupling_bound` |
| Assembly | `le_trans` (transitivity) | `gronwall_exponential` |
| Pattern | output ≤ input | V(t) ≤ V(0)·e^{−2ωt} |

Invariance is the zero-rate special case: contraction means ω = 0 in
the decay formula. Stability adds a positive rate ω > 0.

### StabilityCertificate changes

The certificate now carries the Gronwall axiom directly:

```
structure StabilityCertificate where
  safety      : SafetyCertificate
  spectral    : SpectralGap
  coupling_lip : CouplingLipschitz
  stab_bound  : StabilityCouplingBound
  lyapunov    : BarrierLyapunov
  gronwall    : ∀ σ₀ h_safe t ht, V(Φ_t σ₀) ≤ V(σ₀)·e^{−2ωt}
```

New APIs:
- `StabilityCertificate.mk'` — canonical constructor
- `StabilityCertificate.apply_decay` — extract V-decay (delegates to gronwall)

### Axiom dependency DAG

```
diagonal_dissipation  ───┐
                         ├──→ gronwall_exponential ──→ locally_exponentially_stable
cross_coupling_bound  ───┘                         ──→ safe_and_stable
```

Currently `gronwall_exponential` is a standalone axiom. Relay 10 can
prove it from `diagonal_dissipation` + `cross_coupling_bound` via Gronwall's
lemma, reducing the axiom count from 3 to 2 for stability.

### Full axiom inventory (6 axioms, all named + referenced)

Invariance:
1. `field_evolution_contraction` — Pazy Thm 4.3
2. `thermal_evolution_bound` — Evans §6.4
3. `gradient_evolution_bound` — Lieberman Ch. 7

Stability:
4. `diagonal_dissipation` — Gearhart–Prüss
5. `cross_coupling_bound` — Henry §5.1
6. `gronwall_exponential` — Gronwall (1919)

### Recommendation for Relay 10

**Option A (recommended): Discharge `gronwall_exponential` from (A)+(B).**
The mathematical content is:
1. (A) gives: dV/dt ≤ −2λ·V + (coupling perturbation)
2. (B) bounds: (coupling perturbation) ≤ 2|κ|L·V
3. Combine: dV/dt ≤ −2(λ − |κ|L)·V = −2ω·V
4. Gronwall's lemma: V(t) ≤ V(0)·e^{−2ωt}

Step 4 may be available in Mathlib (`GronwallBound` or similar).
If so, (C) becomes a theorem and the stability axiom count drops to 2.

**Option B: Begin controllability.**
Using `StabilityCertificate`, create a `ControllabilityCertificate`
with HUM duality + adjoint unique continuation.

**Option C: Prove asymptotically_stable.**
Fill in the sorry using `Real.exp` monotonicity from Mathlib.
-/
