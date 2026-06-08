# Android Tweet Shake

Legacy Android sample that signs in with Twitter and opens a tweet composer when
the user shakes the phone.

## Toolchain

This project currently uses the original Android build stack:

- Gradle wrapper 2.2.1
- Android Gradle Plugin 1.2.3
- Fabric Gradle Plugin 1.14.4
- compile SDK 22 / target SDK 22
- Android build-tools 24.0.3

Gradle resolves the Android plugin from HTTPS Maven Central and the legacy
Twitter/Fabric SDK from the Fabric Maven repository.

Configure an Android SDK path before running Gradle:

```sh
export ANDROID_HOME=/path/to/android-sdk
```

or create an untracked `local.properties` file:

```properties
sdk.dir=/path/to/android-sdk
```

## Verify

Run the SDK-free source baseline check first:

```sh
scripts/check-baseline.sh
```

Then run Gradle after Android SDK configuration is available:

```sh
ANDROID_HOME=/home/gjones/android-sdk ./gradlew tasks --no-daemon
ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon
ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon
```

## Credential Policy

Committed Twitter and Fabric credential placeholders must stay empty. Real keys,
tokens, signing files, and machine-local Fabric properties belong outside Git.

## Modernization Notes

The current baseline initializes and unregisters the accelerometer listener
through the activity lifecycle, tests the shake threshold/debounce logic in a
small detector, pins compatible legacy build tooling, disables Crashlytics
processing for empty-key local builds, and removes generated IDE metadata from
version control. Future work should replace Fabric/Twitter Kit with maintained
APIs if the app is revived, add hardware or emulator verification for shake
behavior, and modernize SDK/dependency levels in a dedicated pass.
