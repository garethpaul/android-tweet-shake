# CI Baseline

Status: Completed

## Context

The repository had local SDK-free and optional Gradle verification gates for
the legacy Android sample, but no hosted workflow ran the baseline for pushes
and pull requests.

## Changes

- Added a pinned, read-only GitHub Actions workflow with manual dispatch and no
  persisted checkout credentials. It now installs Android API 22 and
  build-tools 24.0.3, selects Java 8, and runs the complete `make check` gate
  with a 15-minute timeout.
- Removed the maintainer-specific default SDK path; local Gradle checks require
  explicit SDK configuration.
- Extended the shell baseline to require a byte-exact canonical workflow and
  reject hidden or additional workflow files.
- Added repository-wide owner coverage and locked the fixed legacy manifest,
  source inventory, Gradle configuration, and wrapper executables.
- Recorded the full production app-tree inventory and hashes, including Java,
  XML resources, and images, to reject renamed or appended packaged payloads.
- Rejected Gradle `buildSrc` so implicit plugin code cannot bypass the explicit
  configuration inventory.

## Verification

- SDK-backed `make check`
- Exact-head pull-request workflow
