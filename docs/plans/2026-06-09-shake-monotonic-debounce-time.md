# Shake Monotonic Debounce Time

## Status: Completed

## Context

`ShakeActivity` passed `System.currentTimeMillis()` into `ShakeDetector` for
debounce timing. Wall-clock time can jump when the user, network, or system time
changes, which can make debounce behavior unexpectedly stretch or shrink. Sensor
debounce should use monotonic elapsed time.

## Objectives

- Preserve the existing `ShakeDetector` threshold and debounce behavior.
- Keep detector tests independent from Android runtime APIs.
- Route Android sensor events into the detector with monotonic elapsed realtime.
- Add an SDK-free source contract against wall-clock debounce timing.

## Work Completed

- Imported `android.os.SystemClock` in `ShakeActivity`.
- Replaced `System.currentTimeMillis()` with `SystemClock.elapsedRealtime()` for
  shake debounce timestamps.
- Extended `scripts/check-baseline.sh`.
- Updated README, VISION, and CHANGES.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

## Follow-Up Candidates

- Add Android sensor-loop instrumentation after the legacy stack is modernized.
- Review whether tweet-composer launch should add an additional UI-level
  cooldown once hardware testing is available.
