---
title: Share Security Exception Recovery
type: fix
status: planned
date: 2026-06-13
---

# Share Security Exception Recovery

## Status: Planned

## Problem Frame

`ShakeActivity.showShareComposer()` marks a share as in progress before asking
Android to launch the chooser. It resets that state when no matching activity
exists, but not when platform permission enforcement rejects the launch with a
`SecurityException`. Because that failure does not leave the activity, the flag
can remain set and silently suppress every later shake until another lifecycle
transition resets it.

Android documents `ActivityNotFoundException` as a runtime launch failure, and
activity launch permissions can also be enforced by the platform. The recovery
must cover those expected launch failures without catching every runtime error.

## Scope Boundaries

- Preserve the platform `ACTION_SEND` chooser, plain-text MIME type, packaged
  share text, chooser title, and user-confirmed sharing flow.
- Preserve the existing success-path ownership flag and resume reset.
- Do not add network access, credentials, direct posting, dependencies, or
  Android/Gradle modernization.
- Do not catch `Throwable`, `Error`, or all `RuntimeException` instances.

## Implementation Units

### U1: Recover From Permission Rejection

**File:** `app/src/main/java/gpj/tweetshake/ShakeActivity.java`

Handle `SecurityException` alongside `ActivityNotFoundException`, clear
`shareInProgress`, and show the existing generic share-unavailable feedback.

### U2: Protect The Recovery Contract

**File:** `scripts/check-baseline.sh`

Require both narrow launch-failure catches and identical state/feedback
recovery, reject broad exception catches, and require completed plan evidence.

### U3: Document And Verify

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
`docs/plans/2026-06-13-share-security-exception-recovery.md`

Record the recoverable platform launch boundary, SDK-backed validation, and
hostile mutation evidence.

## Test Scenarios

- A missing chooser activity clears the in-progress flag and reports the
  existing generic unavailable message.
- A platform `SecurityException` performs the same recovery.
- Successful chooser launch retains the flag until lifecycle resume.
- Removing either catch, either reset, or either feedback call fails checks.
- Replacing the narrow catches with `RuntimeException`, `Throwable`, or `Error`
  fails checks.

## Verification

Pending implementation and execution.

## Sources

- Android `ActivityNotFoundException` API:
  https://developer.android.com/reference/android/content/ActivityNotFoundException
- Android `Activity` API and activity launch permission notes:
  https://developer.android.com/reference/android/app/Activity
