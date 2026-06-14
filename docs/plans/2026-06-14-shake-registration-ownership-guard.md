# Shake Registration Ownership Guard

Status: In Progress

## Problem

The activity rejects queued accelerometer callbacks while paused and reports a
failed listener registration, but its callback gate only checks resumed state.
If re-registration fails, a callback queued from the previous registration can
still reach shake detection after the activity resumes without owning a current
sensor registration.

## Requirements

1. Process sensor callbacks only while the activity is resumed and the current
   listener registration succeeded.
2. Keep the guard before event-array reads and shake detection.
3. Preserve sensor registration, failure feedback, debounce behavior,
   chooser ownership, share recovery, lifecycle ordering, and privacy.
4. Add SDK-free source contracts and focused hostile mutations.

## Verification

- Run the baseline checker and complete SDK-backed `make check` from the
  repository root and an unrelated working directory.
- Reject focused mutations for omitted registration ownership, weakened OR
  logic, guard reordering, documentation drift, and stale plan status.
- Inspect the exact diff, generated artifacts, conflict markers, whitespace,
  and credential-shaped additions before committing.

## Scope Boundaries

- Do not change thresholds, debounce timing, sensor delay, chooser contents,
  permissions, dependencies, SDK levels, or user-visible strings.
- Do not claim emulator, physical-sensor, or chooser runtime verification.
- Do not merge or close stacked pull requests without explicit authorization.
