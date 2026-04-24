import Mathlib.Geometry.Manifold.SmoothManifoldWithCorners
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Topology.FiberBundle.Basic
import Mathlib.Analysis.Normed.Module.Basic

/-!
# SIARCRelay11.StateSpace — Type Definitions for the Full State Space Hierarchy

## Purpose
Defines the mathematical types: base manifold M, fiber spaces (Field, Thermal,
Structural), control and intent spaces, the product StateSpace, and the
SafeManifold invariant subset.

## Dependencies
- Mathlib smooth manifolds, inner product spaces, fiber bundles, normed spaces

## Known Blockers
- Full Lorentzian metric requires pseudo-Riemannian Mathlib extension (not yet available)
- Sobolev space structure on ThermalSpace requires Mathlib Sobolev API

## Status (Relay 21)
- NormedAddCommGroup on StateSpace: **discharged** (via `Function.Injective.normedAddCommGroup`)
- NormedSpace ℝ on StateSpace: **discharged** (via `norm_smul_le` transfer)
- 0 sorry remaining in this file
-/


namespace SIARCRelay11

-- ============================================================
-- Base Lorentzian-type manifold M
-- ============================================================

/-- M: the base manifold (smooth, finite-dimensional, compact with boundary).
    In the physical interpretation this is a 4-dimensional Lorentzian spacetime
    region. We use Riemannian proxy since Mathlib4 lacks pseudo-Riemannian. -/
structure LorentzBase (n : ℕ) where
  carrier        : Type*
  smooth_mfld    : SmoothManifoldWithCorners (𝓡 n) carrier
  compact        : CompactSpace carrier
  pseudo_metric  : carrier → carrier → ℝ

-- ============================================================
-- Component spaces (fibers over M)
-- ============================================================

/-- FieldSpace: L² sections of an electromagnetic-type field bundle over M.
    Abstracted as a Banach space with inner product structure. -/
structure FieldSpace where
  carrier       : Type*
  normed        : NormedAddCommGroup carrier
  module        : NormedSpace ℝ carrier
  inner_product : InnerProductSpace ℝ carrier

/-- ThermalSpace: temperature distribution space, W^{1,2}(M) Sobolev proxy. -/
structure ThermalSpace where
  carrier   : Type*
  normed    : NormedAddCommGroup carrier
  module    : NormedSpace ℝ carrier

/-- StructuralSpace: displacement field space for mechanical/elastic deformation. -/
structure StructuralSpace where
  carrier   : Type*
  normed    : NormedAddCommGroup carrier
  module    : NormedSpace ℝ carrier

/-- ControlSpace: finite-dimensional input space U ≅ ℝᵐ. -/
structure ControlSpace (m : ℕ) where
  carrier   : Fin m → ℝ

/-- IntentSpace: abstract high-level goal/intent parameter space.
    Compact metric space (could be a simplex of mission modes). -/
structure IntentSpace where
  carrier   : Type*
  metric    : MetricSpace carrier
  compact   : CompactSpace carrier

-- ============================================================
-- Full StateSpace: product bundle over M
-- ============================================================

/-- StateSpace: the full coupled state Σ = FieldSpace × ThermalSpace × StructuralSpace. -/
structure StateSpace
    (F : FieldSpace)
    (T : ThermalSpace)
    (S : StructuralSpace) where
  field      : F.carrier
  thermal    : T.carrier
  structural : S.carrier

-- ============================================================
-- Product norm structure on StateSpace (Relay 21 — sorry discharge)
-- ============================================================
-- Strategy: StateSpace ≅ F.carrier × (T.carrier × S.carrier) as an
-- additive group. Mathlib provides NormedAddCommGroup and NormedSpace
-- on product types. We transfer via the injective embedding
-- `StateSpace.toProd` using `Function.Injective.normedAddCommGroup`.

