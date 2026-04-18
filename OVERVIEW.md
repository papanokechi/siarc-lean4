# SIARC Overview

## What is SIARC?

**SIARC** (Safety, Invariance, And Resilient Control) is a Lean 4 + Mathlib4
formalization proving that a coupled PDE-ODE system — specifically a
thermoelastic field–thermal–structural system — is simultaneously **safe**,
**stable**, and **controllable**.

The artifact takes 6 physical axioms about the PDE operators (contraction,
maximum principle, spectral gap, coupling Lipschitz bound, unique
continuation) and produces a single `MasterCertificate` carrying machine-
checked proofs of all four guarantees.

## The Three Certificate Layers

The formalization builds a stack of three certificates, each extending the
previous:

| Layer | Certificate | What it proves |
|-------|-------------|----------------|
| 1. Invariance | `SafetyCertificate` | Trajectories starting in the safe operating envelope remain there for all time. Five barrier functions (field strength, gradient, curvature, quench temperature, stress) are forward-invariant. |
| 2. Stability | `StabilityCertificate` | A Lyapunov functional V decays exponentially: V(σ(t)) ≤ V(σ₀)·e^{−2ωt}. For any ε > 0, V eventually drops below ε. |
| 3. Controllability | `ControllabilityCertificate` | The system is approximately controllable via the Hilbert Uniqueness Method (HUM). Any target state can be approached to arbitrary precision. |

These are bundled into `MasterCertificate`, and the single theorem
`master_certificate_summary` extracts all four guarantees at once.

## The Axiom Boundary

The formalization rests on **9 axioms** (6 system-specific + 3 utility):

### System-specific axioms (require PDE proofs)

| # | Axiom | PDE Reference | Role |
|---|-------|---------------|------|
| 1 | `field_evolution_contraction` | Pazy Thm 4.3 (Lumer–Phillips) | ‖Φ_t(σ₀).field‖ ≤ ‖σ₀.field‖ |
| 2 | `thermal_evolution_bound` | Evans §6.4 (max principle + ABP) | θ(t) ≤ T_quench |
| 3 | `gradient_evolution_bound` | Lieberman Ch. 7 (Bernstein) | ‖∇θ(t)‖ ≤ gradT_max |
| 4 | `diagonal_dissipation` | Gearhart–Prüss theorem | diag(dV/dt) ≤ −2λ·V |
| 5 | `cross_coupling_bound` | Henry §5.1 (Lipschitz coupling) | cross(dV/dt) ≤ 2\|κ\|L·V |
| 6 | `unique_continuation` | Carleman estimates (Zuazua 2007) | B\*φ ≡ 0 ⟹ φ_T = 0 |

### Utility axioms (standard functional analysis)

| # | Axiom | Status |
|---|-------|--------|
| 7 | `lyapunov_deriv_decomposition` | Structural identity |
| 8 | `gronwall_integration` | Grönwall (1919) |
| 9 | `hum_density_of_reachable_set` | Lions (1988) — active |
| — | `exp_decay_eventually_small` | **Discharged** to theorem (Relay 18) |
| — | `forward_adjoint_duality` | **Discharged** to theorem (Relay 18) |

Three unused axioms were removed in Relay 23 (`nagumo_invariance`,
`unique_minimizer_of_coercive_strictly_convex`, `euler_lagrange_optimal_control`).

## The Numerical Instance

The thermoelastic example (`Example_ThermoelasticParameters.lean`) provides
concrete parameter values (B_max = 10, T_quench = 1500, σ_yield = 300, etc.)
and proves all 19 numerical inequalities automatically via `norm_num`, `simp`,
`linarith`, and `nlinarith`. No manual arithmetic anywhere.

## The Trusted Core

The artifact is split into two zones (see `TrustedBoundary.lean`):

- **Trusted Core** (12 files, 0 sorry) — all theorems, certificates, API.
  The theorem layer treats `evolutionMap` as opaque and derives guarantees
  from the 6 system-specific axioms alone.

- **Untrusted Infrastructure** (3 files, 8 sorry) — PDE semigroup bodies
  and well-posedness uniqueness. These are placeholders awaiting future
  Mathlib PDE theory. They cannot affect theorem correctness because the
  theorem layer never unfolds them.

## How to Use

```lean
import SIARCRelay11.API

-- Given a MasterCertificate mc and initial state σ₀ in the safe set:
-- master_certificate_summary mc σ₀ h_safe
-- returns a proof of (safety ∧ decay ∧ convergence ∧ controllability).
```

## How to Build

```bash
lake exe cache get   -- fetch Mathlib cache
lake build           -- build everything
```

See `BUILD.md` for full instructions and `ARTIFACT.md` for the detailed
axiom inventory, sorry audit, and replay recipe.
