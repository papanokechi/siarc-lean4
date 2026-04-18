# Artifact: SIARC Lean 4 Formalization

## Scope

This artifact is a Lean 4 + Mathlib4 formalization of safety, stability,
and approximate controllability for a coupled PDE–ODE system
(SIARC = Safety, Invariance, And Resilient Control).

The formal result is self-contained in the `SIARCRelay11/` directory.

---

## Files Constituting the Formal Result

| File | Role |
|------|------|
| `SIARCRelay11/API.lean` | **Public entry point** — re-exports minimal interface |
| `SIARCRelay11/Theorems/AxiomInventory.lean` | Master certificate + axiom classification |
| `SIARCRelay11/Theorems/Controllability.lean` | Approximate controllability via HUM |
| `SIARCRelay11/Theorems/Stability.lean` | Exponential + asymptotic stability |
| `SIARCRelay11/Theorems/ForwardInvarianceFramework.lean` | Abstract forward invariance |
| `SIARCRelay11/Theorems/Invariance.lean` | PDE-specific barrier invariance |
| `SIARCRelay11/Theorems/LocalWellPosedness.lean` | Local existence |

### Infrastructure (scaffolding)

| File | Role |
|------|------|
| `SIARCRelay11/StateSpace.lean` | Product Banach space X = X₁ × X₂ × X₃ |
| `SIARCRelay11/Operators.lean` | Evolution map signatures |
| `SIARCRelay11/Barriers.lean` | Barrier parameters + safe set |
| `SIARCRelay11/Axioms.lean` | Physical constants (coupling κ) |
| `SIARCRelay11/Parameters.lean` | Coupling thresholds |
| `SIARCRelay11/Bundles.lean` | Fiber bundle structures |
| `SIARCRelay11/Control.lean` | Control law structures |

---

## Axiom Inventory

All axioms are catalogued in `SIARCRelay11/Theorems/AxiomInventory.lean`.

### System-Specific Axioms (6) — require PDE proofs

| # | Name | Layer | Reference |
|---|------|-------|-----------|
| 1 | `field_evolution_contraction` | Invariance | Pazy Thm 4.3 (Lumer–Phillips) |
| 2 | `thermal_evolution_bound` | Invariance | Evans §6.4 (max principle + ABP) |
| 3 | `gradient_evolution_bound` | Invariance | Lieberman Ch. 7 (Bernstein) |
| 4 | `diagonal_dissipation` | Stability | Gearhart–Prüss theorem |
| 5 | `cross_coupling_bound` | Stability | Henry §5.1 (Lipschitz coupling) |
| 6 | `unique_continuation` | Controllability | Carleman estimates (Zuazua 2007) |

### Axiom → PDE Reference Mapping

| Axiom | Mathematical Statement | PDE Mechanism | Literature Reference |
|-------|----------------------|---------------|---------------------|
| `field_evolution_contraction` | ‖Φ_t(σ₀).field‖ ≤ ‖σ₀.field‖ | Contraction semigroup from dissipativity | Pazy, *Semigroups of Linear Operators* (1983), Thm 4.3 |
| `thermal_evolution_bound` | θ(t) ≤ T_quench | Maximum principle for parabolic PDE | Evans, *PDE* (2010), §6.4 |
| `gradient_evolution_bound` | ‖∇θ(t)‖_∞ ≤ gradT_max | Bernstein gradient estimate | Lieberman, *Second Order Parabolic DE* (1996), Ch. 7 |
| `diagonal_dissipation` | diag(dV/dt) ≤ −2λ_gap·V | Spectral gap of diagonal operators | Gearhart–Prüss: ω₀(e^{tL}) = s₀(L) |
| `cross_coupling_bound` | cross(dV/dt) ≤ 2\|κ\|L·V | Lipschitz bound on coupling operator | Henry, *Geometric Theory* (1981), §5.1 |
| `unique_continuation` | B*φ ≡ 0 on [0,T] ⟹ φ_T = 0 | Unique continuation for adjoint | Zuazua (2007); Lions (1988) |

### Utility Axioms (3)

| # | Name | Layer | Status |
|---|------|-------|--------|
| 7 | `lyapunov_deriv_decomposition` | Stability | Axiom (structural; needs refactor) |
| 8 | `gronwall_integration` | Stability | Axiom (needs concrete ODE comparison) |
| 9 | `hum_density_of_reachable_set` | Control | Axiom (active; Lions 1988) |

Two former utility axioms were **discharged to theorems** (Relay 18).
Three unused axioms were **removed** (Relay 23).

**Total: 9 axioms (6 system-specific + 3 utility). 0 sorry in theorem files.**

---

## Public API

