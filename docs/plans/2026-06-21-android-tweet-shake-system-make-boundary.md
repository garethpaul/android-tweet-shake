# Android Tweet Shake System Make Boundary

Status: Completed

## Problem

Hosted and documented verification selected `make` through `PATH`, while the
Makefile allowed startup files, unsafe modes, later Makefiles, shell changes,
and SDK or Gradle replacement to redirect the gate.

## Work Completed

- Bound GitHub Actions and contributor verification to `/usr/bin/make`.
- Froze `/bin/sh`, the canonical root, SDK selection, and literal Gradle path.
- Rejected startup files, replaced Makefile lists, raw Make-syntax paths, later
  Makefiles, and non-executing or error-ignoring modes.
- Added `scripts/test-makefile-root.sh` to `/usr/bin/make check`.

## Verification

- Run `/usr/bin/make check` from the repository root and an external directory.
- Run the SDK-free authority and shake-detector host harnesses.
- Let the hosted API 22/Java 8 job exercise Gradle on the exact head.

## Scope Boundary

Application behavior, sensor handling, share dispatch, dependencies,
permissions, and device data are unchanged. Explicit literal SDK and Gradle
paths remain supported caller authority.
