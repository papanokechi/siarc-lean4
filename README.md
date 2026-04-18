# SIARC — Mechanized Safety–Stability–Controllability for Coupled PDE Systems

[![Lean 4](https://img.shields.io/badge/Lean%204-v4.14.0-blue)](https://leanprover.github.io/)
[![Mathlib4](https://img.shields.io/badge/Mathlib4-v4.14.0-blue)](https://github.com/leanprover-community/mathlib4)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19641981.svg)](https://doi.org/10.5281/zenodo.19641981)

**SIARC** (Safety, Invariance, And Resilient Control) is a fully mechanized
Lean 4 + Mathlib4 framework that establishes forward invariance, exponential
Lyapunov stability, asymptotic convergence, and approximate controllability
for coupled semilinear parabolic PDE-ODE systems.

> **Paper:** *SIARC: A Mechanized Safety–Stability–Controllability Framework
> for Semilinear Parabolic PDE Systems in Lean 4*
> — Shunsuke Kubota (2026). Under review at JAR.
>
> **Zenodo archive:** [doi:10.5281/zenodo.19641981](https://doi.org/10.5281/zenodo.19641981)

---

## What It Proves

Given a `MasterCertificate` and an initial state σ₀ in the safe set:

1. **Safety:** Trajectories remain in the safe operating envelope for all *t* ≥ 0.
2. **Exponential decay:** *V*(σ(*t*)) ≤ *V*(σ₀) · e^{−2ωt}.
3. **Convergence:** For any ε > 0, eventually *V*(σ(*t*)) < ε.
4. **Controllability:** Approximate steering to any target state.

All four guarantees are extracted by a single **sorry-free** capstone theorem:
`master_certificate_summary`.

---

## Quick Start

### Prerequisites

- [Lean 4 v4.14.0](https://leanprover.github.io/lean4/doc/setup.html)
  (automatically managed via `lean-toolchain`)
- Internet connection (to fetch the Mathlib cache)

### Build

```bash
# Clone
git clone https://github.com/papanokechi/siarc-lean4.git
cd siarc-lean4

# Fetch Mathlib cache (saves ~30 min of compilation)
lake exe cache get

# Build the entire project
lake build

# Build only the trusted core (minimal, sorry-free)
lake build SIARCRelay11TrustedCore

# Build only the examples
lake build SIARCRelay11Examples
```

### Verify Auto-Checked Numerical Inequalities

Open `SIARCRelay11/Examples/Example_ThermoelasticAutoVerify.lean` in
VS Code with the Lean 4 extension. All 20 numerical inequalities are
verified by `norm_num`, `simp`, `linarith`, and `nlinarith` — no `sorry`,
no external axioms.

---

## Project Structure

```
.
├── lakefile.lean                          Build configuration (v1.0.0)
├── lean-toolchain                         Lean v4.14.0
├── SIARCRelay11.lean                      Root module (imports all sub-modules)
│
├── SIARCRelay11/
│   ├── API.lean                           PUBLIC ENTRY POINT
│   ├── TrustedCore.lean                   Minimal public face (3 objects)
│   ├── TrustedBoundary.lean               Trust boundary + sorry inventory
│   │
│   ├── Axioms.lean                        Mathematical obstacles / axioms
│   ├── Parameters.lean                    Coupling thresholds (κ_safe)
│   ├── StateSpace.lean                    Product Banach space X₁×X₂×X₃
│   ├── Barriers.lean                      Barrier functions g₁–g₅ + safe set
│   ├── Bundles.lean                       Fiber bundle structures
│   ├── Operators.lean                     Evolution map signatures (6 sorry)
│   ├── Control.lean                       Control law structures (1 sorry)
│   │
│   ├── Theorems/
│   │   ├── AxiomInventory.lean            MasterCertificate + capstone theorem
│   │   ├── Invariance.lean                PDE-specific barrier invariance
│   │   ├── ForwardInvarianceFramework.lean  Abstract forward invariance
│   │   ├── Stability.lean                 Exponential + asymptotic stability
│   │   ├── Controllability.lean           Approximate controllability (HUM)
│   │   └── LocalWellPosedness.lean        Local existence (1 sorry)
│   │
│   └── Examples/
│       ├── Example_Minimal.lean           How to use the API
│       ├── Replay_MasterCertificate.lean  Reviewer smoke test
│       ├── Example_ThermoelasticSystem.lean      Concrete PDE instantiation
│       ├── Example_ThermoelasticParameters.lean  Numerical parameter instance
│       ├── Example_ThermoelasticAutoVerify.lean  20 auto-verified inequalities
│       ├── Example_LinearHeatEquation.lean       Cross-validation (2nd model)
│       └── Example_PhysicalSystem.lean           User-fillable template
│
├── ARTIFACT.md                            Scope, axioms, replay recipe
├── README.md                              This file
├── LICENSE                                MIT License
└── manuscript.tex                         LaTeX manuscript source
```

### Trusted Core vs. Untrusted Infrastructure

| Zone | Files | Sorry count |
|------|-------|-------------|
| **Trusted Core** | 13 files (all theorem + API files) | **0** |
| **Untrusted Infrastructure** | `Operators.lean`, `Control.lean`, `LocalWellPosedness.lean` | 8 |

The theorem layer **never unfolds** infrastructure definitions. All guarantees
derive from 9 explicit axioms (6 system-specific PDE properties + 3 standard
functional-analysis utilities). Infrastructure sorrys **cannot** introduce
logical inconsistency into the trusted theorems.

---

## Axiom Boundary

### System-Specific Axioms (6)

| # | Axiom | Mathematical Statement | Reference |
|---|-------|----------------------|-----------|
| 1 | `field_evolution_contraction` | ‖Φ_t(σ₀)₁‖ ≤ ‖(σ₀)₁‖ | Pazy Thm 4.3 |
| 2 | `thermal_evolution_bound` | T_sup(Φ_t(σ₀)₂) ≤ T_sup((σ₀)₂) | Evans §6.4 |
| 3 | `gradient_evolution_bound` | ‖∇Φ_t(σ₀)₂‖_∞ ≤ ‖∇(σ₀)₂‖_∞ | Lieberman Ch. 7 |
| 4 | `diagonal_dissipation` | diag(V̇) ≤ −2λ_gap · V | Gearhart–Prüss |
| 5 | `cross_coupling_bound` | cross(V̇) ≤ 2\|κ\|L · V | Henry §5.1 |
| 6 | `unique_continuation` | B*φ ≡ 0 ⟹ φ_T = 0 | Zuazua 2007 |

### Utility Axioms (3)

| # | Axiom | Status |
|---|-------|--------|
| 7 | `lyapunov_deriv_decomposition` | Axiom (structural identity) |
| 8 | `gronwall_integration` | Axiom (needs semigroup generation) |
| 9 | `hum_density_of_reachable_set` | Axiom (Lions 1988) |

Two former utility axioms were **discharged to theorems** (Relay 18).
Three unused axioms were **removed** (Relay 23).

---

## Examples and the Manuscript

### Thermoelastic System (§6–7 of the manuscript)

`Example_ThermoelasticAutoVerify.lean` demonstrates the full SIARC pipeline:
- `autoParams` — automatic parameter construction
- `autoMasterCert` — automatic certificate assembly
- `auto_safe_stable_controllable` — the capstone theorem applied
- Decay-rate, safety, and controllability extractors

### Linear Heat Equation (§8 of the manuscript)

`Example_LinearHeatEquation.lean` instantiates SIARC for the scalar heat
equation with zero coupling, validating that the framework is not specific
to the thermoelastic model.

---

## Reproducibility Table

| Item | Value |
|------|-------|
| Lean version | v4.14.0 (pinned in `lean-toolchain`) |
| Mathlib4 version | v4.14.0 (pinned in `lakefile.lean`) |
| Build system | Lake (ships with Lean 4) |
| Full build | `lake exe cache get && lake build` |
| Trusted core only | `lake build SIARCRelay11TrustedCore` |
| Expected errors | 0 |
| Expected sorry in theorem layer | 0 |
| Expected sorry in infrastructure | 8 (documented) |
| Artifact repository | https://github.com/papanokechi/siarc-lean4 |
| Artifact archive | https://doi.org/10.5281/zenodo.19641981 |

### Numerical Lemma Verification (20 inequalities)

| Tactic | Count | Examples |
|--------|-------|----------|
| `norm_num` | 15 | 10 > 0, 300 < 1500, 0.05 > 0 |
| `simp` | 1 | min(1, min(1, min(1, 1))) = 1 |
| `linarith` | 1 | 0.1 − \|κ\| · 0.02 > 0 |
| `nlinarith` | 1 | \|κ\| < 5 |
| `hypothesis` | 2 | \|κ\| · 0.02 < 0.1, \|κ\| < 1 |
| **Total** | **20** | |

---

## AI Disclosure

**AI-Assistance Statement.**
This work made use of AI tools (GitHub Copilot for Lean 4 code completion
and Anthropic Claude for research assistance). All proofs and numerical
results were independently verified by the author. The full artifact is
available at: https://github.com/papanokechi/siarc-lean4

---

## How to Cite

```bibtex
@software{kubota_siarc_2026,
  author       = {Kubota, Shunsuke},
  title        = {{SIARC: A Mechanized Safety--Stability--Controllability
                   Framework for Semilinear Parabolic PDE Systems in Lean 4}},
  year         = {2026},
  publisher    = {Zenodo},
  version      = {v1.0.0},
  doi          = {10.5281/zenodo.19641981},
  url          = {https://doi.org/10.5281/zenodo.19641981}
}
```

---

## License

[MIT](LICENSE)