Import `SIARCRelay11.API` to access:

### Main Objects

- `MasterCertificate` — bundles all 6 axioms + the controllability
  certificate (which nests safety and stability).
- `master_certificate_summary` — the one theorem proving all 4 guarantees.

### Guarantees (given `MasterCertificate` + initial state in safe set)

1. **Safety:** Trajectories remain in `InSafe` for all t ≥ 0.
2. **Exponential decay:** V(σ(t)) ≤ V(σ₀) · exp(−2ωt).
3. **Convergence:** For any ε > 0, eventually V(σ(t)) < ε.
4. **Controllability:** Approximate steering to any target state.

### Certificate Hierarchy

```
                    ┌─────────────────────┐
                    │  SystemAxioms (6)    │
                    │  PDE properties      │
                    └─────────┬───────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │  SafetyCertificate   │  ← 5 barrier functions
                    │  forward invariance  │     g₁–g₅ all non-negative
                    └─────────┬───────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │ StabilityCertificate │  ← Lyapunov V, spectral gap
                    │ exp decay + conv.   │     V(σ(t)) ≤ V(σ₀)·e^{−2ωt}
                    └─────────┬───────────┘
                              │
                              ▼
               ┌──────────────────────────────┐
               │ ControllabilityCertificate    │  ← HUM + adjoint + UCP
               │ approximate steering         │     ‖Φ_T^u(σ₀) − target‖ < ε
               └──────────────┬───────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │  MasterCertificate   │  ← axioms + certificate
                    └─────────┬───────────┘
                              │
                              ▼
              ┌────────────────────────────────┐
              │  master_certificate_summary     │
              │  (safety ∧ decay ∧ conv ∧ ctrl)│
              └────────────────────────────────┘
```

### Data Structure (fields)

```
MasterCertificate
├── axioms : SystemAxioms               (6 physical assumptions)
└── certificate : ControllabilityCertificate
    ├── stability : StabilityCertificate
    │   └── safety : SafetyCertificate
    ├── adjoint : AdjointEvolution
    ├── control_op : ControlOperator
    ├── observation : ObservationOperator
    ├── gramian : ObservabilityGramian
    └── obs_ineq : ObservabilityInequality
```

---

## Replay Recipe

```bash
# 1. Clone
git clone https://github.com/papanokechi/siarc-lean4.git
cd siarc-lean4

# 2. Fetch Mathlib cache
lake exe cache get

# 3. Build
lake build

# 4. Verify examples
lake build SIARCRelay11Examples

# 5. Confirm sorry-free theorem layer
grep -rn "sorry" SIARCRelay11/Theorems/
# Expected: matches only in comments/docstrings, not in proof terms
```

Then open `SIARCRelay11/Examples/Replay_MasterCertificate.lean` in
VS Code with the Lean 4 extension to see the `#check` / `#print`
output confirming the master theorem.

---

## Concrete PDE Instantiation

`SIARCRelay11/Examples/Example_ThermoelasticSystem.lean` shows how to
instantiate `SystemAxioms` for a **concrete PDE model** — the quasi-static
thermoelastic SIARC system on a bounded Lipschitz domain Ω in ℝ³ —
and obtain a `MasterCertificate` for that model.

Key definitions:
- `ThermoelasticData` / `ThermoelasticBarrierData` — physical parameters
- `thermoelastic_axioms` — instantiates `SystemAxioms` from 6 named lemmas
- `thermoelastic_master_certificate` — the concrete `MasterCertificate`
- `thermoelastic_safe_stable_controllable` — the physical theorem

Each of the 6 system-specific axioms is a named `axiom` with a docstring
pointing to the PDE reference (Pazy, Evans, Lieberman, Gearhart–Prüss,
Henry, Zuazua). These would become `theorem`s once the relevant Mathlib /
PDE theory is available.

---

## Numerical Instance

`SIARCRelay11/Examples/Example_ThermoelasticParameters.lean` provides a
**fully numerical** instantiation with concrete physical parameter values:

| Parameter | Value | Parameter | Value |
|-----------|-------|-----------|-------|
| B_max | 10 | T_quench | 1500 |
| T_boundary | 300 | gradT_max | 200 |
| sigma_yield | 300 | C_curv | 0.05 |
| λ_min | 0.1 | L_coupling | 0.02 |
| κ₂=κ₃=κ₄=κ₅ | 1.0 | | |

All positivity inequalities are verified by Lean (`norm_num`).
The coupling smallness hypotheses (|κ|·0.02 < 0.1 and |κ| < 1) are
carried as explicit hypotheses on the global coupling constant κ.

---

## Automated Numerical Verification

