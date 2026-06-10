# Sharesheet Launch Compatibility

Status: Completed

## Context

The shake flow queried `resolveActivity()` before starting Android's chooser.
That query is redundant for this API-22 target and becomes a compatibility
hazard when the target SDK is modernized: package-visibility rules can filter
query results even though an app may still launch another activity through an
implicit intent. Android's documented chooser pattern is to call
`startActivity()` and catch `ActivityNotFoundException`.

References:

- https://developer.android.com/training/basics/intents/sending
- https://developer.android.com/training/package-visibility/automatic

## Changes

- Removed the `resolveActivity()` preflight from sharesheet dispatch.
- Preserved the explicit chooser, duplicate-launch guard, and
  `ActivityNotFoundException` fallback.
- Extended the SDK-free baseline to reject package-query preflights and require
  this completed plan.
- Updated project documentation to describe launch-and-catch behavior.

## Verification

- `make check`
- Static mutations for a restored `resolveActivity()` query and removed launch
  exception handling
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

The Android SDK is unavailable on this host. Runtime chooser behavior still
requires verification on a device or emulator, especially after a future
target-SDK upgrade.
