# Android Tweet Shake Changes

## 2026-06-09

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
