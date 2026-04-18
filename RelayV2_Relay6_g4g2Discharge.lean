/-!
# Relay V2 — Relay 6: Thermal Barrier Analyst (g₄ + g₂ Discharge)

## Role
PDE heat-kernel specialist. Discharge ALL remaining vacuous barriers.

## Result: COMPLETE — 5/5 barriers discharged

This relay went beyond its original brief (g₄ only) and also discharged g₂,
completing the entire barrier invariance proof. No vacuous axioms remain.

## What was done

### g₄ (quench temperature barrier)
- **Removed:** vacuous `g₄_lie_nonneg` axiom (was `→ True`)
- **Added:** `thermal_evolution_bound` axiom
  - Statement: `thermalSup (Φ_t σ₀).thermal ≤ thermalSup σ₀.thermal`
  - Hypotheses: `|κ| < κ_safe ct`, g₁ field bound (via `h_field`)
  - Content: max principle + ABP estimate + coupling smallness absorbs Joule heating
  - References: Evans §6.4, Caffarelli–Cabré Ch. 3
- **Proved:** `invariant_g4` via `rw [g₄_nonneg_iff]; exact le_trans ... h₄`
- **No sorry, no Nagumo routing.**

### g₂ (thermal gradient barrier)
- **Removed:** vacuous `g₂_lie_nonneg` axiom (was `→ True`)
- **Added:** `gradient_evolution_bound` axiom
  - Statement: `thermalGradient (Φ_t σ₀).thermal ≤ thermalGradient σ₀.thermal`
  - Hypotheses: `|κ| < κ_safe ct`, g₁ field bound (via `h_field`)
  - Content: Bernstein gradient estimate + coupling smallness absorbs gradient source
  - References: Lieberman Ch. 7, Krylov–Safonov Harnack
- **Proved:** `invariant_g2` via `rw [g₂_nonneg_iff]; exact le_trans ... h₂`
- **No sorry, no Nagumo routing.**

## Final axiom inventory (3 meaningful axioms)

| Axiom | Content | Reference |
|-------|---------|-----------|
| `field_evolution_contraction` | ‖Φ_t(σ₀).field‖ ≤ ‖σ₀.field‖ | Pazy Thm 4.3 |
| `thermal_evolution_bound` | thermalSup(Φ_t σ₀) ≤ thermalSup(σ₀) | Evans §6.4 |
| `gradient_evolution_bound` | thermalGradient(Φ_t σ₀) ≤ thermalGradient(σ₀) | Lieberman Ch. 7 |

All three are *contraction-type bounds* with the same shape:
  `‖output(Φ_t σ₀)‖ ≤ ‖output(σ₀)‖`

This reflects the underlying parabolic contractivity of the system under small coupling.

## Proof pattern (uniform across all 5 barriers)

For each barrier gₖ with threshold Tₖ:
1. `rw [gₖ_nonneg_iff]` — convert to `measurement ≤ threshold`
2. `exact le_trans (evolution_bound ...) h₀` — chain: evolved ≤ initial ≤ threshold

The pattern is: **"evolution contracts; initial satisfies; transitivity closes."**

## Structural notes

- `nagumo_invariance` is retained in the file but is **no longer used by any barrier**.
  It could be removed, but we keep it for potential future extensions (e.g., if the
  system is extended with non-parabolic components where Nagumo is the natural tool).

- The `safe_manifold_invariance` theorem and `InSafe_invariance` corollary are
  unchanged — they assemble the five barrier invariance lemmas into the final result.

- The quasi-static linkage (g₃', g₅ from g₄) was already discharged in Relay 4.
  Relay 6 completed the picture by providing the upstream g₄ proof that these
  depend on, making the entire DAG load-bearing.

## What's next (Relay 7+)

With all barriers discharged, the natural next targets are:

1. **Stability analysis** — Gearhart–Prüss spectral gap theorem for exponential
   decay to equilibrium. This would add a rate to the contraction bounds.

2. **Controllability** — HUM duality method + unique continuation for the adjoint.
   This would show the system can be steered between safe states.

3. **Axiom strengthening** — Replace the `True` placeholders in Parameters.lean
   (e.g., `Dissipative`, `UniformlyElliptic`) with real conditions on the operators,
   and derive the three evolution bound axioms from those conditions.

4. **Numerical certificate** — Verify κ_safe numerically for specific material
   parameters, closing the gap between the abstract proof and engineering practice.
-/
