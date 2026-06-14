# Android Tweet Shake Device Verification Checklist

Status: Completed

## Problem

Portable contracts cover finite acceleration, overflow rejection, monotonic
debounce timing, registration ownership, duplicate chooser suppression, and
share-launch recovery, but no checklist defines repeatable physical-sensor or
emulator evidence for the exact implementation commit.

## Requirements

1. Add an exact-commit matrix for sensor availability, threshold behavior,
   debounce, registration, pause/resume, chooser ownership, failures, and
   relaunch.
2. Require synthetic share text and sanitized toolchain, device, sensor,
   result, and evidence fields.
3. Keep repository checks separate from unexecuted Android, accelerometer,
   chooser, and hardware scenarios.
4. Add mutation-sensitive contracts for the checklist and completion evidence.

## Scope Boundaries

- Do not change detector thresholds, lifecycle behavior, Android SDK, Gradle
  plugin, dependencies, share targets, or chooser behavior.
- Do not add real draft text, account data, device identifiers, sensor dumps,
  screenshots, logs, APKs, or local configuration.
- Do not claim emulator, accelerometer, chooser, or physical-device execution
  from portable checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- `sh -n scripts/check-baseline.sh` and the focused baseline checker passed.
- `make check` passed from the repository and from an external working
  directory with the available Android API 22 toolchain.
- Twelve hostile mutations were rejected by the checklist's static contracts.
- The Android SDK was used only for build-time lint, tests, and assembly.
- No emulator, accelerometer injection, physical device, share target, or live chooser scenario was executed;
  every runtime matrix row remains `not run`.
