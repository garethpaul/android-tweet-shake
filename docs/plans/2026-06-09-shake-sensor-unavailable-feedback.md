# Shake Sensor Unavailable Feedback

status: completed

## Context

`ShakeActivity` already skips listener registration when the sensor service or
accelerometer is missing, but that path was silent. On tablets, emulators, or
devices without accelerometer support, the user could reach the shake screen
and receive no explanation that shaking cannot be detected.

## Plan

- Add a generic resource-backed unavailable message for missing shake sensors.
- Show the message when `SensorManager` is unavailable or when no accelerometer
  hardware is returned.
- Preserve the existing null-guarded listener registration and unregister path.
- Extend the SDK-free baseline so the unavailable state and plan remain
  documented.

## Verification

- `scripts/check-baseline.sh`
- `git diff --check`
- `make check`
