# android-tweet-shake

## Overview

`garethpaul/android-tweet-shake` is an Android application or sample. Android app - shake to tweet

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: Java (5), shell (1).

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
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- Use Android Studio to open the project or run `./gradlew assembleDebug` when the Android SDK is configured.

## Testing and Verification

- `./gradlew test` or Android Studio's test runner when the SDK is configured

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- Detected references to Twitter. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.

## Security and Privacy Notes

- Review changes touching authentication or token handling; examples from the scan include docs/plans/2026-06-08-tweet-shake-lint-resource-baseline.md, docs/plans/2026-06-08-tweet-shake-sensor-build-baseline.md.
- Review changes touching external API calls or credential-adjacent configuration; examples from the scan include app/build.gradle, app/src/main/AndroidManifest.xml, app/src/main/java/gpj/tweetshake/MainActivity.java, app/src/main/java/gpj/tweetshake/ShakeActivity.java, and 5 more.
- Review changes touching network requests, sockets, or service endpoints; examples from the scan include app/build.gradle, app/src/androidTest/java/gpj/tweetshake/ApplicationTest.java, app/src/main/AndroidManifest.xml, app/src/main/res/layout/activity_main.xml, and 6 more.
- Review changes touching mobile permissions or privacy-sensitive device data; examples from the scan include app/src/main/AndroidManifest.xml, app/src/main/java/gpj/tweetshake/ShakeActivity.java, docs/plans/2026-06-08-tweet-shake-sensor-build-baseline.md, gradlew, and 1 more.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include app/lint.xml, app/src/main/AndroidManifest.xml, app/src/main/java/gpj/tweetshake/MainActivity.java, app/src/main/java/gpj/tweetshake/ShakeActivity.java, and 5 more.
- Review changes touching database, model, or persistence code; examples from the scan include docs/plans/2026-06-08-tweet-shake-sensor-build-baseline.md.

## Maintenance Notes

- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.

## Existing Project Notes

Prior README summary:

> Android Tweet Shake <!-- README-OVERVIEW-IMAGE --> Legacy Android sample that signs in with Twitter and opens a tweet composer when the user shakes the phone. Toolchain This project currently uses the original Android build stack: - Gradle wrapper 2.2.1 - Android Gradle Plugin 1.2.3

