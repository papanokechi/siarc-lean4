/-!
# Replay: Master Certificate Smoke Test

This file is the **reviewer smoke test** for the SIARCRelay11 artifact.

After `lake build`, open this file in VS Code with the Lean 4 extension.
Every `#check` and `#print` command should resolve without errors.
No `sorry` should appear in the output.

## What this file demonstrates

1. The public API imports cleanly via `SIARCRelay11.API`.
2. `SystemAxioms.standard` instantiates the 6 system-specific axioms.
3. `MasterCertificate` and `master_certificate_summary` are accessible.
4. The master theorem's type signature encodes all 4 guarantees.
5. Key sub-certificates are extractable from the master certificate.
-/

import SIARCRelay11.API

open SIARCRelay11

namespace SIARCRelay11.Examples.Replay

/-! ## 1. Check that core types are accessible -/

#check @SystemAxioms
#check @MasterCertificate
#check @SafetyCertificate
#check @StabilityCertificate
#check @ControllabilityCertificate

/-! ## 2. Check the master theorem -/

#check @master_certificate_summary

/-! ## 3. Check certificate extractors -/

#check @MasterCertificate.safety
#check @MasterCertificate.stability

/-! ## 4. Check controllability machinery -/

#check @ApproximatelyControllable
#check @UniqueContProp
#check @AdjointEvolution
#check @controlledEvolution
#check @approximate_controllability_of_UCP

/-! ## 5. Check stability layer -/

#check @locally_exponentially_stable
#check @asymptotically_stable
#check @full_stability_certificate

/-! ## 6. Check invariance layer -/

#check @safe_manifold_invariance
#check @InSafe_invariance

/-! ## 7. Check the standard axiom bundle -/

#check @SystemAxioms.standard

/-! ## 8. Print the master theorem's full type

This is the key output a reviewer should inspect.
It shows exactly what is assumed and what is proved. -/

#print master_certificate_summary

/-! ## 9. Print the SystemAxioms structure

Shows exactly the 6 physical axioms that must be provided. -/

#print SystemAxioms

/-! ## 10. Functional test: construct axioms + extract a guarantee

This example constructs `SystemAxioms.standard` and uses the
master theorem to extract the safety guarantee. -/

variable {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
variable [NormedAddCommGroup F.carrier] [NormedSpace ℝ F.carrier] [CompleteSpace F.carrier]
variable [NormedAddCommGroup T.carrier] [NormedSpace ℝ T.carrier] [CompleteSpace T.carrier]
variable [NormedAddCommGroup S.carrier] [NormedSpace ℝ S.carrier] [CompleteSpace S.carrier]

-- The standard axioms are constructible
noncomputable example : SystemAxioms (F := F) (T := T) (S := S) :=
  SystemAxioms.standard

-- Given a master certificate, safety is extractable
example (mc : MasterCertificate (F := F) (T := T) (S := S))
    (σ₀ : StateSpace F T S)
    (h_safe : InSafe mc.certificate.stability.safety.params σ₀)
    (t : ℝ) (ht : t ≥ 0) :
    InSafe mc.certificate.stability.safety.params
      (evolutionMap t ht F T S σ₀) :=
  (master_certificate_summary mc σ₀ h_safe).1 t ht

-- Given a master certificate, controllability is extractable
example (mc : MasterCertificate (F := F) (T := T) (S := S))
    (σ₀ : StateSpace F T S)
    (h_safe : InSafe mc.certificate.stability.safety.params σ₀) :
    ApproximatelyControllable mc.certificate.adjoint mc.certificate.U
      mc.certificate.control_op :=
  (master_certificate_summary mc σ₀ h_safe).2.2.2

end SIARCRelay11.Examples.Replay
