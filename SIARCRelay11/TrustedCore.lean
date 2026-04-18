/-!
# SIARCRelay11.TrustedCore — Minimal Public Interface

## Purpose

This file re-exports **only** the three objects a downstream user needs:

1. `SystemAxioms` — the 6 physical assumptions about the PDE system
2. `MasterCertificate` — bundles safety + stability + controllability
3. `master_certificate_summary` — the one theorem proving all 4 guarantees

## Usage

```lean
import SIARCRelay11.TrustedCore
```

This is the leanest possible import. It transitively pulls in the
entire verified chain but exposes only the top-level interface.

## Relay 23: No new axioms. No new sorry. Architecture only.
-/

import SIARCRelay11.Theorems.AxiomInventory

namespace SIARCRelay11.TrustedCore

variable {F : FieldSpace} {T : ThermalSpace} {S : StructuralSpace}
variable [NormedAddCommGroup F.carrier] [NormedSpace ℝ F.carrier] [CompleteSpace F.carrier]
variable [NormedAddCommGroup T.carrier] [NormedSpace ℝ T.carrier] [CompleteSpace T.carrier]
variable [NormedAddCommGroup S.carrier] [NormedSpace ℝ S.carrier] [CompleteSpace S.carrier]

-- ============================================================
-- The three objects that constitute the public face
-- ============================================================

/-- The 6 physical axioms about the coupled PDE-ODE system. -/
abbrev SystemAxioms := Theorems.SystemAxioms (F := F) (T := T) (S := S)

/-- The master certificate bundling all verified guarantees. -/
abbrev MasterCertificate := Theorems.MasterCertificate (F := F) (T := T) (S := S)

/-- The one theorem: given a certificate and σ₀ ∈ InSafe, all 4 guarantees hold. -/
theorem master_certificate_summary
    (mc : Theorems.MasterCertificate (F := F) (T := T) (S := S))
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
    Theorems.ApproximatelyControllable mc.certificate.adjoint mc.certificate.U
      mc.certificate.control_op :=
  Theorems.master_certificate_summary mc σ₀ h_safe

end SIARCRelay11.TrustedCore
