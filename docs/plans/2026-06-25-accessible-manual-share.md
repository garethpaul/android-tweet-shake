# Accessible Manual Share

## Status: Completed

## Context

Tweet Shake declared the accelerometer optional and failed safely when sensor
hardware or listener registration was unavailable, but the screen exposed no
other way to complete its sole sharing flow. Android accessibility guidance
requires critical user flows to have alternatives to gesture-only actions.

## Design

Add an always-visible standard Android `Button` labeled `Share now`. A
conditional sensor-only fallback was rejected because users of TalkBack, Voice
Access, Switch Access, or limited-motion input need the alternative even on a
device with a working accelerometer. A custom action on the logo was rejected
because a standard button is visible, discoverable, and supplies built-in
accessibility semantics.

Anchor the button to the bottom of the screen and scale the logo inside the
space between the title and action. This keeps the accessible path visible on
short landscape displays instead of allowing the fixed-size artwork to push it
off-screen.

The button claims the same `ShakeSession` share lock used by an accepted shake.
Manual requests require a resumed activity but do not require accelerometer
registration. Both paths retain duplicate-launch suppression, the platform
chooser, and the existing launch-failure recovery.

## Work Completed

- Added `ShakeSession.requestShare()` as the shared lifecycle/launch claim.
- Routed accepted sensor shakes through that claim.
- Added portable tests for sensor-independent manual sharing, lifecycle and
  duplicate suppression, and failure retry.
- Added the standard button, resource-backed label, exact inventory updates,
  documentation, and a device-verification row.
- Added a layout regression contract for a bottom-anchored action and a logo
  that scales within the remaining portrait or landscape space.

## Verification

- `scripts/test-shake-detector.sh`
- `scripts/check-baseline.sh`
- `/usr/bin/make check`
- `git diff --check`

## Android Accessibility Evidence

- Android's Views guidance says users of TalkBack, Voice Access, or Switch
  Access need alternate ways to complete flows otherwise available only through gestures:
  https://developer.android.com/guide/topics/ui/accessibility/views/principles-views

## Scope Boundaries

- Share text, chooser ownership, exported activity input handling, permissions,
  dependencies, and network behavior are unchanged.
- No silent posting or background share action is introduced.