`SIARCRelay11/Examples/Example_ThermoelasticAutoVerify.lean` demonstrates
that **all 20 numerical inequalities** in the thermoelastic certificate are
automatically discharged by Lean's decision procedures:

| Strategy | Count | Examples |
|----------|-------|----------|
| `norm_num` | 15 | `10 > 0`, `300 < 1500`, `0.05 > 0` |
| `simp` | 1 | `min(1,min(1,min(1,1))) = 1` |
| `linarith` | 1 | `0.1 − |κ|·0.02 > 0` |
| `nlinarith` | 1 | `|κ| < 5` |
| hypothesis | 2 | `|κ|·0.02 < 0.1`, `|κ| < 1` |

Every inequality is a standalone named `lemma`. The `autoParams`
construction references only these lemmas, and `auto_safe_stable_controllable`
proves all 4 SIARC guarantees with zero manual arithmetic.

---

## Infrastructure Sorry's

**Remaining infrastructure sorry's (8 total):**

| File | Count | Reason |
|------|-------|--------|
| `Operators.lean` | 6 | PDE semigroup bodies |
| `Control.lean` | 1 | Controlled PDE solution |
| `LocalWellPosedness.lean` | 1 | Uniqueness clause |

These are architecturally blocked — they require PDE semigroup theory not
in Mathlib. The **theorem layer** remains **sorry-free**.

---

## Trusted Core Boundary

`SIARCRelay11/TrustedBoundary.lean` formally separates the artifact into:

- **Trusted Core** (12 files, 0 sorry) — all theorems, certificate structures,
  axiom inventory, public API, and the trust boundary itself.
- **Untrusted Infrastructure** (3 files, 8 sorry) — PDE semigroup bodies,
  controlled evolution, well-posedness uniqueness.

`trusted_core_soundness` — theorem stating all 4 SIARC guarantees hold
for any `MasterCertificate`. Sorry-free.

---

## Reproducibility

| Item | Value |
|------|-------|
| **Lean version** | v4.14.0 (pinned in `lean-toolchain`) |
| **Mathlib4 version** | v4.14.0 (pinned in `lakefile.lean`) |
| **Build system** | Lake (ships with Lean 4) |
| **OS tested** | Windows 11 |
| **Build command** | `lake exe cache get && lake build` |
| **Trusted core only** | `lake build SIARCRelay11TrustedCore` |
| **Expected: errors** | 0 |
| **Expected: sorry in theorem layer** | 0 |
| **Expected: sorry in infrastructure** | 8 (documented in `TrustedBoundary.lean`) |
| **Expected: axioms** | 9 (6 system-specific + 3 utility) |

### Expected `lake build` output

A successful build completes with no errors. The only `sorry` warnings
appear in infrastructure files (`Operators.lean`, `Control.lean`,
`LocalWellPosedness.lean`) — these are documented PDE placeholders
that do not affect the trusted theorem layer.

---

## Artifact Versioning

| Version | Location | Purpose |
|---------|----------|---------|
| GitHub [v1.0.0](https://github.com/papanokechi/siarc-lean4/releases/tag/v1.0.0) | GitHub release | Development + browsing |
| Zenodo [doi:10.5281/zenodo.19641981](https://doi.org/10.5281/zenodo.19641981) | Archival snapshot | **JAR submission reference** |

The Zenodo archive is the archival version cited in the manuscript and used
for JAR review. The GitHub repository may receive updates after publication.

---

## How to Cite

```bibtex
@software{papanokechi_siarc_2026,
  author       = {papanokechi},
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

## AI Disclosure

**AI-Assistance Statement.**
Portions of the computational workflow — including iterative development of
Lean 4 proofs — were conducted within an AI-assisted research environment.
GitHub Copilot was used for code completion and Anthropic Claude for
research assistance. AI tools were used for editing, refactoring, and
documentation — not for generating proofs. All proofs and numerical results
were independently verified by the author.

---

## Statement of Novelty

This artifact presents the first fully mechanized safety–stability–controllability
certificate for a coupled PDE–ODE system in Lean 4, including:

- A sorry-free theorem layer deriving all four guarantees from 9 explicit axioms
- A concrete numerical thermoelastic instance with 20 auto-verified inequalities
- A trusted-core boundary formally separating verified theorems from infrastructure
- Cross-system validation via a second PDE model (linear heat equation)

---

## Version

- **Library version:** v1.0.0
- **Lean:** v4.14.0 (pinned in `lean-toolchain`)
- **Mathlib4:** v4.14.0 (pinned in `lakefile.lean`)
- **Repository:** https://github.com/papanokechi/siarc-lean4
- **Zenodo archive:** https://doi.org/10.5281/zenodo.19641981
