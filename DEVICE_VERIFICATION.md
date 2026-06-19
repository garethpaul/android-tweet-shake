# Android Tweet Shake Device Verification Matrix

Use this matrix only for an exact implementation commit. Record the commit SHA and pull request
before testing so accelerometer, lifecycle, and chooser evidence cannot be
transferred to a different detector implementation.

## Evidence Rules

- Use synthetic share text that contains no personal, account, location, or
  business-sensitive information.
- Record the Android SDK, API level, device or emulator class, accelerometer
  availability, test motion method, result, and evidence identifier.
- Do not include device identifiers, sensor dumps, account names, selected share
  accounts, unrelated notifications, or raw diagnostic output.
- Store durable evidence outside git. Link only a sanitized run, screenshot, or
  short log excerpt by stable identifier.
- Record each result as `pass`, `fail`, `blocked`, or `not run`, with an owner
  and follow-up for every result other than `pass`.
- Do not convert `not run` into passing evidence.

## Run Identity

| Field | Value |
| --- | --- |
| Commit SHA | `not run` |
| Pull request | `not run` |
| Android SDK / API | `not run` |
| Device or emulator | `not run` |
| Accelerometer / sensor rate | `not run` |
| Share targets available | `not run` |
| Synthetic share text | `not run` |
| Evidence location | `not run` |

## Verification Matrix

| Scenario | Expected evidence | Result | Evidence |
| --- | --- | --- | --- |
| Accelerometer unavailable | The activity remains usable and shows generic unavailable feedback without crashing. | `not run` | `not run` |
| Listener registration failure | Failed registration prevents ownership and shows generic unavailable feedback. | `not run` | `not run` |
| Below-threshold motion | Ordinary movement does not open the chooser or consume accepted-shake state. | `not run` | `not run` |
| Threshold shake | A qualifying physical shake opens exactly one user-confirmed ACTION_SEND chooser. | `not run` | `not run` |
| Rapid repeated shakes | Events inside the cooldown or while a chooser is opening do not launch duplicates. | `not run` | `not run` |
| Debounce boundary | A shake at the configured cooldown boundary is accepted without timestamp overflow. | `not run` | `not run` |
| Pause before callback | A queued sensor callback after pause cannot open a chooser. | `not run` | `not run` |
| Resume registration | Resume establishes fresh successful registration ownership before shake handling. | `not run` | `not run` |
| Chooser already opening | Duplicate suppression remains active until the chooser flow returns to the activity. | `not run` | `not run` |
| Chooser return | Returning or cancelling permits a later qualifying shake to open a new chooser. | `not run` | `not run` |
| Missing share activity | No-handler failure clears suppression and shows generic unavailable feedback. | `not run` | `not run` |
| Permission-rejected launch | Security rejection clears suppression and uses the same generic feedback. | `not run` | `not run` |
| Process relaunch | Relaunch starts without stale registration, debounce, chooser, account, or draft state. | `not run` | `not run` |

## Current Status

No Android SDK, emulator, accelerometer injection, physical device, share
target, or live chooser scenario was executed for this checklist. Treat every Android, accelerometer, chooser, and lifecycle row as unexecuted
until evidence is attached to the exact commit.
