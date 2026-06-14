# Android Tweet Shake Make Root Override Protection

Status: Completed

## Problem

The Makefile derives its repository root from its own location, but GNU Make
command-line variables override an ordinary assignment. A hostile `ROOT` value
can redirect the baseline checker and all conditional Gradle gates away from
the reviewed checkout.

## Requirements

1. Protect the Makefile-derived root with GNU Make's `override` directive.
2. Preserve configurable SDK and Gradle commands, every target, skip condition,
   and existing lint/test/build behavior.
3. Require exact protected-root and tool semantics plus complete rooted
   baseline and Gradle command contracts.
4. Pass local, external-directory, and hostile-root `make check` gates.
5. Reject focused root, tool, path, environment, task, and completed-plan
   mutations.

## Verification

- Run shell syntax and the dependency-free baseline checker first.
- Run bounded local, external-directory, and hostile command-line `ROOT`
  `make check` gates, recording whether SDK-backed tasks execute or skip.
- Run focused mutations plus workflow YAML, Android XML, SVG XML, artifact,
  conflict-marker, whitespace, and changed-line credential audits.

## Scope Boundaries

- Do not change shake detection, share behavior, exception recovery,
  permissions, dependencies, workflows, Android sources, or resources.
- Do not weaken wrapper or application safety contracts.
- Do not create SDK placeholders or claim emulator/device verification.
- Do not merge or close any pull request without explicit owner authorization.

## Work Completed

- Protected the Makefile-derived root while preserving SDK/Gradle
  configurability, every target, task, and skip condition.
- Added exact contracts for variables, rooted baseline/Gradle commands,
  verification ordering, and completed plan evidence.

## Verification Results

- The focused baseline checker and shell syntax checks passed.
- Local, external-directory, and hostile command-line `ROOT` `make check`
  gates passed while remaining anchored to this checkout.
- No Android SDK was configured, so Gradle lint, tests, and assembly truthfully
  skipped in all three contexts; no SDK-backed or device result is claimed.
- All twelve root, override, path, environment, task, ordering, and completed
  plan mutations were rejected.
- Workflow YAML, Android XML, SVG XML, shell syntax, conflict-marker,
  whitespace, artifact, exact-diff, and credential audits passed; only the
  three intended files changed and no generated artifacts remained.
