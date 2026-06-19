# Android Tweet Shake Deep Review

Status: In Progress

## Refs and Surface

- Pull requests: `#2` through `#8`
- Surface: Gradle wrapper and CI, shake threshold/debounce, sensor lifecycle,
  Android sharesheet launch/recovery, portable tests, and device evidence

## Bug

The stacked changes improved pause and registration guards, but one activity-wide
listener was reused across every resume. A callback queued by an earlier
registration could therefore run after a later resume, observe the new booleans,
and be treated as current. Debounce also used callback time instead of the sensor
event timestamp, and the threshold epsilon accepted the adjacent float below 2g.

## Cause and Provenance

- Clear: the original single listener came from the 2015 activity design.
- Clear: lifecycle booleans were introduced by the June 10-14, 2026 hardening
  commits and reduced background launches, but did not encode listener identity.
- Clear: monotonic callback time was introduced by commit `b67ff7c`; it was
  monotonic but did not preserve sensor sample time when delivery was delayed.
- Clear: the threshold epsilon was carried forward by the June 8, 2026 detector
  extraction and made the documented boundary inexact.

## Best Fix

Use an identity token for each resume and a fresh listener that captures that
token. The session owner accepts samples only after the same token completes a
successful registration, invalidates ownership before unregistering on pause,
and acquires duplicate-launch suppression in the same transition that accepts a
shake. Register the listener with the main-looper handler and debounce with the
sensor event's monotonic timestamp.

## Refactor Decision

A small pure-Java `ShakeSession` owner is justified because lifecycle,
registration, debounce, and launch suppression form one invariant that can be
tested without an Android SDK. A broader Android/Gradle modernization is not
part of this fix and would widen compatibility risk for the archived sample.

## Proof

- Portable detector and session tests run from `scripts/test-shake-detector.sh`.
- The source baseline checks listener tokens, main-looper registration, sensor
  event timestamps, narrow chooser recovery, Make root ownership, immutable CI
  actions, wrapper hashes, and the fixed production tree.
- Android lint, JUnit, debug assembly, and CodeQL remain required hosted gates.
- The wrapper JAR and distribution checksums are compared with Gradle-operated
  checksum sources.

## Risk

No emulator, physical accelerometer, live chooser, activity lifecycle harness,
or permission-rejecting share target has been executed. `DEVICE_VERIFICATION.md`
remains the authoritative matrix and every runtime row remains `not run` until
evidence is attached to the exact final commit.
