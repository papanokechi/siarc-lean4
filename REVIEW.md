# How to Review This Artifact

This guide helps reviewers verify the SIARC formalization efficiently.
Total review time: ~10 minutes (after build completes).

## Step 1: Build (one command)

```bash
lake exe cache get && lake build
```

This fetches the Mathlib cache and builds the entire project.
A successful build produces **zero errors**.

For the minimal trusted-core-only build:

```bash
lake build SIARCRelay11TrustedCore
```

## Step 2: Verify the trusted core

Open these three files in VS Code with the Lean 4 extension:

| File | What to check |
|------|---------------|
| `SIARCRelay11/TrustedCore.lean` | The `master_certificate_summary` theorem type-checks with no sorry. This is the single theorem that extracts all 4 guarantees. |
| `SIARCRelay11/API.lean` | The public interface re-exports `SystemAxioms`, `MasterCertificate`, and the main theorem. No sorry. |
| `SIARCRelay11/Theorems/AxiomInventory.lean` | The full axiom classification (9 axioms: 6 system-specific + 3 utility), `MasterCertificate` structure, and `master_certificate_summary` proof. No sorry. |

All three files should show **green checkmarks** (no errors, no sorry).

## Step 3: Inspect the trust boundary

Open `SIARCRelay11/TrustedBoundary.lean`. It contains:

- `trusted_core_soundness` — theorem re-proving all 4 guarantees (sorry-free)
- `InfrastructureSorryInventory` — compile-time record of all 8 infrastructure sorry's
- `trustedFiles` / `untrustedFiles` — programmatic file lists
- A soundness argument (Section 4) explaining why sorry's are safe

Verify that the 3 untrusted files (`Operators.lean`, `Control.lean`,
`Theorems/LocalWellPosedness.lean`) have `⚠ OUTSIDE TRUSTED CORE` headers.

## Step 4: Replay the numerical instance

Open `SIARCRelay11/Examples/Replay_MasterCertificate.lean`.
Confirm all `#check` commands resolve without errors.

Then open `SIARCRelay11/Examples/Example_ThermoelasticAutoVerify.lean`.
This file proves all 19 numerical inequalities automatically — verify
it type-checks with no sorry.

## Step 5: Check cross-system validation

Open `SIARCRelay11/Examples/Example_LinearHeatEquation.lean`.
This is a second PDE model (linear heat equation) that uses the same
`master_certificate_summary` theorem. Verify it type-checks.

## What is trusted vs. untrusted

| Zone | Files | Sorry count | Role |
|------|-------|-------------|------|
| **Trusted Core** | 13 files (Axioms, Parameters, StateSpace, Barriers, Bundles, 5 Theorems, API, TrustedBoundary, TrustedCore) | **0** | All theorems, certificates, public API |
| **Untrusted Infrastructure** | 3 files (Operators, Control, LocalWellPosedness) | 8 | PDE semigroup bodies, controlled evolution, uniqueness |
| **Examples** | 7 files | varies | Smoke tests, templates, numerical instances |

The theorem layer **never unfolds** untrusted definitions. It treats
`evolutionMap` as opaque and derives all guarantees from the 9 explicit
axioms listed in `SystemAxioms`.

## Quick reference

| Item | Location |
|------|----------|
| Main theorem | `Theorems/AxiomInventory.lean` → `master_certificate_summary` |
| Public API | `API.lean` |
| Axiom list | `Theorems/AxiomInventory.lean` (module docstring) |
| Trust boundary | `TrustedBoundary.lean` |
| Numerical instance | `Examples/Example_ThermoelasticAutoVerify.lean` |
| Second PDE model | `Examples/Example_LinearHeatEquation.lean` |
| Replay smoke test | `Examples/Replay_MasterCertificate.lean` |
| Certificate diagram | `ARTIFACT.md` → Certificate hierarchy |
| Axiom → PDE mapping | `ARTIFACT.md` → Axiom → PDE reference mapping |
| Build instructions | `BUILD.md` |
| Human-readable overview | `OVERVIEW.md` |
