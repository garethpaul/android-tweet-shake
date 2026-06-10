# CI Baseline

Status: Completed

## Context

The repository had local SDK-free and optional Gradle verification gates for
the legacy Android sample, but no hosted workflow ran the baseline for pushes
and pull requests.

## Changes

- Added a pinned, read-only GitHub Actions workflow that runs the SDK-free
  `make check` baseline with a five-minute timeout and manual dispatch.
- Removed the maintainer-specific default SDK path; local Gradle checks require
  explicit SDK configuration.
- Extended the shell baseline and docs so the hosted CI path stays visible.

## Verification

- `make check`
