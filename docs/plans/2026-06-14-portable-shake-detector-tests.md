# Portable Shake Detector Tests

Status: In Progress

## Problem

`ShakeDetector` is dependency-free Java, but its behavioral regression suite
only runs through legacy Android Gradle tasks. When the Android SDK is absent,
`make test` skips every executable detector assertion and the canonical local
gate relies only on source-shape contracts.

## Requirements

1. Run dependency-free `ShakeDetector` behavior tests on every `make test` and
   `make check`, regardless of Android SDK availability.
2. Cover the existing finite-input, overflow, threshold, negative/backward
   timestamp, exact debounce-boundary, and maximum-timestamp behavior.
3. Compile production `ShakeDetector.java` directly so the portable suite tests
   the shipped implementation rather than a duplicate.
4. Use an isolated temporary output directory and remove it on success or
   failure without leaving repository artifacts.
5. Preserve the existing Android/JUnit tests and SDK-backed lint, test, and
   build behavior.
6. Add mutation-sensitive contracts for harness invocation, assertion coverage,
   production-source compilation, cleanup, documentation, and plan status.

## Implementation Units

### U1: Add The Portable Harness

**Files:** `scripts/ShakeDetectorHostTest.java`,
`scripts/test-shake-detector.sh`

Create a package-compatible Java test runner with explicit assertions and a
POSIX wrapper that compiles it together with production `ShakeDetector.java`
into a temporary directory.

### U2: Integrate The Canonical Gate

**Files:** `Makefile`, `scripts/check-baseline.sh`

Run the portable suite before the optional Android Gradle test variants and
protect its source, invocation, cleanup, and behavioral matrix.

### U3: Document Verification

**Files:** `AGENTS.md`, `README.md`, `CHANGES.md`, this plan

Document that core detector behavior always runs locally and record truthful
bounded validation after implementation.

## Scope Boundaries

- Do not change detector thresholds, debounce duration, activity lifecycle,
  chooser behavior, permissions, dependencies, Gradle, SDK levels, or UI.
- Do not remove or weaken the existing Android/JUnit regression suite.
- Do not claim emulator, physical-sensor, or chooser runtime verification.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Pending implementation and bounded validation.
