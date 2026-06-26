# Sensor Registration Security Recovery

Status: Completed

## Problem

`ShakeActivity.onResume()` handled the documented boolean failure from
`SensorManager.registerListener`, but a platform `SecurityException` escaped
before `ShakeSession.completeRegistration` and generic unavailable feedback.
That crashed the activity even though manual sharing does not require sensor
ownership.

## Scope

- Catch only `SecurityException` around accelerometer listener registration.
- Convert the rejection to `registered = false` so the existing ownership,
  listener cleanup, and generic feedback path remains authoritative.
- Preserve sensor parameters, main-looper delivery, per-resume identity,
  manual sharing, chooser behavior, and all detector/debounce logic.
- Do not log or display the exception and do not catch broad runtime failures.

## Verification

- Add a failing SDK-free source contract before changing the activity.
- Run `/usr/bin/make check` with the portable detector/session suites.
- Run focused hostile mutations removing the catch, broadening it, skipping
  failed ownership, retaining the listener, or suppressing feedback.
- Require exact-head hosted Java 8/API 22 lint, tests, debug assembly, and
  CodeQL before merge.

## Boundary

This does not claim a device or emulator reproduced registration rejection.
The exact-commit device matrix remains `not run`. The change adds no permission,
networking, credential, destination-package query, background share, retry, or
dependency behavior.
