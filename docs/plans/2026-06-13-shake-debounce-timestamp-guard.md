---
title: Shake Debounce Timestamp Guard
type: fix
status: completed
date: 2026-06-13
---

# Shake Debounce Timestamp Guard

## Status: Completed

## Problem Frame

`ShakeDetector` initializes its last-shake timestamp to negative one debounce
interval and subtracts that value from every supplied elapsed-realtime value.
For a valid first sample at `Long.MAX_VALUE`, that subtraction overflows and the
detector incorrectly treats the sample as debounced. A timestamp moving behind
the last accepted sample also produces a negative duration and needs an
explicit contract that does not corrupt debounce state.

## Scope Boundaries

- Preserve the existing 2.0g threshold and 200 ms debounce interval.
- Preserve rejection of non-finite and overflowed acceleration values.
- Keep `ShakeActivity`, sharing behavior, permissions, and build tooling
  unchanged.
- Keep verification available through pure JVM tests and the SDK-free baseline.

## Implementation Units

### U1: Make First-Sample State Explicit

Files:

- Modify `app/src/main/java/gpj/tweetshake/ShakeDetector.java`

Approach:

- Replace the negative timestamp initializer with explicit accepted-shake
  state.
- Let the first valid threshold-crossing sample trigger at any nonnegative
  elapsed-realtime value, including `Long.MAX_VALUE`.
- Reject timestamps earlier than the last accepted shake without updating
  debounce state.
- Continue accepting a shake exactly at the 200 ms cooldown boundary.

### U2: Add Timestamp Boundary Coverage

Files:

- Modify `app/src/test/java/gpj/tweetshake/ShakeDetectorTest.java`

Approach:

- Prove a first shake at `Long.MAX_VALUE` triggers.
- Prove a backward timestamp is rejected and does not replace the last accepted
  timestamp.
- Retain the existing consecutive-shake and cooldown-boundary assertions.

### U3: Extend The Static Contract

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Require explicit accepted-shake state and backward-time rejection.
- Reject restoration of the negative timestamp initializer.
- Require the two timestamp-boundary regression tests by name.

### U4: Record The Contract

Files:

- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Record overflow-safe first-sample handling and non-consuming rejection of
  backward timestamps.

## Verification

- `scripts/check-baseline.sh` passed.
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon` passed
  with 12 debug and 12 release JVM tests.
- SDK-backed `make check` passed from the repository root and through the
  absolute Makefile path from `/tmp`, including lint, tests, and debug APK
  assembly. Lint retained the repository's existing `OldTargetApi` warning.
- Ten isolated hostile mutations were rejected: sentinel removal, restoration
  of negative initialization, weakened negative/backward/cooldown comparisons,
  omitted sentinel branching or state acceptance, and removal of each new test
  contract.
- `git diff --check` passed.

The first direct Gradle test attempt lacked `ANDROID_HOME` and failed during
project evaluation before compilation. The bounded rerun with the installed
SDK path passed as recorded above.
