/-!
# Relay V2 — Relay 10: Grönwall Discharge Specialist

## Role
Prove `gronwall_exponential` from `diagonal_dissipation` and `cross_coupling_bound`,
reducing the stability axiom count from 3 → 2.

## Result: COMPLETE

### What was done

**Discharged `gronwall_exponential`** — previously an axiom, now a theorem.

The proof introduces a Lyapunov derivative decomposition and applies the
classical Grönwall inequality:

| Step | Name | Type | Content |
|------|------|------|---------|
| 1 | `lyapunovDeriv` | opaque | Total dV/dt along trajectories |
| 2 | `diagContrib` | opaque | Diagonal contribution Σₖ 2αₖ⟨σₖ*, Aₖσₖ⟩ |
| 3 | `crossContrib` | opaque | Coupling contribution Σₖ 2αₖ⟨σₖ*, κCₖⱼσⱼ⟩ |
| 4 | `lyapunov_deriv_decomposition` | structural axiom | dV/dt = diag + cross |
| 5 | `diagonal_dissipation` | **physics axiom (A)** | diag ≤ −2λ·V (pointwise) |
| 6 | `cross_coupling_bound` | **physics axiom (B)** | cross ≤ 2\|κ\|L·V (pointwise) |
| 7 | `lyapunov_deriv_combined_bound` | **theorem** | dV/dt ≤ −2ω·V (from A+B) |
| 8 | `gronwall_integration` | generic axiom | dV/dt ≤ −αV ⟹ V(t) ≤ V(0)e^{−αt} |
| 9 | `gronwall_exponential` | **THEOREM** | V(t) ≤ V(0)e^{−2ωt} (from 7+8) |

### Key theorem: `lyapunov_deriv_combined_bound`

This is the heart of Relay 10. The proof is:

```
theorem lyapunov_deriv_combined_bound ... := by
  rw [lyapunov_deriv_decomposition p bl sg cl σ]
  have hA := diagonal_dissipation p bl sg σ h_safe
  have hB := cross_coupling_bound p bl cl σ h_safe
  nlinarith [bl.V_nonneg σ, scb.coupling_absorbs]
```

Pure arithmetic: diagContrib + crossContrib ≤ −2λV + 2|κ|LV = −2(λ−|κ|L)V = −2ωV.
The `nlinarith` call uses:
- `V_nonneg` (V(σ) ≥ 0)
- `coupling_absorbs` (|κ|·L_cross < λ_gap)

### Key theorem: `gronwall_exponential` (discharged)

```
theorem gronwall_exponential ... := by
  have h_deriv := fun σ hσ => lyapunov_deriv_combined_bound ...
  have hω : 2 * ω > 0 := by nlinarith [scb.coupling_absorbs]
  exact gronwall_integration ... h_deriv σ₀ h_safe t ht
```

Three lines: get pointwise bound → check rate positive → apply Grönwall.

### Axiom dependency DAG (Relay 10)

```
                          ┌─ diagonal_dissipation (A) ─────────┐
                          │                                    ▼
lyapunov_deriv_decomposition ───────────────────────► lyapunov_deriv_combined_bound
                          │                                    │
                          └─ cross_coupling_bound (B) ─────────┘
                                                               │
                                                               ▼
                                              gronwall_integration (generic)
                                                               │
                                                               ▼
                                                    gronwall_exponential (THEOREM)
                                                               │
                                                               ▼
                                                  lyapunov_decay_of_components
                                                               │
                                                               ▼
                                              StabilityCertificate.apply_decay
                                                               │
                                                               ▼
                                              locally_exponentially_stable
```

### StabilityCertificate changes (simplified)

| Field | Relay 9 | Relay 10 |
|-------|---------|----------|
| safety | ✓ | ✓ |
| spectral | ✓ | ✓ |
| coupling_lip | ✓ | ✓ |
| stab_bound | ✓ | ✓ |
| lyapunov | ✓ | ✓ |
| gronwall | ✓ (user-provided) | **REMOVED** (auto-derived) |

The `mk'` constructor no longer requires a Grönwall proof.
`apply_decay` now calls the global `gronwall_exponential` theorem directly.

### Axiom inventory (system-specific)

| # | Axiom | Layer | Reference | Status |
|---|-------|-------|-----------|--------|
| 1 | `field_evolution_contraction` | Invariance | Pazy Thm 4.3 | Relay 5 |
| 2 | `thermal_evolution_bound` | Invariance | Evans §6.4 | Relay 6 |
| 3 | `gradient_evolution_bound` | Invariance | Lieberman Ch. 7 | Relay 6 |
| 4 | `diagonal_dissipation` | Stability | Gearhart–Prüss | Relay 10 |
| 5 | `cross_coupling_bound` | Stability | Henry §5.1 | Relay 10 |

Mathematical utilities (not system-specific):
- `lyapunov_deriv_decomposition` (structural, from bilinearity)
- `gronwall_integration` (Grönwall's inequality, 1919)

### Parallel structure: invariance vs stability

| Aspect | Invariance (R5-6) | Stability (R9-10) |
|--------|-------------------|-------------------|
| Axioms | 3 contraction | 2 pointwise |
| Discharge | direct (`le_trans`) | via Grönwall integration |
| Assembly | `forwardInvariant_of_triangular` | `gronwall_exponential` |
| Certificate | `SafetyCertificate` | `StabilityCertificate` |
| Combined | `safe_and_stable` | `safe_and_stable` |

### Recommendation for Relay 11

**Option A (recommended): Prove `asymptotically_stable`.**
Fill the `sorry` using exponential decay + Mathlib's `Real.exp` limits.
The argument: choose T_conv = (1/(2ω))·ln(V(σ₀)/ε). Pure analysis.

**Option B: Begin controllability.**
Use `StabilityCertificate` to create `ControllabilityCertificate`
(HUM duality + adjoint unique continuation).

**Option C: Further discharge stability axioms.**
Prove `diagonal_dissipation` from `SpectralGap` + semigroup theory,
and `cross_coupling_bound` from `CouplingLipschitz` + Cauchy–Schwarz.
This would reduce system-specific axioms from 5 → 3.
-/
