# Android Tweet Shake Changes

## 2026-06-08

- Cleaned the Android lint gate by moving the logo bitmap to `drawable-nodpi`, routing display text through resources, and moving the screen background into the app theme.
- Added a narrow lint configuration for the legacy Android toolchain API-database and density-folder warnings.
- Documented and enforced the lint, unit test, and debug assemble verification path.
