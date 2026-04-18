/-!
# SIARCRelay11 Public API

This file exposes the minimal interface needed to use the SIARC
safety–stability–controllability stack.

## How to use

1. Provide a `SystemAxioms` instance for your physical system
   (or use `SystemAxioms.standard` which instantiates from the
   globally declared Lean axioms).
2. Build a `MasterCertificate` from those axioms plus a
   `ControllabilityCertificate`.
3. Apply `master_certificate_summary` to obtain all four guarantees:

   - forward invariance of the safe set,
   - local exponential stability (Lyapunov decay),
   - asymptotic stability (V → 0),
   - approximate controllability (HUM + UCP).

All internal details — barriers, Lyapunov derivative decomposition,
Grönwall integration, HUM functional, adjoint system — are
abstracted away behind the certificate structures.

## Axiom boundary

The system requires exactly **6 system-specific axioms** (physical
PDE properties) and **3 generic utility axioms** (standard functional
analysis). See `SystemAxioms` for the physical axioms and the
`AxiomInventory.lean` module docstring for the full classification.

## Sorry status

**0** in all theorem files (Invariance, Stability, Controllability,
AxiomInventory).

## Citation

> This artifact corresponds to the SIARCRelay11 formalization of safe-set
> invariance, stability, and controllability for coupled PDE-ODE systems.
>
> Entry point: `SIARCRelay11.API`
> Main theorem: `master_certificate_summary`
>
> **Axiom boundary:** 6 system-specific (physical PDE properties) +
> 3 generic utility (standard functional analysis) = 9 total.
> **Sorry count:** 0 in all theorem files.
>
> **Version:** v1.0.0 — Lean v4.14.0 — Mathlib4 v4.14.0
> See `ARTIFACT.md` for the full replay recipe and axiom inventory.
-/

import SIARCRelay11.Theorems.AxiomInventory

/-! ## Re-exports: Public API -/

namespace SIARCRelay11

-- ============================================================
-- Core types (from infrastructure)
-- ============================================================

-- StateSpace, FieldSpace, ThermalSpace, StructuralSpace
-- are already available via transitive import from SIARCRelay11.StateSpace.

-- BarrierParams, InSafe
-- are already available via transitive import from SIARCRelay11.Barriers.

-- evolutionMap
-- is already available via transitive import from SIARCRelay11.Operators.

-- κ, κ_safe, CouplingThresholds
-- are already available via transitive import from SIARCRelay11.Parameters.

-- ============================================================
-- Public API — Certificates
-- ============================================================

-- Re-export the five certificate structures and the axiom bundle
-- so users can write `SIARCRelay11.SystemAxioms` etc. without
-- opening `SIARCRelay11.Theorems`.

export Theorems (
  SystemAxioms
  MasterCertificate
  SafetyCertificate
  StabilityCertificate
  ControllabilityCertificate
)

-- ============================================================
-- Public API — Main theorems
-- ============================================================

export Theorems (
  -- The one theorem
  master_certificate_summary
  -- Invariance layer
  safe_manifold_invariance
  InSafe_invariance
  -- Stability layer
  locally_exponentially_stable
  asymptotically_stable
  full_stability_certificate
  -- Controllability layer
  approximate_controllability_of_UCP
  full_system_certificate
  -- Controllability predicates
  ApproximatelyControllable
  UniqueContProp
)

-- ============================================================
-- Public API — Constructors and extractors
-- ============================================================

export Theorems (
  -- SystemAxioms
  SystemAxioms.standard
  -- MasterCertificate
  MasterCertificate.safety
  MasterCertificate.stability
  -- SafetyCertificate
  SafetyCertificate.apply_InSafe
  -- StabilityCertificate
  StabilityCertificate.mk'
  StabilityCertificate.decay_rate
  StabilityCertificate.decay_rate_pos
  StabilityCertificate.apply_decay
  -- ControllabilityCertificate
  ControllabilityCertificate.mk'
  ControllabilityCertificate.safety
  ControllabilityCertificate.has_ucp
  ControllabilityCertificate.approx_controllable
)

-- ============================================================
-- Public API — Evolution maps
-- ============================================================

-- `evolutionMap` is in namespace SIARCRelay11 (from Operators.lean),
-- so it's already accessible as `SIARCRelay11.evolutionMap`.

-- The adjoint evolution and controlled evolution are structures/defs
-- in the Theorems namespace:
export Theorems (
  AdjointEvolution
  controlledEvolution
  ControlSpace
  ControlOperator
  ObservationOperator
)

end SIARCRelay11
