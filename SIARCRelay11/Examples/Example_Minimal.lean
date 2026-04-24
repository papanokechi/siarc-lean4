import SIARCRelay11.API

/-!
# Example: Minimal instantiation of `SystemAxioms`

This file demonstrates how to use the SIARC public API by
instantiating `SystemAxioms` with the globally declared axioms
and extracting results from a `MasterCertificate`.

This is a *template* — for a real physical system, replace
`SystemAxioms.standard` with axioms proved for your PDE system.
-/


open SIARCRelay11

namespace SIARCRelay11.Examples

variable {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
variable [NormedAddCommGroup F.carrier] [NormedSpace ℝ F.carrier] [CompleteSpace F.carrier]
variable [NormedAddCommGroup T.carrier] [NormedSpace ℝ T.carrier] [CompleteSpace T.carrier]
variable [NormedAddCommGroup S.carrier] [NormedSpace ℝ S.carrier] [CompleteSpace S.carrier]

/-! ## Step 1: Obtain system axioms

For the SIARC system, these are available as `SystemAxioms.standard`.
For a custom system, you would construct a `SystemAxioms` by providing
proofs of the 6 physical properties. -/

noncomputable example : SystemAxioms (F := F) (T := T) (S := S) :=
  SystemAxioms.standard

/-! ## Step 2: Given a `MasterCertificate`, extract guarantees

Suppose someone hands you a `MasterCertificate`. Here is how you
use it to get each individual guarantee. -/

-- Extract safety: trajectories stay in the safe set
example (mc : MasterCertificate (F := F) (T := T) (S := S))
    (σ₀ : StateSpace F T S)
    (h_safe : InSafe mc.certificate.stability.safety.params σ₀)
    (t : ℝ) (ht : t ≥ 0) :
    InSafe mc.certificate.stability.safety.params
      (evolutionMap t ht F T S σ₀) :=
  (master_certificate_summary mc σ₀ h_safe).1 t ht

-- Extract exponential decay: V decreases exponentially
example (mc : MasterCertificate (F := F) (T := T) (S := S))
    (σ₀ : StateSpace F T S)
    (h_safe : InSafe mc.certificate.stability.safety.params σ₀)
    (t : ℝ) (ht : t ≥ 0) :
    mc.certificate.stability.lyapunov.V (evolutionMap t ht F T S σ₀) ≤
      mc.certificate.stability.lyapunov.V σ₀ *
        Real.exp (-(2 * mc.certificate.stability.decay_rate) * t) :=
  (master_certificate_summary mc σ₀ h_safe).2.1 t ht

-- Extract convergence: V eventually drops below any ε
example (mc : MasterCertificate (F := F) (T := T) (S := S))
    (σ₀ : StateSpace F T S)
    (h_safe : InSafe mc.certificate.stability.safety.params σ₀)
    (ε : ℝ) (hε : ε > 0) :
    ∃ T_conv : ℝ, T_conv > 0 ∧
      ∀ t (ht : t ≥ 0), t ≥ T_conv →
        mc.certificate.stability.lyapunov.V (evolutionMap t ht F T S σ₀) < ε :=
  (master_certificate_summary mc σ₀ h_safe).2.2.1 ε hε

-- Extract controllability: approximate steering to any target
example (mc : MasterCertificate (F := F) (T := T) (S := S))
    (σ₀ : StateSpace F T S)
    (h_safe : InSafe mc.certificate.stability.safety.params σ₀) :
    ApproximatelyControllable mc.certificate.adjoint mc.certificate.U
      mc.certificate.control_op :=
  (master_certificate_summary mc σ₀ h_safe).2.2.2

end SIARCRelay11.Examples
