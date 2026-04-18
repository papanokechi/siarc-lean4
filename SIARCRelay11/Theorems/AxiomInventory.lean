/-!
# SIARCRelay11.Theorems.AxiomInventory — Global Audit and Public API

## Relay 14: Axiom Classification, MasterCertificate, Export
## Relay 18: Mathlib Discharge — 2 utility axioms → theorems
## Relay 23: Removed 3 unused axioms (nagumo, minimizer, Euler–Lagrange)

One-screenful summary of the SIARC mechanization.

### System-specific axioms (6) — require PDE proofs

| # | Name | Layer | Reference |
|---|------|-------|-----------|
| 1 | `field_evolution_contraction` | Invariance | Pazy Thm 4.3 (Lumer–Phillips) |
| 2 | `thermal_evolution_bound` | Invariance | Evans §6.4 (max principle + ABP) |
| 3 | `gradient_evolution_bound` | Invariance | Lieberman Ch. 7 (Bernstein) |
| 4 | `diagonal_dissipation` | Stability | Gearhart–Prüss theorem |
| 5 | `cross_coupling_bound` | Stability | Henry §5.1 (Lipschitz coupling) |
| 6 | `unique_continuation` | Controllability | Carleman estimates (Zuazua 2007) |

### Generic utility axioms — Relay 18/23 status

| # | Name | Layer | Status |
|---|------|-------|--------|
| 7 | `lyapunov_deriv_decomposition` | Stability | **axiom** (structural; needs `lyapunovDeriv` refactor) |
| 8 | `gronwall_integration` | Stability | **axiom** (needs concrete evolution + ODE comparison) |
| 9 | `exp_decay_eventually_small` | Stability | **THEOREM** (Relay 18: `add_one_le_exp` + Archimedean) |
| 10| `forward_adjoint_duality` | Control | **THEOREM** (Relay 18: conclusion is `True`) |
| 11| `hum_density_of_reachable_set` | Control | **axiom** (active; Lions 1988 — deep PDE theory) |

### Removed axioms (Relay 23)
- `nagumo_invariance` — unused in all proofs; depended on opaque `evolutionMap`
- `unique_minimizer_of_coercive_strictly_convex` — unused; HUM uses density directly
- `euler_lagrange_optimal_control` — unused; HUM uses density directly

### Axiom count: **9** (6 system-specific + 3 utility)
### Theorem count: **2** utility axioms discharged (Relay 18)
### Sorry status: **0** in all theorem files

### Infrastructure sorry status (Relay 21)
| File | Before | After | Notes |
|------|--------|-------|-------|
| StateSpace.lean | 2 | **0** | Product norm instances discharged |
| LocalWellPosedness.lean | 1 | **1** | Existence discharged; uniqueness blocked |
| Operators.lean | 6 | 6 | Blocked: needs PDE semigroup bodies |
| Control.lean | 1 | 1 | Blocked: needs controlled PDE solution |
-/

import SIARCRelay11.Theorems.Controllability

namespace SIARCRelay11.Theorems

