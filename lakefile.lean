-- lakefile.lean
-- SIARCRelay11: Lake build configuration
-- Sorry-free safety–stability–controllability certificate stack

import Lake
open Lake DSL

package «siarc-lean4» where
  version := v!"1.0.0"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.14.0"

@[default_target]
lean_lib «SIARCRelay11» where
  roots := #[`SIARCRelay11]

-- Public API (the recommended import for external users)
lean_lib «SIARCRelay11API» where
  roots := #[`SIARCRelay11.API]

-- Trusted Core (minimal public face — just 3 objects)
lean_lib «SIARCRelay11TrustedCore» where
  roots := #[`SIARCRelay11.TrustedCore]

-- Examples (smoke tests for reviewers)
lean_lib «SIARCRelay11Examples» where
  roots := #[`SIARCRelay11.Examples.Example_Minimal,
             `SIARCRelay11.Examples.Replay_MasterCertificate,
             `SIARCRelay11.Examples.Example_ThermoelasticSystem,
             `SIARCRelay11.Examples.Example_ThermoelasticParameters,
             `SIARCRelay11.Examples.Example_ThermoelasticAutoVerify,
             `SIARCRelay11.Examples.Example_LinearHeatEquation]
