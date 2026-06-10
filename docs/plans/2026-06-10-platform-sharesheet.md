# Platform Sharesheet Migration

Status: Completed

## Goal

Restore a usable shake-to-compose flow without relying on retired Fabric and
Twitter Kit libraries, embedded credentials, or direct app-managed network
access.

## Requirements

- Remove Fabric and Twitter Kit plugins, repositories, dependencies, source,
  metadata, and ProGuard configuration.
- Remove credential placeholders and the `INTERNET` permission.
- Launch `ShakeActivity` directly from the app icon.
- Preserve the existing tested shake threshold, finite-input, overflow, and
  debounce behavior.
- Send the prefilled text through Android's user-mediated sharesheet.
- Guard missing share handlers through `ActivityNotFoundException`.
- Prevent overlapping chooser launches from repeated sensor events.
- Surface accelerometer listener registration failure.
- Enforce the migration in the SDK-free baseline.

## Implementation

- Replaced `TweetComposer` with `ACTION_SEND`, `EXTRA_TEXT`, and
  `Intent.createChooser`.
- Added launch exception handling and a chooser-in-progress guard reset when the
  activity resumes.
- Made sensor registration state explicit and only unregister an active
  listener.
- Declared accelerometer hardware optional and resource-backed the prefilled
  share text.
- Removed the dead login activity and its layout/menu resources.
- Removed the login screen's now-unused margin resources.
- Made `make check` location-independent, accepted either Android SDK variable,
  and hardened the hosted workflow runner and concurrency behavior.

## Verification

- `make check`
- `make -f /absolute/path/to/Makefile check` from outside the repository
- sharesheet, dependency-removal, permission, sensor, Makefile, and CI mutation
  checks
- `ANDROID_HOME=/path/to/android-sdk make check` (verified with API 22 lint,
  nine debug and nine release detector tests, and debug assembly)
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

The API-22 build gate passes with only the known `targetSdkVersion 22` lint
warning. Runtime chooser and sensor behavior still require an emulator or
physical device with an accelerometer and at least one compatible sharing
application.
