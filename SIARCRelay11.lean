-- SIARCRelay11.lean
-- Root module: imports all sub-modules in dependency order
-- SIARC coupled PDE-ODE system — fully mechanized certificate chain

-- Layer 0: Obstacles, axioms, and global parameters
import SIARCRelay11.Axioms
import SIARCRelay11.Parameters

-- Layer 1: State space hierarchy
import SIARCRelay11.StateSpace

-- Layer 2: Barrier functions (depends on StateSpace, Axioms, Parameters)
import SIARCRelay11.Barriers

-- Layer 3: Operator signatures and typeclasses (depends on StateSpace)
import SIARCRelay11.Operators

-- Layer 4: Fiber bundle structures (depends on StateSpace)
import SIARCRelay11.Bundles

-- Layer 5: Control law structures (depends on StateSpace, Axioms)
import SIARCRelay11.Control

-- Layer 6: Theorem proofs (depend on all above)
import SIARCRelay11.Theorems.LocalWellPosedness
import SIARCRelay11.Theorems.Invariance
import SIARCRelay11.Theorems.ForwardInvarianceFramework
import SIARCRelay11.Theorems.Stability
import SIARCRelay11.Theorems.Controllability
import SIARCRelay11.Theorems.AxiomInventory

-- Layer 7: Public API (re-exports minimal interface)
import SIARCRelay11.API

-- Layer 8: Trusted core boundary (Relay 22)
import SIARCRelay11.TrustedBoundary

-- Layer 9: Trusted core extraction (Relay 23)
import SIARCRelay11.TrustedCore

/-!
# SIARCRelay11

A complete, sorry-free Lean 4 formalization of safety, stability, and
controllability for a coupled PDE-ODE system (SIARC).

## Public API

**For external users:** import `SIARCRelay11.API` (not this file).
It exposes only the final objects you need:

- `SystemAxioms` — the 6 physical assumptions
- `MasterCertificate` — bundles safety + stability + controllability
- `master_certificate_summary` — the one theorem proving all 4 guarantees

## What it proves

Given a `MasterCertificate` and an initial state σ₀ in the safe set:

1. **Safety:** Trajectories remain in `InSafe` for all t ≥ 0.
2. **Exponential decay:** V(σ(t)) ≤ V(σ₀)·e^{−2ωt}.
3. **Convergence:** For any ε > 0, eventually V(σ(t)) < ε.
4. **Controllability:** Approximate steering to any target state.

## Axiom boundary

| Type | Count | Examples |
|------|-------|---------|
| System-specific | 6 | field contraction, thermal bound, UCP |
| Generic utility | 3 | Grönwall, Lyapunov decomposition, HUM density |

See `SIARCRelay11/Theorems/AxiomInventory.lean` for the full classification
and dependency graph.

## Sorry status: **0** in all theorem files

## Architecture (Relay 24)

The project is split into a **trusted core** (sorry-free theorem layer) and
**infrastructure layer** (0 sorry — uses opaque/axiom declarations for PDE-semigroup
placeholders). See `SIARCRelay11/TrustedBoundary.lean` for the formal separation,
soundness argument, and declaration inventory.

## File structure

```
SIARCRelay11/
┌────── TRUSTED CORE (0 sorry) ────────────────────┐
│ API.lean                            ← PUBLIC ENTRY POINT    │
│ TrustedBoundary.lean                ← trust boundary (R22)  │
│ TrustedCore.lean                    ← minimal public face   │
│ Axioms.lean                                                │
│ Parameters.lean                                            │
│ StateSpace.lean                     ← sorry-free (R21)      │
│ Barriers.lean                                              │
│ Bundles.lean                                               │
│ Theorems/                                                  │
│ ├── Invariance.lean                                         │
│ ├── ForwardInvarianceFramework.lean                         │
│ ├── Stability.lean                                         │
│ ├── Controllability.lean                                   │
│ ├── AxiomInventory.lean                                    │
│ └── LocalWellPosedness.lean    ← sorry-free (R22)           │
└──────────────────────────────────────────────────┘
┌────── INFRASTRUCTURE (0 sorry — opaque/axiom) ───┐
│ Operators.lean                      ← 4 opaque + 2 axiom    │
│ Control.lean                        ← 1 opaque              │
└──────────────────────────────────────────────────┘
Examples/
├── Example_Minimal.lean            ← how to use the API
├── Example_PhysicalSystem.lean     ← template (sorry by design)
├── Example_ThermoelasticSystem.lean← concrete PDE instantiation
├── Example_ThermoelasticParameters.lean ← numerical instance (R19A)
├── Example_ThermoelasticAutoVerify.lean  ← auto-verified (R20)
├── Example_LinearHeatEquation.lean ← cross-validation (R23)
└── Replay_MasterCertificate.lean   ← reviewer smoke test

Top-level:
├── lakefile.lean                       ← build config (v1.0.0)
├── lean-toolchain                      ← Lean v4.14.0
├── BUILD.md                            ← build instructions
├── REVIEW.md                           ← reviewer guide (R24)
├── ARTIFACT.md                         ← scope, axioms, replay recipe
└── OVERVIEW.md                         ← human-readable summary (R23)
```
-/
