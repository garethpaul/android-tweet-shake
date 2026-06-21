# Android Tweet Shake System Make Boundary

Status: Completed

## Problem

Hosted and documented verification selected `make` through `PATH`, while the
Makefile allowed startup files, unsafe modes, later Makefiles, shell changes,
and SDK or Gradle replacement to redirect the gate.
Startup makefiles can run parse-time Make functions before the repository Makefile rejects them.

## Work Completed

- Bound GitHub Actions and contributor verification to `/usr/bin/make`.
- Bound `/bin/sh`, the canonical root, SDK selection, and literal Gradle path
  against ordinary caller assignments for the checked-in Makefile invocation.
- Rejected replaced Makefile lists, raw Make-syntax paths, later single-colon
  recipe replacement, and non-executing or error-ignoring modes for the
  checked-in Makefile invocation.
- Recorded caller-supplied later makefiles, target-specific override shell
  assignments, double-colon public recipes, and startup parse-time Make code
  as outside the local Make trust boundary.
- Recorded that Make syntax in an explicit `-f` path is version-sensitive before the
  repository Makefile loads; literal `$(` checkout paths must be invoked from
  inside the checkout without an explicit Makefile path.
- Added `scripts/test-makefile-root.sh` to `/usr/bin/make check`.

## Verification

- Run `/usr/bin/make check` from the repository root and an external directory.
- Run the SDK-free authority and shake-detector host harnesses.
- Let the hosted API 22/Java 8 job exercise Gradle on the exact head.
- Do not treat caller-supplied extra `-f` files or startup files as trusted
  validation; the harness reproduces those caller programs as outside-boundary
  cases.

## Scope Boundary

Application behavior, sensor handling, share dispatch, dependencies,
permissions, and device data are unchanged. Explicit literal SDK and Gradle
paths remain supported caller authority.
Caller-supplied later makefiles, including target-specific override SHELL/.SHELLFLAGS assignments and double-colon public recipes, are outside the local Make trust boundary.
Hosted GitHub Actions remains authoritative because it invokes the checked-in
workflow command without caller-supplied extra makefiles or startup files.
