/-!
# Relay V2 — Relay 14: Global Audit, Axiom Minimization, and Export

## Role
Compress and audit the complete SIARCRelay11 stack. No new PDE content;
this relay is about structure, clarity, and minimality.

## Result: COMPLETE

### What was done

1. **Created `AxiomInventory.lean`** — the new entry point for the mechanization:
   - `SystemAxioms` structure (6 fields, one per physical axiom)
   - `SystemAxioms.standard` (instantiated from global Lean axioms)
   - `MasterCertificate` structure (bundles axioms + controllability certificate)
   - `master_certificate_summary` theorem (the one theorem)
   - Utility axiom classification (8 axioms, documented in comments)
   - Full dependency graph (ASCII art)

2. **Tightened root module** (`SIARCRelay11.lean`):
   - Replaced ~250 lines of relay log with ~70 lines of final status
   - Lists 6 system-specific axioms by name + reference
   - Points to `MasterCertificate` and `master_certificate_summary`
   - Notes sorry-free status across all theorem files
   - Updated file structure to include `AxiomInventory.lean`
   - Added `import SIARCRelay11.Theorems.AxiomInventory`

### Axiom classification (final)

**System-specific (6)** — physical, require PDE proofs:

| # | Name | Layer | What it encodes |
|---|------|-------|-----------------|
| 1 | `field_evolution_contraction` | Invariance | Contraction semigroup |
| 2 | `thermal_evolution_bound` | Invariance | Maximum principle |
| 3 | `gradient_evolution_bound` | Invariance | Bernstein gradient |
| 4 | `diagonal_dissipation` | Stability | Spectral gap |
| 5 | `cross_coupling_bound` | Stability | Coupling Lipschitz |
| 6 | `unique_continuation` | Controllability | UCP via Carleman |

**Generic utility (8)** — standard functional analysis:

| # | Name | Provable from |
|---|------|---------------|
| 7 | `nagumo_invariance` | Brezis (1970) |
| 8 | `lyapunov_deriv_decomposition` | Bilinearity |
| 9 | `gronwall_integration` | Mathlib ODE.Gronwall |
| 10| `exp_decay_eventually_small` | Mathlib Real.exp |
| 11| `forward_adjoint_duality` | Semigroup theory |
| 12| `unique_minimizer_of_coercive_strictly_convex` | Brezis Thm 3.3 |
| 13| `euler_lagrange_optimal_control` | Calculus of variations |
| 14| `hum_density_of_reachable_set` | Lions (1988) |

### One-screenful summary for a referee

```
SystemAxioms (6 physical assumptions)
    ↓  instantiated from global Lean axioms
MasterCertificate
    ↓  bundles ControllabilityCertificate (nests stability + safety)
master_certificate_summary (mc, σ₀, h_safe)
    ↓  proves 4 properties simultaneously
  (1) Safety: ∀ t ≥ 0, σ(t) ∈ InSafe
  (2) Decay: V(σ(t)) ≤ V(σ₀)·e^{−2ωt}
  (3) Convergence: ∀ ε > 0, ∃ T, ∀ t ≥ T, V(σ(t)) < ε
  (4) Controllability: ∀ σ_target ε > 0, ∃ u, ‖σ(T)−σ_target‖ < ε
```

### Relay 15 options

**Option A: Mathlib discharge.** Prove the 8 utility axioms from Mathlib
APIs (Grönwall, convex optimization, exp decay).

**Option B: Concrete instantiation.** Supply a specific SIARC system
(e.g., 2D thermal-structural with distributed control) and verify
the 6 system-specific axioms for it.

**Option C: Export as library.** Extract `AxiomInventory.lean` as a
standalone `.lean` file with minimal imports, suitable for
distribution as a proof artifact.
-/
