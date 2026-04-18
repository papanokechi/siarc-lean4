# Building SIARCRelay11

## Prerequisites

- **Lean 4:** v4.14.0 (pinned in `lean-toolchain`)
- **Mathlib4:** v4.14.0 (pinned in `lakefile.lean`)
- **Lake:** ships with Lean 4

## Quick start

```bash
# 1. Clone the repository
git clone <repo-url> && cd siarc-lean4

# 2. Fetch Mathlib cache (saves ~30 min of compilation)
lake exe cache get

# 3. Build the library
lake build

# 4. Build examples (smoke test)
lake build SIARCRelay11Examples
```

## Build targets

| Target | Command | Content |
|--------|---------|---------|
| `SIARCRelay11` | `lake build` | Full library (default) |
| `SIARCRelay11API` | `lake build SIARCRelay11API` | Public API only |
| `SIARCRelay11TrustedCore` | `lake build SIARCRelay11TrustedCore` | Trusted core only (minimal) |
| `SIARCRelay11Examples` | `lake build SIARCRelay11Examples` | Smoke tests |

## One-command trusted core verification

To verify **only** the sorry-free trusted core (the public face of the artifact):

```bash
lake build SIARCRelay11TrustedCore
```

This command compiles `TrustedCore.lean`, which transitively verifies:
- All theorem files (Invariance, Stability, Controllability, AxiomInventory)
- The `master_certificate_summary` theorem
- The `SystemAxioms` and `MasterCertificate` structures

It does **not** compile examples or untrusted infrastructure beyond what the
theorem layer requires. A clean build with zero errors confirms the entire
trusted core is valid.

## Expected output

A successful build produces **zero errors** and **zero `sorry`** warnings
in the theorem files (`Invariance.lean`, `Stability.lean`,
`Controllability.lean`, `AxiomInventory.lean`).

Infrastructure files (`StateSpace.lean`, `Operators.lean`) contain
`sorry` placeholders for `NormedAddCommGroup` instances and evolution
map bodies — these are scaffolding and do not affect the theorem layer.

## Verification

After building, confirm the sorry-free status of the theorem layer:

```bash
# Should return matches only in documentation comments, not in proofs
grep -rn "sorry" SIARCRelay11/Theorems/
```

## For reviewers

The fastest way to verify the artifact:

1. `lake exe cache get && lake build`
2. Open `SIARCRelay11/Examples/Replay_MasterCertificate.lean` in VS Code
3. Confirm all `#check` commands resolve without errors
