# CI Baseline

Status: Completed

## Context

The repository had local SDK-free and optional Gradle verification gates for
the legacy Android sample, but no hosted workflow ran the baseline for pushes
and pull requests.

## Changes

- Added a pinned, read-only GitHub Actions workflow that runs the SDK-free
  `make check` baseline with a five-minute timeout, manual dispatch, and no
  persisted checkout credentials.
- Removed the maintainer-specific default SDK path; local Gradle checks require
  explicit SDK configuration.
- Extended the shell baseline to require a byte-exact canonical workflow and
  reject hidden or additional workflow files.
- Added repository-wide owner coverage and locked the fixed legacy manifest,
  source inventory, Gradle configuration, and wrapper executables.

## Verification

- `make check`
