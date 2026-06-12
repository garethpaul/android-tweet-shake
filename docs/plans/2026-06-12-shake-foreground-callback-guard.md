# Shake Foreground Callback Guard

Status: Completed

## Context

`onPause` unregisters the accelerometer listener, but an event already queued
for delivery can still reach `onSensorChanged`. When the pause was not caused by
the app's own chooser, that event can launch a new sharesheet while the activity
is no longer foreground-active.

## Changes

- Track whether the shake activity is currently resumed.
- Mark the activity inactive before unregistering the sensor listener.
- Ignore sensor callbacks unless the activity is resumed.
- Preserve existing chooser ownership, debounce, and unavailable-sensor logic.
- Extend the SDK-free baseline and README with the foreground callback contract.

## Verification

- `make check`
- Static mutation that removes the foreground callback guard
- `git diff --check`

The Android SDK and accelerometer runtime are unavailable on this host, so
queued callback ordering still requires device or emulator verification.
