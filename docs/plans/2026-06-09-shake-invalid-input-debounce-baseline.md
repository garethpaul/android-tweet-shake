---
title: Shake Invalid Input Debounce Baseline
type: test
status: completed
date: 2026-06-09
---

# Shake Invalid Input Debounce Baseline

## Problem Frame

`ShakeDetector` rejects non-finite accelerometer values before evaluating the
shake threshold. The existing tests cover rejection, but they do not prove that
invalid sensor samples leave the debounce window untouched for the next valid
shake.

## Scope Boundaries

- Preserve the existing 2.0g threshold and 200ms debounce interval.
- Do not change `ShakeActivity`, Twitter/Fabric behavior, permissions, or build
  tooling in this pass.
- Keep verification available through JVM tests and the SDK-free baseline.

## Implementation Units

### U1: Add Debounce Regression Coverage

Files:

- Modify `app/src/test/java/gpj/tweetshake/ShakeDetectorTest.java`

Approach:

- Feed a non-finite accelerometer sample into a fresh detector.
- Immediately feed a valid threshold-crossing sample.
- Assert that the valid sample still triggers.

### U2: Extend Static Baseline Checks

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Require the invalid-input debounce regression test by name.

### U3: Document The Contract

Files:

- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Record that invalid sensor samples do not consume debounce state.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `./gradlew test --no-daemon`
- `git diff --check`
