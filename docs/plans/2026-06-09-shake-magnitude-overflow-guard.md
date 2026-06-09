# Shake Magnitude Overflow Guard

status: completed

## Context

`ShakeDetector` rejected `NaN` and infinite accelerometer components before
computing magnitude. Extremely large finite components could still overflow the
squared magnitude calculation to infinity and be treated as a valid shake.

## Objectives

- Preserve the existing 2.0g threshold and 200 ms debounce behavior.
- Reject non-finite magnitude calculations before threshold evaluation.
- Ensure overflowed magnitude inputs do not consume the debounce window.
- Keep the guard covered by unit tests and the SDK-free baseline checker.

## Work Completed

- Split squared magnitude into an explicit local value.
- Reused the finite-value helper to reject overflowed magnitude before
  threshold and debounce checks.
- Added a unit test for `Float.MAX_VALUE` component overflow.
- Extended `scripts/check-baseline.sh`.
- Updated README, VISION, and CHANGES notes.

## Verification

- `./gradlew test --no-daemon`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
