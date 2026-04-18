/-!
# Relay V2 — Relay 7: Invariance Abstraction & Export Specialist

## Role
Abstraction engineer. Lift the fully discharged invariance proof into a reusable
framework and export it as a single `SafetyCertificate` for downstream relays.

## Result: COMPLETE

### Files created/modified

| File | Action | Content |
|------|--------|---------|
| `ForwardInvarianceFramework.lean` | **NEW** | Abstract framework + SafetyCertificate |
| `Invariance.lean` | Modified | Refactored assembly, updated docstring |
| `SIARCRelay11.lean` | Modified | New import, updated status + file tree |

### What was built

#### 1. Abstract barrier/flow structures
- `BarrierFn X` — a real-valued barrier function on state space X
- `Flow X` — a time-parametrized flow map Φ_t : X → X
- `InvariantUnder φ g` — single barrier invariance under a flow
- `ForwardInvariant φ P` — predicate invariance under a flow

#### 2. Triangular DAG structure
- `TriangularDAG X` — 5 barriers organized as root → hub → {leaf₁, leaf₂, leaf₃}
- `TriangularDAG.safeSet` — conjunction of all 5 barriers ≥ 0
- `forwardInvariant_of_triangular` — general assembly theorem:
  given individual barrier invariance (with DAG dependencies), produces
  `ForwardInvariant φ dag.safeSet`

#### 3. SIARC instantiation
- `siarc_dag p` — maps g₁→root, g₄→hub, g₂→leaf₁, g₃'→leaf₂, g₅→leaf₃
- `siarc_flow` — wraps `evolutionMap` as a `Flow`
- `siarc_dag_safeSet_eq` — proves DAG safe set ↔ AllBarriersSatisfied
  (handles the reordering: DAG order vs AllBarriersSatisfied order)
- `siarc_forwardInvariant` — wires all 5 barrier lemmas into the abstract theorem

#### 4. SafetyCertificate
```
structure SafetyCertificate where
  params : BarrierParams
  thresholds : CouplingThresholds
  coupling_small : |κ| < κ_safe thresholds
  qs_link : QuasiStaticLink params
  invariance : ForwardInvariant siarc_flow (siarc_dag params).safeSet
```
- `SafetyCertificate.mk'` — constructor that auto-derives invariance
- `SafetyCertificate.apply` — extracts `AllBarriersSatisfied` at evolved state
- `SafetyCertificate.apply_InSafe` — extracts `InSafe` at evolved state
- `SafetyCertificate.iterate` — composition for time stepping

#### 5. Invariance.lean refactoring
- `safe_manifold_invariance` now uses `refine ⟨?_, ?_, ?_, ?_, ?_⟩` with
  labeled DAG-order goals (ROOT, LEAF₁, LEAF₂, HUB, LEAF₃)
- Docstring updated to reference ForwardInvarianceFramework.lean

### Design decisions

1. **DAG order vs AllBarriersSatisfied order:**
   - `AllBarriersSatisfied` uses: g₁, g₂, g₃', g₄, g₅ (physical order)
   - `TriangularDAG` uses: root(g₁), hub(g₄), leaf₁(g₂), leaf₂(g₃'), leaf₃(g₅)
   - `siarc_dag_safeSet_eq` bridges the two with a simple permutation proof

2. **SafetyCertificate.mk' vs manual construction:**
   - `mk'` takes only `(p, ct, hκ, link)` and auto-derives `invariance`
   - This ensures the invariance proof is always consistent with the parameters

3. **Flow wrapping:**
   - `evolutionMap` takes explicit type parameters `(F T S)`
   - `siarc_flow` wraps it into a `Flow (StateSpace F T S)` for the abstract API

4. **No removal of concrete theorems:**
   - `safe_manifold_invariance` and `InSafe_invariance` are retained in Invariance.lean
   - The framework provides a parallel abstract API, not a replacement

### Downstream usage pattern

```lean
-- Relay 8+ can do this:
variable (cert : SafetyCertificate)

-- Use invariance in stability proof:
theorem stable_of_invariant (σ₀ : StateSpace F T S) (h : InSafe cert.params σ₀)
    (t : ℝ) (ht : t ≥ 0) : InSafe cert.params (evolutionMap t ht F T S σ₀) :=
  cert.apply_InSafe σ₀ h t ht
```

### Recommendation for Relay 8

With `SafetyCertificate` available, Relay 8 should begin **stability analysis**:

1. **Gearhart–Prüss spectral condition:**
   For the linearized semigroup e^{tL}, prove the spectral bound
   s(L) < 0 (all eigenvalues have negative real part).
   This gives exponential stability: ‖e^{tL}‖ ≤ M·e^{-ωt}.

2. **Lyapunov approach (alternative):**
   Construct V(σ) = Σ αₖ·gₖ(σ) and prove dV/dt ≤ −ω·V inside the safe set.
   The `SafetyCertificate` provides the safe-set invariance needed for V > 0.

3. **Structure:**
   Create `StabilityCertificate` extending `SafetyCertificate` with a spectral gap ω > 0
   and a decay rate bound. This would be the natural continuation of the certification pattern.

The key insight: stability *requires* invariance as a precondition (you need to know
the state stays in the safe set before you can analyze its asymptotic behavior).
The `SafetyCertificate` provides exactly this precondition.
-/
