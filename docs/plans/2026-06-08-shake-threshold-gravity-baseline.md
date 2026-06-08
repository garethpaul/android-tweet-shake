# Shake Threshold Gravity Baseline

## Status: Completed

## Context

`android-tweet-shake` extracts accelerometer shake detection into
`ShakeDetector`, but the threshold comparison used squared acceleration divided
by squared gravity. The configured `SHAKE_THRESHOLD_GRAVITY = 2.0f` should mean
two times Earth gravity, not the square of that threshold.

## Objectives

- Preserve the legacy 200 ms debounce interval.
- Interpret the configured threshold as acceleration magnitude in gravity units.
- Keep 2.0g input triggering a shake.
- Reject 1.9g input as below the configured 2.0g threshold.
- Expose the SDK-free check through `make check`.

## Work Completed

- Updated `ShakeDetector` to compare acceleration magnitude divided by
  `GRAVITY_EARTH`.
- Added regression coverage for 1.9g movement below the configured threshold.
- Added `make check` as the root SDK-free verification wrapper.
- Updated README, VISION, CHANGES, and the baseline checker.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`

## Follow-Up Candidates

- Verify shake behavior on real hardware before changing the threshold again.
- Replace deprecated Fabric/Twitter SDK dependencies in a dedicated migration.
