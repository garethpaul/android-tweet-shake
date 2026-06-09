# Tweet Login Button Guard

## Status: Completed

## Context

`MainActivity` assumed `R.id.twitter_login_button` was always present and
forwarded activity results to it unconditionally. A legacy layout mismatch or
resource regression could therefore crash startup or result handling before the
user saw any useful feedback.

## Objectives

- Preserve the existing Twitter login success and failure behavior.
- Show a generic resource-backed message if the login button is unavailable.
- Avoid forwarding activity results to a missing login button.
- Keep the behavior covered by the SDK-free baseline checker.

## Work Completed

- Guarded `findViewById(R.id.twitter_login_button)` before registering the
  Twitter callback.
- Added `twitter_login_unavailable` to string resources.
- Guarded `onActivityResult()` forwarding behind a non-null login button.
- Extended `scripts/check-baseline.sh` to require the guard and resource.
- Updated README, VISION, and CHANGES.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Gradle lint, tests, and debug assembly run when a compatible Android SDK is
configured.
