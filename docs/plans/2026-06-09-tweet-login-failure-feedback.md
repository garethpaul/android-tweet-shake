---
title: Tweet Login Failure Feedback
type: privacy
status: completed
date: 2026-06-09
---

# Tweet Login Failure Feedback

## Problem Frame

The Twitter login callback handled failures with a placeholder comment. That
left users with no visible feedback and made future changes more likely to log
Twitter exception or session details while debugging auth failures.

## Scope Boundaries

- Preserve the existing Twitter Kit login flow and shake-to-compose behavior.
- Keep committed Twitter and Fabric credential placeholders empty.
- Do not add real credentials, new dependencies, or migration work for the
  deprecated Fabric/Twitter SDK.
- Keep verification SDK-free except for the existing Gradle gate.

## Implementation Units

### U1: Add Generic Failure Feedback

Files:

- Modify `app/src/main/java/gpj/tweetshake/MainActivity.java`
- Modify `app/src/main/res/values/strings.xml`

Approach:

- Replace the placeholder failure callback with a short generic Toast.
- Store the message in string resources.
- Do not print Twitter exception text or session details.

### U2: Guard The Auth Failure Contract

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Fail if the placeholder failure comment returns.
- Fail if the failure callback stops using the resource-backed message.
- Fail if obvious exception logging is introduced in `MainActivity`.

### U3: Document The Behavior

Files:

- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Record that login failures are user-visible and generic.
- Keep the privacy rule explicit for future auth work.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `./gradlew lint test assembleDebug --no-daemon`
- `git diff --check`
