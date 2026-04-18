/-!
# Relay V2 — Relay 15: Library Extraction & Public API Finalization

## Role
Transform SIARCRelay11 from a research notebook into a clean, importable
Lean library with a minimal public interface, clear axiom boundary, and
a single master theorem summarizing the entire system.

## Result: COMPLETE

### Files created

| File | Purpose |
|------|---------|
| `SIARCRelay11/API.lean` | Public entry point — re-exports minimal interface |
| `SIARCRelay11/Examples/Example_Minimal.lean` | How to use the API (4 worked examples) |
| `SIARCRelay11/Examples/Example_PhysicalSystem.lean` | Template for custom PDE systems |

### Files updated

| File | Change |
|------|--------|
| `SIARCRelay11.lean` | New docstring, imports API.lean, updated file tree |

### Public API surface (from `API.lean`)

**Certificates (5 structures):**
`SystemAxioms`, `MasterCertificate`, `SafetyCertificate`,
`StabilityCertificate`, `ControllabilityCertificate`

**Main theorems (8):**
`master_certificate_summary`, `safe_manifold_invariance`,
`InSafe_invariance`, `locally_exponentially_stable`,
`asymptotically_stable`, `full_stability_certificate`,
`approximate_controllability_of_UCP`, `full_system_certificate`

**Constructors/extractors (10):**
`SystemAxioms.standard`, `MasterCertificate.safety`, `.stability`,
`SafetyCertificate.apply_InSafe`, `StabilityCertificate.mk'`,
`.decay_rate`, `.decay_rate_pos`, `.apply_decay`,
`ControllabilityCertificate.mk'`, `.safety`, `.has_ucp`, `.approx_controllable`

**Evolution maps (5):**
`evolutionMap`, `AdjointEvolution`, `controlledEvolution`,
`ControlSpace`, `ControlOperator`, `ObservationOperator`

**Predicates (2):**
`ApproximatelyControllable`, `UniqueContProp`

### Namespacing

| Scope | Namespace | Content |
|-------|-----------|---------|
| Public | `SIARCRelay11` | Re-exported API via `export Theorems (...)` |
| Internal | `SIARCRelay11.Theorems` | All theorem implementations |
| Infrastructure | `SIARCRelay11` | StateSpace, Operators, Barriers, etc. |

Users import `SIARCRelay11.API` and use names like
`SIARCRelay11.MasterCertificate`, `SIARCRelay11.master_certificate_summary`.
Internal names like `gramian_pos_def_of_ucp` or `lyapunov_deriv_combined_bound`
are not re-exported.

### Example usage (from `Example_Minimal.lean`)

```lean
import SIARCRelay11.API
open SIARCRelay11

-- Get all 4 guarantees from one theorem call:
example (mc : MasterCertificate) (σ₀ : StateSpace F T S)
    (h_safe : InSafe mc.certificate.stability.safety.params σ₀) :
    -- safety ∧ decay ∧ convergence ∧ controllability
    ... :=
  master_certificate_summary mc σ₀ h_safe
```

### Relay 16 options

**Option A: Zenodo/artifact packaging.** Create a `lakefile.lean`,
`lean-toolchain`, `README.md`, and package for Zenodo DOI.

**Option B: Mathlib discharge.** Prove the 8 utility axioms from
Mathlib APIs to reduce the axiom count.

**Option C: Concrete instantiation.** Supply a specific 2D thermal-
structural system and verify the 6 system-specific axioms.
-/
