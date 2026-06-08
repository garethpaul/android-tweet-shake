# Shake Finite Acceleration Baseline

## Status: Completed

## Context

`ShakeDetector` computes vector magnitude from accelerometer values. Sensor
inputs should be finite numbers before they are considered for threshold and
debounce logic; `NaN` or infinite values should never trigger tweet composition.

## Objectives

- Ignore `NaN` accelerometer values.
- Ignore infinite accelerometer values.
- Preserve the 2.0g threshold and 200 ms debounce behavior for finite input.
- Keep SDK-free source checks enforcing the finite-value guard.

## Work Completed

- Added a finite acceleration guard before shake threshold calculation.
- Added unit tests for `NaN` and positive infinity inputs.
- Extended `scripts/check-baseline.sh` to require finite-value handling and
  regression tests.
- Documented the guard in README and CHANGES.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`

## Follow-Up Candidates

- Add hardware or emulator notes for real sensor edge cases before further
  threshold changes.
