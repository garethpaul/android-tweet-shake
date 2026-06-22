# Android Tweet Shake Changes

## 2026-06-21

- Bound hosted and contributor verification to `/usr/bin/make` and added an
  executable authority harness for shell, root, SDK, Gradle, startup-file,
  later-Makefile, and unsafe-mode boundaries.
- Documented caller-supplied later makefiles and startup parse-time Make code as outside the local Make trust boundary.
- Documented version-specific explicit `-f` Make-syntax paths as pre-load caller authority.
- Covered GNU Make 4.2.1's explicit `-f` pre-load behavior in the portable authority regression harness.

## 2026-06-19

- Replaced lifecycle booleans shared by one long-lived sensor listener with a
  tested per-resume registration token, fresh listener identity, main-looper
  delivery, and pause-before-unregister invalidation.
- Moved debounce input from callback time to the sensor event's monotonic
  boot-time timestamp, and made duplicate share suppression part of the
  session's accepted-shake transition.
- Added portable lifecycle/session tests for pending, failed, paused, stale,
  and replaced registrations plus launch failure and resume recovery.
- Enforced the exact 2.0g threshold boundary instead of accepting the adjacent
  lower float through an epsilon, with host and JUnit regressions.
- Updated the test-only JUnit dependency from vulnerable 4.12 to 4.13.2.
- Verified the Gradle wrapper JAR against Gradle's official 8.14.x checksum
  registry and the Gradle 2.2.1 distribution against its official checksum.

## 2026-06-14

- Added an exact-commit Tweet Shake device verification matrix for sensor
  availability, threshold and debounce behavior, registration ownership,
  lifecycle callbacks, chooser suppression and failure recovery, and privacy-safe evidence, with every runtime row explicitly unexecuted.
- Added portable host regression tests for shake detection so core behavior is
  exercised even when the Android SDK is unavailable.
- Required current successful accelerometer registration, in addition to
  resumed lifecycle state, before queued callbacks can trigger shake handling.

## 2026-06-13

- Recovered from missing activities and permission-rejected chooser launches
  through one state-reset and generic-feedback path.
- Made first-shake debounce state explicit so maximum elapsed-realtime values do
  not overflow timestamp arithmetic.
- Rejected negative and backward debounce timestamps without replacing the last
  accepted shake time.

## 2026-06-12

- Regenerated the wrapper bootstrap with official Gradle 8.14.5 tooling while
  retaining Gradle 2.2.1, and pinned exact distribution and artifact hashes.
- Ignored queued accelerometer callbacks after activity pause so stale sensor
  events cannot launch the sharesheet from the background.

## 2026-06-10

- Disabled persisted checkout credentials and added repository-wide ownership
  for CI, Gradle, verification, and Android app trust boundaries.
- Locked the sharesheet app's workflow, manifest, source inventory, Gradle
  inputs, and wrapper hashes against hidden executable build inputs.
- Made the complete production app tree byte-exact so additional outbound
  intents, resources, renamed payloads, and image polyglots cannot land unseen.
- Rejected Gradle `buildSrc` plugin shadowing as an implicit executable build
  input outside the fixed legacy configuration.
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