/-- The canonical embedding of StateSpace into the product type. -/
def StateSpace.toProd {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    (σ : StateSpace F T S) : F.carrier × (T.carrier × S.carrier) :=
  (σ.field, σ.thermal, σ.structural)

/-- Inverse: product type back to StateSpace. -/
def StateSpace.ofProd {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    (p : F.carrier × (T.carrier × S.carrier)) : StateSpace F T S :=
  ⟨p.1, p.2.1, p.2.2⟩

/-- The embedding is injective. -/
theorem StateSpace.toProd_injective
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace} :
    Function.Injective (StateSpace.toProd (F := F) (T := T) (S := S)) := by
  intro a b h
  simp only [toProd, Prod.mk.injEq] at h
  exact StateSpace.ext _ _ h.1 h.2.1 h.2.2

/-- The embedding is an equivalence. -/
def StateSpace.equivProd (F : FieldSpace) (T : ThermalSpace) (S : StructuralSpace) :
    StateSpace F T S ≃ F.carrier × (T.carrier × S.carrier) where
  toFun := toProd
  invFun := ofProd
  left_inv := fun σ => by simp [toProd, ofProd]
  right_inv := fun p => by simp [toProd, ofProd]

/-- Zero element for StateSpace. -/
instance stateSpace_zero
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [Zero F.carrier] [Zero T.carrier] [Zero S.carrier] :
    Zero (StateSpace F T S) :=
  ⟨⟨0, 0, 0⟩⟩

/-- Additive structure on StateSpace, component-wise. -/
instance stateSpace_add
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [Add F.carrier] [Add T.carrier] [Add S.carrier] :
    Add (StateSpace F T S) :=
  ⟨fun a b => ⟨a.field + b.field, a.thermal + b.thermal, a.structural + b.structural⟩⟩

/-- Negation on StateSpace, component-wise. -/
instance stateSpace_neg
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [Neg F.carrier] [Neg T.carrier] [Neg S.carrier] :
    Neg (StateSpace F T S) :=
  ⟨fun a => ⟨-a.field, -a.thermal, -a.structural⟩⟩

/-- Subtraction on StateSpace, component-wise. -/
instance stateSpace_sub
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [Sub F.carrier] [Sub T.carrier] [Sub S.carrier] :
    Sub (StateSpace F T S) :=
  ⟨fun a b => ⟨a.field - b.field, a.thermal - b.thermal, a.structural - b.structural⟩⟩

/-- Scalar multiplication on StateSpace, component-wise. -/
instance stateSpace_smul
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [SMul ℝ F.carrier] [SMul ℝ T.carrier] [SMul ℝ S.carrier] :
    SMul ℝ (StateSpace F T S) :=
  ⟨fun r a => ⟨r • a.field, r • a.thermal, r • a.structural⟩⟩

/-- `toProd` is an additive group homomorphism. -/
theorem StateSpace.toProd_zero
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [NormedAddCommGroup F.carrier]
    [NormedAddCommGroup T.carrier]
    [NormedAddCommGroup S.carrier] :
    (0 : StateSpace F T S).toProd = 0 := by
  simp [toProd, Prod.zero_def]

theorem StateSpace.toProd_add
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [NormedAddCommGroup F.carrier]
    [NormedAddCommGroup T.carrier]
    [NormedAddCommGroup S.carrier]
    (a b : StateSpace F T S) :
    (a + b).toProd = a.toProd + b.toProd := by
  simp [toProd, HAdd.hAdd, Add.add, stateSpace_add, Prod.add_def]

theorem StateSpace.toProd_neg
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [NormedAddCommGroup F.carrier]
    [NormedAddCommGroup T.carrier]
    [NormedAddCommGroup S.carrier]
    (a : StateSpace F T S) :
    (-a).toProd = -a.toProd := by
  simp [toProd, HNeg.hNeg, Neg.neg, stateSpace_neg, Prod.neg_def]

theorem StateSpace.toProd_sub
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [NormedAddCommGroup F.carrier]
    [NormedAddCommGroup T.carrier]
    [NormedAddCommGroup S.carrier]
    (a b : StateSpace F T S) :
    (a - b).toProd = a.toProd - b.toProd := by
  simp [toProd, HSub.hSub, Sub.sub, stateSpace_sub, Prod.sub_def]

theorem StateSpace.toProd_smul
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [NormedAddCommGroup F.carrier] [NormedSpace ℝ F.carrier]
    [NormedAddCommGroup T.carrier] [NormedSpace ℝ T.carrier]
    [NormedAddCommGroup S.carrier] [NormedSpace ℝ S.carrier]
    (r : ℝ) (a : StateSpace F T S) :
    (r • a).toProd = r • a.toProd := by
  simp [toProd, HSMul.hSMul, SMul.smul, stateSpace_smul, Prod.smul_def]

/-- **NormedAddCommGroup on StateSpace** (Relay 21: sorry → theorem).

    Transferred from the Mathlib `NormedAddCommGroup` instance on
    `F.carrier × (T.carrier × S.carrier)` via the injective embedding
    `StateSpace.toProd`.

    The norm is: ‖σ‖ = max(‖σ.field‖, max(‖σ.thermal‖, ‖σ.structural‖))
    (inherited from the Mathlib product norm). -/
noncomputable instance stateSpace_normedAddCommGroup
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [NormedAddCommGroup F.carrier]
    [NormedAddCommGroup T.carrier]
    [NormedAddCommGroup S.carrier] :
    NormedAddCommGroup (StateSpace F T S) :=
  Function.Injective.normedAddCommGroup
    StateSpace.toProd
    StateSpace.toProd_injective
    StateSpace.toProd_zero
    StateSpace.toProd_add
    StateSpace.toProd_neg
    StateSpace.toProd_sub
    (fun n a => by
      simp [toProd, Prod.smul_def]
      rfl)
    (fun n a => by
      simp [toProd, Prod.smul_def]
      rfl)

/-- **NormedSpace ℝ on StateSpace** (Relay 21: sorry → theorem).

    Transferred from the Mathlib `NormedSpace ℝ` instance on
    `F.carrier × (T.carrier × S.carrier)` via the injective embedding. -/
noncomputable instance stateSpace_normedSpace
    {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
    [NormedAddCommGroup F.carrier] [NormedSpace ℝ F.carrier]
    [NormedAddCommGroup T.carrier] [NormedSpace ℝ T.carrier]
    [NormedAddCommGroup S.carrier] [NormedSpace ℝ S.carrier] :
    NormedSpace ℝ (StateSpace F T S) where
  norm_smul_le r σ := by
    show ‖(r • σ).toProd‖ ≤ ‖r‖ * ‖σ.toProd‖
    rw [toProd_smul]
    exact norm_smul_le r σ.toProd

-- ============================================================
-- SafeManifold: invariant subset of StateSpace
-- ============================================================

/-- SafeManifold: the admissible region defined by barrier constraints.
    Σ_safe = { σ ∈ Σ | g₁(σ) ≥ 0 ∧ g₂(σ) ≥ 0 ∧ g₄(σ) ≥ 0 ∧ g₅(σ) ≥ 0 }
    g₃ (holonomy) excluded: non-local, see Axioms.lean. -/
structure SafeManifold
    (F : FieldSpace)
    (T : ThermalSpace)
    (S : StructuralSpace)
    (g₁ g₂ g₄ g₅ : StateSpace F T S → ℝ) where
  point      : StateSpace F T S
  barrier_g1 : g₁ point ≥ 0
  barrier_g2 : g₂ point ≥ 0
  barrier_g4 : g₄ point ≥ 0
  barrier_g5 : g₅ point ≥ 0

end SIARCRelay11