variable {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
variable [NormedAddCommGroup F.carrier] [NormedSpace ℝ F.carrier] [CompleteSpace F.carrier]
variable [NormedAddCommGroup T.carrier] [NormedSpace ℝ T.carrier] [CompleteSpace T.carrier]
variable [NormedAddCommGroup S.carrier] [NormedSpace ℝ S.carrier] [CompleteSpace S.carrier]

-- ============================================================
-- SECTION 1: System-Specific Axioms (6)
-- ============================================================

/-- **System-specific axioms.**

    The 6 physical assumptions about the coupled SIARC PDE-ODE system.
    Each requires a domain-specific proof: PDE regularity, spectral
    theory, or Carleman estimates. They cannot be discharged from
    Mathlib alone.

    **Invariance (3):** contraction/bound for each PDE component.
    **Stability (2):** spectral gap dissipation + coupling Lipschitz.
    **Controllability (1):** unique continuation for the adjoint. -/
structure SystemAxioms where
  /-- Axiom 1 (Invariance): Field evolution is contractive.
      `‖Φ_t(σ₀).field‖ ≤ ‖σ₀.field‖` — Lumer–Phillips (Pazy Thm 4.3). -/
  ax1_field_contraction :
    ∀ (σ₀ : StateSpace F T S) (t : ℝ) (ht : t ≥ 0),
      ‖(evolutionMap t ht F T S σ₀).field‖ ≤ ‖σ₀.field‖
  /-- Axiom 2 (Invariance): Thermal sup-norm is non-increasing.
      Maximum principle + ABP estimate (Evans §6.4). -/
  ax2_thermal_bound :
    ∀ (ct : CouplingThresholds) (hκ : |κ| < κ_safe ct)
      (σ₀ : StateSpace F T S) (t : ℝ) (ht : t ≥ 0)
      (h_field : ‖σ₀.field‖ ≤ ‖σ₀.field‖),
      thermalSup (evolutionMap t ht F T S σ₀).thermal ≤ thermalSup σ₀.thermal
  /-- Axiom 3 (Invariance): Thermal gradient is non-increasing.
      Bernstein gradient estimate (Lieberman Ch. 7). -/
  ax3_gradient_bound :
    ∀ (ct : CouplingThresholds) (hκ : |κ| < κ_safe ct)
      (σ₀ : StateSpace F T S) (t : ℝ) (ht : t ≥ 0)
      (h_field : ‖σ₀.field‖ ≤ ‖σ₀.field‖),
      thermalGradient (evolutionMap t ht F T S σ₀).thermal ≤ thermalGradient σ₀.thermal
  /-- Axiom 4 (Stability): Diagonal dissipation from spectral gap.
      `diag(dV/dt) ≤ −2λ·V` — Gearhart–Prüss theorem. -/
  ax4_dissipation :
    ∀ (p : BarrierParams) (bl : BarrierLyapunov p) (sg : SpectralGap)
      (σ : StateSpace F T S) (h_safe : InSafe p σ),
      diagContrib p bl sg σ ≤ -(2 * sg.gap) * bl.V σ
  /-- Axiom 5 (Stability): Cross-coupling bound.
      `cross(dV/dt) ≤ 2|κ|L·V` — Henry §5.1 (Lipschitz coupling). -/
  ax5_coupling :
    ∀ (p : BarrierParams) (bl : BarrierLyapunov p) (cl : CouplingLipschitz)
      (σ : StateSpace F T S) (h_safe : InSafe p σ),
      crossContrib p bl cl σ ≤ (2 * |κ| * cl.L_cross) * bl.V σ
  /-- Axiom 6 (Controllability): Unique continuation for the adjoint.
      `B*φ ≡ 0 on [0,T] ⟹ φ_T = 0` — Carleman estimates (Zuazua 2007). -/
  ax6_ucp :
    ∀ (adj : AdjointEvolution (F := F) (T := T) (S := S))
      (U : ControlSpace)
      (obs : ObservationOperator (F := F) (T := T) (S := S) U),
      UniqueContProp adj obs

/-- Instantiate `SystemAxioms` from the globally declared Lean `axiom`s.

    Each field is filled by the corresponding axiom from
    `Invariance.lean`, `Stability.lean`, or `Controllability.lean`. -/
def SystemAxioms.standard : SystemAxioms (F := F) (T := T) (S := S) where
  ax1_field_contraction := field_evolution_contraction
  ax2_thermal_bound := thermal_evolution_bound
  ax3_gradient_bound := gradient_evolution_bound
  ax4_dissipation := diagonal_dissipation
  ax5_coupling := cross_coupling_bound
  ax6_ucp := unique_continuation

-- ============================================================
-- SECTION 2: Utility Axioms — Classification
-- ============================================================

/-! ### Generic utility axioms (3 remaining axioms + 2 discharged theorems)

**Relay 18 update:** 2 of 8 utility axioms are now proved theorems.
**Relay 23 update:** 3 unused axioms removed (`nagumo_invariance`,
`unique_minimizer_of_coercive_strictly_convex`, `euler_lagrange_optimal_control`).
The remaining 3 are annotated with discharge candidates.

**Stability utilities (2 axioms + 1 theorem):**
- `lyapunov_deriv_decomposition` — **axiom** (structural identity;
  could become `rfl` if `lyapunovDeriv` were defined as sum).
- `gronwall_integration` — **axiom** (needs concrete evolution +
  `Mathlib.Analysis.ODE.Gronwall`).
- `exp_decay_eventually_small` — **THEOREM (Relay 18)**.
  Proved from `add_one_le_exp` + Archimedean property.

**Controllability utilities (1 axiom + 1 theorem):**
- `forward_adjoint_duality` — **THEOREM (Relay 18)**.
  Conclusion was `True`; proved by `trivial`.
- `hum_density_of_reachable_set` — **axiom** (actively used;
  Lions (1988) Thm 1.3 — deep PDE controllability theory).
-/

-- ============================================================
-- SECTION 3: Master Certificate
-- ============================================================

/-- **MasterCertificate** — the single object a downstream user needs.

    Bundles the 6 system-specific axioms (for transparency) together
    with the controllability certificate (which already nests safety
    and stability).

    ```
    MasterCertificate
    ├── axioms : SystemAxioms           (6 physical assumptions)
    └── certificate : ControllabilityCertificate
        ├── stability : StabilityCertificate
        │   └── safety : SafetyCertificate
        ├── adjoint : AdjointEvolution
        ├── control_op : ControlOperator
        ├── observation : ObservationOperator
        ├── gramian : ObservabilityGramian
        └── obs_ineq : ObservabilityInequality
    ``` -/
structure MasterCertificate where
  /-- The system-specific axioms (documentation / audit trail) -/
  axioms : SystemAxioms (F := F) (T := T) (S := S)
  /-- The controllability certificate (bundles safety + stability) -/
  certificate : ControllabilityCertificate (F := F) (T := T) (S := S)

/-- Extract the safety certificate from a `MasterCertificate`. -/
def MasterCertificate.safety
    (mc : MasterCertificate (F := F) (T := T) (S := S)) :
    SafetyCertificate (F := F) (T := T) (S := S) :=
  mc.certificate.safety

/-- Extract the stability certificate from a `MasterCertificate`. -/
def MasterCertificate.stability
    (mc : MasterCertificate (F := F) (T := T) (S := S)) :
    StabilityCertificate (F := F) (T := T) (S := S) :=
  mc.certificate.stability

-- ============================================================
-- SECTION 4: The One Theorem
-- ============================================================

/-- **The main theorem of the SIARC mechanization.**

    Given a `MasterCertificate` and an initial state σ₀ in the safe set,
    the coupled PDE-ODE system satisfies all four guarantees simultaneously:

    1. **Safety:** Trajectories remain in InSafe for all t ≥ 0.
    2. **Exponential decay:** V(Φ_t(σ₀)) ≤ V(σ₀)·e^{−2ωt}.
    3. **Convergence:** For any ε > 0, eventually V(Φ_t(σ₀)) < ε.
    4. **Controllability:** Approximate steering to any target state.

    **Axioms used:** 6 system-specific (see `SystemAxioms`) +
    3 generic utilities (see module docstring above).

    **Sorry count:** 0 in all theorem files. -/
theorem master_certificate_summary
    (mc : MasterCertificate (F := F) (T := T) (S := S))
    (σ₀ : StateSpace F T S)
    (h_safe : InSafe mc.certificate.stability.safety.params σ₀) :
    -- (1) Forward invariance
    (∀ t (ht : t ≥ 0),
      InSafe mc.certificate.stability.safety.params
        (evolutionMap t ht F T S σ₀)) ∧
    -- (2) Exponential decay
    (∀ t (ht : t ≥ 0),
      mc.certificate.stability.lyapunov.V (evolutionMap t ht F T S σ₀) ≤
        mc.certificate.stability.lyapunov.V σ₀ *
          Real.exp (-(2 * mc.certificate.stability.decay_rate) * t)) ∧
    -- (3) Asymptotic convergence
    (∀ ε > 0, ∃ T_conv : ℝ, T_conv > 0 ∧
      ∀ t (ht : t ≥ 0), t ≥ T_conv →
        mc.certificate.stability.lyapunov.V (evolutionMap t ht F T S σ₀) < ε) ∧
    -- (4) Approximate controllability
    ApproximatelyControllable mc.certificate.adjoint mc.certificate.U
      mc.certificate.control_op :=
  full_system_certificate mc.certificate σ₀ h_safe

-- ============================================================
-- SECTION 5: Dependency Graph
-- ============================================================

/-! ### Proof dependency graph

Legend: `[A]` = axiom, `[T]` = theorem (Relay 18), `[✗]` = removed (Relay 23)

```
[A] field_evolution_contraction ──┐
[A] thermal_evolution_bound ──────┤  Invariance layer
[A] gradient_evolution_bound ─────┘  (Relay 7: ForwardInvarianceFramework.lean)
        │
        ▼
  SafetyCertificate
        │
[A] diagonal_dissipation ─────────┐
[A] cross_coupling_bound ─────────┤  Stability layer
[A] lyapunov_deriv_decomposition ─┤  (Relay 8–11: Stability.lean)
[A] gronwall_integration ─────────┤
[T] exp_decay_eventually_small ───┘  ← Relay 18: proved
        │
        ▼
  StabilityCertificate
        │
[A] unique_continuation ──────────────┐
[T] forward_adjoint_duality ──────────┤  Controllability layer
[A] hum_density_of_reachable_set ─────┘  (Relay 12–13: Controllability.lean)
        │
        ▼
  ControllabilityCertificate
        │
        ▼
  MasterCertificate  ←  master_certificate_summary
```
-/

end SIARCRelay11.Theorems
