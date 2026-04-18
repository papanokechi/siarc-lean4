/-!
# SIARCRelay11.Theorems.ForwardInvarianceFramework — Abstract Invariance & Safety Certificate

## Relay 7: Invariance Abstraction & Export

This module lifts the fully discharged invariance proof (Relays 4–6) into a
**reusable, abstract framework** for downstream consumers: stability analysis,
controllability, and safety certification.

### Triangular DAG (proven in Invariance.lean)

```
g₁ (ROOT) ──→ g₄ (HUB) ──→ g₂ (LEAF)
                         ├──→ g₃' (LEAF, QS linkage)
                         └──→ g₅  (LEAF, QS linkage)
```

### Contraction-type axioms (3 total)

All three axioms have the uniform shape `‖output(Φ_t σ₀)‖ ≤ ‖output(σ₀)‖`:

1. `field_evolution_contraction` — Lumer–Phillips contraction (Pazy Thm 4.3)
2. `thermal_evolution_bound` — Max principle + ABP (Evans §6.4, Caffarelli–Cabré Ch. 3)
3. `gradient_evolution_bound` — Bernstein gradient (Lieberman Ch. 7, Krylov–Safonov)

### κ_safe

The global coupling threshold κ_safe = min(κ₂*, κ₃*, κ₄*, κ₅*) is defined
in Parameters.lean. The invariance proof requires |κ| < κ_safe plus a
`QuasiStaticLink` witness for the structural barriers (g₃', g₅).

### Safety Certificate

The `SafetyCertificate` structure bundles:
- the barrier parameters `p`,
- the coupling thresholds `ct`,
- the small-coupling hypothesis `|κ| < κ_safe`,
- the quasi-static linkage,
- the proven forward-invariance theorem.

Downstream relays import `SafetyCertificate` as a single opaque object.

## Dependencies
- SIARCRelay11.Theorems.Invariance (barrier invariance lemmas, assembly)
- SIARCRelay11.Barriers (AllBarriersSatisfied, InSafe, QuasiStaticLink)
- SIARCRelay11.Operators (evolutionMap)
- SIARCRelay11.Parameters (κ, κ_safe, CouplingThresholds)
-/

import SIARCRelay11.Theorems.Invariance
import SIARCRelay11.Barriers
import SIARCRelay11.Operators
import SIARCRelay11.Parameters

namespace SIARCRelay11.Theorems

variable {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
variable [NormedAddCommGroup F.carrier] [NormedSpace ℝ F.carrier] [CompleteSpace F.carrier]
variable [NormedAddCommGroup T.carrier] [NormedSpace ℝ T.carrier] [CompleteSpace T.carrier]
variable [NormedAddCommGroup S.carrier] [NormedSpace ℝ S.carrier] [CompleteSpace S.carrier]

-- ============================================================
-- SECTION 1: Abstract barrier invariance structures
-- ============================================================

/-- A barrier function on a state space: a real-valued function with
    a positivity convention (g σ ≥ 0 ↔ safe). -/
structure BarrierFn (X : Type*) where
  /-- The barrier function g : X → ℝ -/
  fn : X → ℝ

/-- A flow on a state space: maps (t, σ₀) → σ_t for t ≥ 0. -/
structure Flow (X : Type*) where
  /-- The flow map Φ : (t : ℝ) → (ht : t ≥ 0) → X → X -/
  map : (t : ℝ) → (ht : t ≥ 0) → X → X

/-- Forward invariance of a single barrier under a flow:
    g(σ₀) ≥ 0 → g(Φ_t(σ₀)) ≥ 0 for all t ≥ 0. -/
structure InvariantUnder (φ : Flow X) (g : BarrierFn X) where
  /-- The invariance property -/
  invariant : ∀ (σ₀ : X) (h₀ : g.fn σ₀ ≥ 0) (t : ℝ) (ht : t ≥ 0),
    g.fn (φ.map t ht σ₀) ≥ 0

/-- Forward invariance of a predicate (safe set) under a flow:
    P(σ₀) → P(Φ_t(σ₀)) for all t ≥ 0. -/
structure ForwardInvariant (φ : Flow X) (P : X → Prop) where
  /-- The invariance property -/
  invariant : ∀ (σ₀ : X) (h₀ : P σ₀) (t : ℝ) (ht : t ≥ 0),
    P (φ.map t ht σ₀)

-- ============================================================
-- SECTION 2: Triangular DAG structure
-- ============================================================

/-- A triangular invariance DAG with 5 barriers: root, hub, and 3 leaves.

    Structure:  root → hub → {leaf₁, leaf₂, leaf₃}

    The hub's invariance may depend on the root; the leaves' invariance
    may depend on the hub (and transitively on the root). -/
structure TriangularDAG (X : Type*) where
  /-- The root barrier (no upstream dependencies) -/
  root : BarrierFn X
  /-- The hub barrier (depends on root) -/
  hub : BarrierFn X
  /-- Leaf barrier 1 (depends on hub) -/
  leaf₁ : BarrierFn X
  /-- Leaf barrier 2 (depends on hub) -/
  leaf₂ : BarrierFn X
  /-- Leaf barrier 3 (depends on hub) -/
  leaf₃ : BarrierFn X

/-- The safe set defined by a triangular DAG: all 5 barriers ≥ 0. -/
def TriangularDAG.safeSet (dag : TriangularDAG X) (σ : X) : Prop :=
  dag.root.fn σ ≥ 0 ∧
  dag.hub.fn σ ≥ 0 ∧
  dag.leaf₁.fn σ ≥ 0 ∧
  dag.leaf₂.fn σ ≥ 0 ∧
  dag.leaf₃.fn σ ≥ 0

/-- Forward invariance of a triangular DAG safe set, given that each
    barrier is individually invariant (possibly with upstream dependencies).

    This is the abstract version of `safe_manifold_invariance`.
    It assembles 5 individual barrier invariance results into one.

    **Hypotheses** (reflecting the DAG structure):
    - `h_root`: root is invariant unconditionally (from initial g_root ≥ 0)
    - `h_hub`: hub is invariant given root ≥ 0 at initial time
    - `h_leaf₁`: leaf₁ is invariant given root ≥ 0 at initial time
    - `h_leaf₂`: leaf₂ is invariant given root + hub ≥ 0 at initial time
    - `h_leaf₃`: leaf₃ is invariant given root + hub ≥ 0 at initial time -/
theorem forwardInvariant_of_triangular
    {X : Type*} (dag : TriangularDAG X) (φ : Flow X)
    -- Root: unconditional (only needs its own initial condition)
    (h_root : ∀ σ₀ : X, dag.root.fn σ₀ ≥ 0 →
      ∀ t : ℝ, ∀ ht : t ≥ 0, dag.root.fn (φ.map t ht σ₀) ≥ 0)
    -- Hub: needs root bound
    (h_hub : ∀ σ₀ : X, dag.root.fn σ₀ ≥ 0 → dag.hub.fn σ₀ ≥ 0 →
      ∀ t : ℝ, ∀ ht : t ≥ 0, dag.hub.fn (φ.map t ht σ₀) ≥ 0)
    -- Leaf₁: needs root bound (g₂ depends on g₁ only)
    (h_leaf₁ : ∀ σ₀ : X, dag.root.fn σ₀ ≥ 0 → dag.leaf₁.fn σ₀ ≥ 0 →
      ∀ t : ℝ, ∀ ht : t ≥ 0, dag.leaf₁.fn (φ.map t ht σ₀) ≥ 0)
    -- Leaf₂: needs root + hub (g₃' depends on g₄)
    (h_leaf₂ : ∀ σ₀ : X, dag.root.fn σ₀ ≥ 0 → dag.hub.fn σ₀ ≥ 0 →
      dag.leaf₂.fn σ₀ ≥ 0 →
      ∀ t : ℝ, ∀ ht : t ≥ 0, dag.leaf₂.fn (φ.map t ht σ₀) ≥ 0)
    -- Leaf₃: needs root + hub (g₅ depends on g₄)
    (h_leaf₃ : ∀ σ₀ : X, dag.root.fn σ₀ ≥ 0 → dag.hub.fn σ₀ ≥ 0 →
      dag.leaf₃.fn σ₀ ≥ 0 →
      ∀ t : ℝ, ∀ ht : t ≥ 0, dag.leaf₃.fn (φ.map t ht σ₀) ≥ 0) :
    ForwardInvariant φ dag.safeSet :=
  ⟨fun σ₀ ⟨hr, hh, hl₁, hl₂, hl₃⟩ t ht =>
    ⟨h_root σ₀ hr t ht,
     h_hub σ₀ hr hh t ht,
     h_leaf₁ σ₀ hr hl₁ t ht,
     h_leaf₂ σ₀ hr hh hl₂ t ht,
     h_leaf₃ σ₀ hr hh hl₃ t ht⟩⟩

-- ============================================================
-- SECTION 3: SIARC instantiation — wiring the DAG
-- ============================================================

/-- The SIARC triangular DAG: g₁ (root) → g₄ (hub) → {g₂, g₃', g₅}. -/
def siarc_dag (p : BarrierParams) : TriangularDAG (StateSpace F T S) :=
  { root  := ⟨g₁ p⟩    -- field strength
    hub   := ⟨g₄ p⟩    -- quench temperature
    leaf₁ := ⟨g₂ p⟩    -- thermal gradient
    leaf₂ := ⟨g₃' p⟩   -- curvature (QS linkage)
    leaf₃ := ⟨g₅ p⟩ }  -- von Mises stress (QS linkage)

/-- The SIARC evolution map wrapped as a Flow. -/
def siarc_flow : Flow (StateSpace F T S) :=
  ⟨fun t ht σ₀ => evolutionMap t ht F T S σ₀⟩

/-- The SIARC safe set via the triangular DAG equals AllBarriersSatisfied.
    This connects the abstract framework to the concrete barrier predicates. -/
theorem siarc_dag_safeSet_eq (p : BarrierParams) (σ : StateSpace F T S) :
    (siarc_dag p).safeSet σ ↔ AllBarriersSatisfied p σ := by
  simp only [TriangularDAG.safeSet, siarc_dag, BarrierFn.fn, AllBarriersSatisfied]
  -- Both are: g₁ ≥ 0 ∧ g₄ ≥ 0 ∧ g₂ ≥ 0 ∧ g₃' ≥ 0 ∧ g₅ ≥ 0
  -- but AllBarriersSatisfied has order: g₁, g₂, g₃', g₄, g₅
  -- and DAG has order: root(g₁), hub(g₄), leaf₁(g₂), leaf₂(g₃'), leaf₃(g₅)
  constructor
  · intro ⟨h1, h4, h2, h3, h5⟩; exact ⟨h1, h2, h3, h4, h5⟩
  · intro ⟨h1, h2, h3, h4, h5⟩; exact ⟨h1, h4, h2, h3, h5⟩

/-- **Abstract forward invariance of the SIARC safe set.**

    This applies `forwardInvariant_of_triangular` to the SIARC DAG,
    wiring the 5 individual barrier invariance lemmas from Invariance.lean
    into the abstract framework. -/
def siarc_forwardInvariant
    (p : BarrierParams) (ct : CouplingThresholds)
    (hκ : |κ| < κ_safe ct) (link : QuasiStaticLink p) :
    ForwardInvariant (siarc_flow (F := F) (T := T) (S := S))
      (siarc_dag p).safeSet :=
  forwardInvariant_of_triangular (siarc_dag p) siarc_flow
    -- root = g₁: unconditional
    (fun σ₀ h1 t ht => invariant_g1 p σ₀ h1 t ht)
    -- hub = g₄: needs g₁
    (fun σ₀ h1 h4 t ht => invariant_g4 p ct hκ σ₀ h1 h4 t ht)
    -- leaf₁ = g₂: needs g₁
    (fun σ₀ h1 h2 t ht => invariant_g2 p ct hκ σ₀ h1 h2 t ht)
    -- leaf₂ = g₃': needs g₁ + g₄
    (fun σ₀ h1 h4 h3 t ht => invariant_g3' p ct hκ link σ₀ h1 h3 h4 t ht)
    -- leaf₃ = g₅: needs g₁ + g₄
    (fun σ₀ h1 h4 h5 t ht => invariant_g5 p ct hκ link σ₀ h1 h4 h5 t ht)

-- ============================================================
-- SECTION 4: Safety Certificate
-- ============================================================

/-- **Safety Certificate** — a single exportable object that bundles:

    1. The barrier parameters (thresholds for each physical quantity)
    2. The coupling thresholds (per-barrier maximum coupling strengths)
    3. The small-coupling proof (|κ| < κ_safe)
    4. The quasi-static linkage (structural ↔ thermal via elliptic regularity)
    5. The proven forward-invariance of the safe set

    Downstream relays (stability, controllability, certification) import
    this structure instead of re-proving invariance from scratch. -/
structure SafetyCertificate where
  /-- Physical barrier parameters (B_max, T_quench, ∇T_max, C_curv, σ_yield) -/
  params : BarrierParams
  /-- Per-barrier coupling thresholds (κ₂*, κ₃*, κ₄*, κ₅*) -/
  thresholds : CouplingThresholds
  /-- Proof that physical coupling is below the safe threshold -/
  coupling_small : |κ| < κ_safe thresholds
  /-- Quasi-static structural linkage (g₄ controls g₃' and g₅) -/
  qs_link : QuasiStaticLink params
  /-- The proven forward-invariance theorem -/
  invariance : ForwardInvariant (siarc_flow (F := F) (T := T) (S := S))
    (siarc_dag params).safeSet

/-- Construct a safety certificate from physical parameters and proofs.

    This is the canonical way to build a `SafetyCertificate`. It takes
    the barrier parameters, coupling thresholds, and the two hypotheses
    (small coupling + QS linkage), then *derives* the invariance theorem
    automatically from `siarc_forwardInvariant`. -/
def SafetyCertificate.mk'
    (p : BarrierParams) (ct : CouplingThresholds)
    (hκ : |κ| < κ_safe ct)
    (link : QuasiStaticLink p) :
    SafetyCertificate (F := F) (T := T) (S := S) :=
  { params := p
    thresholds := ct
    coupling_small := hκ
    qs_link := link
    invariance := siarc_forwardInvariant p ct hκ link }

/-- Extract the concrete `AllBarriersSatisfied` invariance from a certificate.

    Given a `SafetyCertificate` and a state σ₀ in the safe set, produces
    `AllBarriersSatisfied` at the evolved state for all t ≥ 0. This is the
    primary API for downstream relays. -/
theorem SafetyCertificate.apply
    (cert : SafetyCertificate (F := F) (T := T) (S := S))
    (σ₀ : StateSpace F T S) (h₀ : AllBarriersSatisfied cert.params σ₀)
    (t : ℝ) (ht : t ≥ 0) :
    AllBarriersSatisfied cert.params (evolutionMap t ht F T S σ₀) := by
  have h_dag := (siarc_dag_safeSet_eq cert.params σ₀).mpr h₀
  have h_inv := cert.invariance.invariant σ₀ h_dag t ht
  exact (siarc_dag_safeSet_eq cert.params _).mp h_inv

/-- Extract `InSafe` invariance from a certificate.

    The `InSafe` predicate uses norm-based formulation (‖field‖ ≤ B_max etc.)
    rather than barrier-function formulation (g₁ ≥ 0 etc.). -/
theorem SafetyCertificate.apply_InSafe
    (cert : SafetyCertificate (F := F) (T := T) (S := S))
    (σ₀ : StateSpace F T S) (h₀ : InSafe cert.params σ₀)
    (t : ℝ) (ht : t ≥ 0) :
    InSafe cert.params (evolutionMap t ht F T S σ₀) := by
  rw [InSafe_iff] at h₀ ⊢
  exact cert.apply σ₀ h₀ t ht

-- ============================================================
-- SECTION 5: Composition lemma for time iteration
-- ============================================================

/-- Forward invariance composes: if the safe set is invariant for one step,
    it is invariant for arbitrarily many steps (semigroup property).
    This is immediate from the pointwise-in-time statement, but is useful
    as an explicit API for numerical integration relays. -/
theorem SafetyCertificate.iterate
    (cert : SafetyCertificate (F := F) (T := T) (S := S))
    (σ₀ : StateSpace F T S) (h₀ : InSafe cert.params σ₀)
    (t₁ t₂ : ℝ) (ht₁ : t₁ ≥ 0) (ht₂ : t₂ ≥ 0)
    (ht_sum : t₁ + t₂ ≥ 0 := by linarith) :
    InSafe cert.params (evolutionMap (t₁ + t₂) ht_sum F T S σ₀) :=
  -- Direct application: the certificate gives invariance for any t ≥ 0
  cert.apply_InSafe σ₀ h₀ (t₁ + t₂) ht_sum

end SIARCRelay11.Theorems
