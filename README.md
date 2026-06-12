# android-tweet-shake

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/android-tweet-shake` is an Android application or sample. Android app - shake to tweet

This legacy Android sample opens Android's sharesheet with prefilled text when
the user shakes the phone.

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: Java (4), shell (1).

## Repository Contents

- `README.md` - project overview and local usage notes
- `build.gradle` - Android or Gradle build configuration
- `app` - source or example code
- `docs` - source or example code
- `gradle` - source or example code
- `gradlew` - Android or Gradle build configuration
- `scripts` - source or example code
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: app, docs, gradle, scripts
- Dependency and build manifests: build.gradle, gradlew
- Entry points or build surfaces: Gradle build files
- Test-looking files: app/src/androidTest/java/gpj/tweetshake/ApplicationTest.java, app/src/test/java/gpj/tweetshake/ShakeDetectorTest.java

## Getting Started

### Prerequisites

- Git
- Android Studio or a compatible Android SDK
- Gradle or the checked-in Gradle wrapper when present

### Setup

```bash
git clone https://github.com/garethpaul/android-tweet-shake.git
cd android-tweet-shake
make check
scripts/check-baseline.sh
./gradlew lint --no-daemon
./gradlew test --no-daemon
./gradlew assembleDebug --no-daemon
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- Use Android Studio to open the project or run `./gradlew assembleDebug` when the Android SDK is configured.

## Testing and Verification

- `make lint` - runs the SDK-free baseline and Gradle lint when the Android SDK is configured.
- `make test` - runs Gradle tests when the Android SDK is configured.
- `make build` - runs debug assembly when the Android SDK is configured.
- `make check` - runs the aggregate lint, test, and build gates.
- `scripts/check-baseline.sh` - runs SDK-free source baseline checks.
- GitHub Actions runs the SDK-free `make check` baseline for pushes and pull
  requests on Ubuntu 24.04 and cancels superseded runs.
- The workflow uses immutable checkout, read-only permissions, and a bounded
  timeout; local Gradle checks accept `ANDROID_HOME` or `ANDROID_SDK_ROOT`.
- The baseline protects threshold units, finite sensor handling, debounce
  behavior, Android sharesheet dispatch, sensor lifecycle handling, and legacy
  build guardrails.
- Shake debounce uses Android's monotonic elapsed realtime clock so wall-clock
  changes do not affect shake timing.
- Overflowed acceleration magnitude is rejected before shake debounce so
  implausibly large finite sensor values cannot trigger composition.
- Missing shake sensor support shows generic unavailable feedback instead of
  failing silently.
- Failure to register the accelerometer listener is also surfaced to the user.
- Queued accelerometer callbacks are ignored after the activity pauses so a
  stale sensor event cannot launch a sharesheet from the background.
- Sharesheet launch follows Android's launch-and-catch pattern without a
  package-visibility preflight and rejects duplicate sensor events while a
  chooser is already opening.
- `./gradlew lint --no-daemon`, `./gradlew test --no-daemon`, and `./gradlew assembleDebug --no-daemon` when the Android SDK is configured.

The canonical GitHub Actions workflow installs Android API 22 and build-tools
24.0.3, selects Java 8, and runs the complete `make check` gate. The legacy
target SDK produces one documented `OldTargetApi` compatibility warning.

When the required SDK or runtime is unavailable locally, use static checks and source review first, then rely on the hosted matching platform toolchain.

## Configuration and Secrets

- The app has no API key, OAuth credential, token, Fabric metadata, or signing
  configuration requirement.
- Sharing is delegated to an app chosen by the user through the Android
  sharesheet.

## Security and Privacy Notes

- The app does not request the `INTERNET` permission and does not authenticate
  directly with a social network.
- The selected sharing app owns any account, network, and posting behavior; the
  sample only supplies prefilled text after an explicit shake gesture.
- Review changes touching mobile permissions or privacy-sensitive device data; examples from the scan include app/src/main/AndroidManifest.xml, app/src/main/java/gpj/tweetshake/ShakeActivity.java, docs/plans/2026-06-08-tweet-shake-sensor-build-baseline.md, gradlew, and 1 more.
- Review changes touching the accelerometer and outgoing share intents in
  `ShakeActivity`; malformed sensor data and sharesheet launch failures must
  remain guarded.
- Review changes touching database, model, or persistence code; examples from the scan include docs/plans/2026-06-08-tweet-shake-sensor-build-baseline.md.

## Maintenance Notes

- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.
- The current baseline initializes and unregisters the accelerometer listener
  through the activity lifecycle, tests the shake threshold/debounce logic in a
  small detector, compares acceleration magnitude against the configured 2.0g
  threshold, rejects non-finite accelerometer values without consuming debounce
  state, rejects overflowed acceleration magnitude before debounce, uses
  monotonic elapsed realtime for shake debounce timing, keeps the resource lint
  gate clean, pins compatible legacy build tooling, and removes generated IDE
  metadata from version control. Missing accelerometer support, listener
  registration failure, and sharesheet launch failure surface generic messages.
- Future work should add hardware or emulator verification for shake and
  chooser behavior, then modernize SDK/dependency levels in a dedicated pass.
- Hosted pull requests and default-branch pushes run lint, JVM tests, and debug
  assembly with Android API 22, build-tools 24.0.3, and Java 8.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `CHANGES.md` for the maintenance history.
- See `docs/plans/2026-06-08-shake-threshold-gravity-baseline.md` for the
  shake-threshold gravity baseline.
- See `docs/plans/2026-06-08-shake-finite-acceleration-baseline.md` for the
  non-finite sensor input baseline.
- See `docs/plans/2026-06-09-shake-invalid-input-debounce-baseline.md` for the
  invalid sensor debounce regression coverage.
- See `docs/plans/2026-06-09-shake-monotonic-debounce-time.md` for the
  monotonic shake debounce timing contract.
- See `docs/plans/2026-06-09-shake-magnitude-overflow-guard.md` for the
  overflowed acceleration magnitude guard.
- See `docs/plans/2026-06-09-tweet-shake-make-gate-targets.md` for the root
  lint, test, and build gate contract.
- See `docs/plans/2026-06-10-ci-baseline.md` for the hosted GitHub Actions
  baseline.
- See `docs/plans/2026-06-12-hosted-android-verification.md` for the complete
  hosted Android lint, test, and build gate.
- See `docs/plans/2026-06-10-platform-sharesheet.md` for the migration away
  from retired Fabric and Twitter Kit dependencies.

Earlier login and credential plans remain in `docs/plans/` as historical
context for the retired integration.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
