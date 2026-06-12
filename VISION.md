## Android Tweet Shake Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Android Tweet Shake is a legacy Android app that opens the platform sharesheet
with prefilled text when the user shakes the phone.

The repository is useful as a small accelerometer, lifecycle, and user-mediated
sharing sample from an older Android stack.

The goal is to preserve the sample's intent while keeping sensor behavior,
sharing, and dependency modernization explicit and safe.

The current focus is:

Priority:

- Keep shake-triggered sharing understandable and user-confirmed
- Preserve tested accelerometer threshold, finite-value, overflow, and debounce behavior
- Ensure rejected sensor samples do not consume shake debounce state
- Keep shake debounce timing based on monotonic elapsed realtime
- Keep missing sensors and listener registration failures visible to the user
- Guard sharesheet launch failures and duplicate chooser launches without
  package-visibility preflight queries
- Keep retired Fabric/Twitter dependencies, credentials, and network permission removed
- Maintain SDK-free `make check` coverage for sensor, sharesheet, and build guardrails
- Keep GitHub Actions aligned with the SDK-free `make check` baseline
- Keep root lint, test, and build gates wired to the Gradle project
- Keep the legacy Gradle runtime behind a checksum-verified generated wrapper

Next priorities:

- Verify shake threshold and chooser behavior on hardware
- Evaluate Gradle runtime, SDK, and dependency modernization together in a
  dedicated compatibility pass; wrapper hardening is separate
- Add activity-level tests after the Android toolchain is modernized

Contribution rules:

- One PR = one focused sensor, sharing, build, or documentation topic.
- Verify shake behavior on hardware when changing sensor logic.
- Keep sharing explicit and user-mediated through the platform chooser.
- Keep `.github/workflows/check.yml` in sync with the SDK-free baseline and
  local Gradle gates.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

The app does not own social credentials, sessions, or posting APIs. The selected
sharing app controls account and network behavior after the user chooses it.

Sensor-triggered sharing must remain user-confirmed through the Android
sharesheet; do not add silent posting or background account actions.

## What We Will Not Merge (For Now)

- Hardcoded social API keys, tokens, or signing files
- Silent posting or background account actions
- Restored Fabric or Twitter Kit dependencies
- Sensor rewrites without hardware verification notes
- Broad dependency migrations bundled with unrelated behavior changes

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
