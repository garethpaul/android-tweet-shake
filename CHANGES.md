# Android Tweet Shake Changes

## 2026-06-10

- Disabled persisted checkout credentials and added repository-wide ownership
  for CI, Gradle, verification, and Android app trust boundaries.
- Locked the sharesheet app's workflow, manifest, source inventory, Gradle
  inputs, and wrapper hashes against hidden executable build inputs.
- Replaced retired Fabric/Twitter Kit login and composer integration with the
  Android sharesheet, removed credential placeholders and the network
  permission, and made the shake screen the launcher.
- Guarded sharesheet launch failures, duplicate chooser launches, and failed
  sensor listener registration while preserving the tested shake detector.
- Removed the redundant share-handler query so future target-SDK package
  visibility filtering cannot incorrectly suppress chooser launch.
- Declared accelerometer hardware optional and moved prefilled share copy into
  string resources.
- Removed login-screen resources that became unused with the launcher migration.
- Made root checks location-independent, accepted either Android SDK variable,
  and pinned CI to Ubuntu 24.04 with superseded-run cancellation.
- Added a pinned, read-only GitHub Actions workflow that runs the SDK-free
  `make check` baseline with a bounded timeout and manual dispatch.
- Extended the shell baseline and docs to require the hosted CI verification
  path.
- Removed the maintainer-specific Android SDK path from the Makefile.

## 2026-06-09

- Added generic unavailable feedback when the shake screen cannot access an
  accelerometer.
- Rejected overflowed acceleration magnitude before shake threshold and
  debounce handling.
- Routed shake debounce timing through Android's monotonic elapsed realtime
  clock instead of wall-clock time.
- Guarded Twitter/Fabric initialization when committed credential placeholders
  are empty, with generic unavailable feedback for local builds.
- Added root `make lint`, `make test`, and `make build` gates around the
  existing SDK-free and Gradle verification commands.

## 2026-06-08

- Corrected shake threshold evaluation to compare acceleration magnitude in g
  units rather than squared magnitude, with a regression test for 1.9g input.
- Guarded shake detection against non-finite accelerometer values with
  NaN/infinity unit coverage.
- Added coverage that invalid accelerometer samples do not consume the debounce
  window before a valid shake.
- Added `make check` as the SDK-free verification wrapper.
- Cleaned the Android lint gate by moving the logo bitmap to `drawable-nodpi`, routing display text through resources, and moving the screen background into the app theme.
- Added a narrow lint configuration for the legacy Android toolchain API-database and density-folder warnings.
- Documented and enforced the lint, unit test, and debug assemble verification path.
- Added generic, resource-backed Twitter login failure feedback without logging
  exception details.
- Guarded the Twitter login button lookup and activity-result forwarding so
  layout regressions produce generic feedback instead of crashes.
