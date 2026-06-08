---
title: Android Tweet Shake Sensor and Build Baseline
type: fix
status: completed
date: 2026-06-08
---

# Android Tweet Shake Sensor and Build Baseline

## Summary

Raise the baseline for the legacy Tweet Shake app by fixing accelerometer
listener initialization/lifecycle behavior, extracting tested shake debounce
logic, pinning legacy build tooling, preserving empty credential placeholders,
removing generated IDE metadata, and adding a source check for future drift.

---

## Problem Frame

`ShakeActivity` registers a sensor listener before initializing
`sensorManager`, which crashes as soon as the activity opens. It also never
unregisters the listener and never updates the shake debounce timestamp after
showing the tweet composer. The Gradle build uses a floating Fabric plugin
dependency that resolves to an incompatible plugin on this host, build-tools
22.0.1 depends on a failing 32-bit `aapt`, root repositories still use JCenter,
Fabric resource processing fails when credential placeholders are intentionally
empty, and Android Studio metadata is tracked.

---

## Requirements

- R1. Opening `ShakeActivity` must not throw because `SensorManager` is null.
- R2. The accelerometer listener must register and unregister with the activity lifecycle.
- R3. Shake compose events must update debounce state so repeated movement is suppressed during the cooldown.
- R4. Shake threshold and debounce behavior must have local unit coverage.
- R5. The legacy Fabric plugin and Android build-tools versions must be pinned to locally buildable versions.
- R6. Root build repositories must use explicit HTTPS Maven Central instead of JCenter.
- R7. Crashlytics/Fabric resource processing must be disabled for local empty-key builds.
- R8. Twitter/Fabric credential placeholders must remain empty in committed files.
- R9. Generated `.idea` and `.iml` metadata must not be tracked.
- R10. The repository must include README verification notes and an SDK-free baseline check.

---

## Key Technical Decisions

- **Move sensor registration to lifecycle methods:** `onCreate` initializes
  references, `onResume` registers, and `onPause` unregisters.
- **Preserve shake threshold behavior:** Keep the existing acceleration ratio
  threshold at `2.0f`, but name it and keep the 200 ms debounce interval explicit.
- **Extract shake detection:** Moving threshold/debounce math to `ShakeDetector`
  makes the behavior testable without Android sensor fixtures.
- **Pin Fabric Gradle Plugin 1.14.4:** The floating `1.+` resolves to 1.31.2,
  which is incompatible with Android Gradle Plugin 1.2.3 in this project.
- **Pin build-tools 24.0.3:** The installed 24.0.3 tools provide a 64-bit
  `aapt` that works on this host while keeping compile/target SDK 22.
- **Disable Crashlytics processing for placeholder builds:** Empty committed
  keys are intentional, so local debug/release builds skip Fabric resource
  processing until real local credentials are supplied.
- **Keep Fabric repository scoped:** The Twitter/Fabric app dependencies still
  come from the legacy Fabric repository; the root Android plugin can resolve
  from HTTPS Maven Central.

---

## Scope Boundaries

- This pass does not replace Fabric/Twitter Kit with maintained APIs.
- This pass does not add real Twitter or Fabric credentials.
- This pass does not alter the tweet text, Twitter login flow, UI layout, or manifest package name.
- This pass does not add hardware-level shake tests or emulator interaction.

---

## Implementation Units

### U1. Fix Sensor Lifecycle and Shake Detection

- **Goal:** Make the shake screen open, manage sensor listeners safely, and cover shake threshold/debounce logic without Android framework objects.
- **Files:** `app/src/main/java/gpj/tweetshake/ShakeActivity.java`, `app/src/main/java/gpj/tweetshake/ShakeDetector.java`, `app/src/test/java/gpj/tweetshake/ShakeDetectorTest.java`
- **Patterns:** Initialize sensor manager in `onCreate`, register in `onResume`, unregister in `onPause`, and delegate threshold/debounce decisions to a pure Java helper.
- **Test Scenarios:**
  - Source check fails if `SensorManager` initialization is removed.
  - Source check fails if unregister behavior is removed.
  - Source check fails if `ShakeActivity` stops routing accelerometer values through `ShakeDetector`.
  - Unit tests cover below-threshold movement, threshold triggering, debounce suppression, and cooldown recovery.
- **Verification:** `scripts/check-baseline.sh`, `./gradlew test --no-daemon`, `./gradlew assembleDebug --no-daemon`

### U2. Stabilize Legacy Build Resolution

- **Goal:** Make Gradle configure and assemble on the local SDK.
- **Files:** `build.gradle`, `app/build.gradle`, `README.md`
- **Patterns:** Use HTTPS Maven Central at root, keep Fabric Maven repo for Fabric dependencies, pin Fabric plugin 1.14.4, pin build-tools 24.0.3, add JUnit for detector tests, disable Crashlytics processing while committed Fabric API key placeholders are empty.
- **Test Scenarios:**
  - `./gradlew tasks --no-daemon` configures successfully.
  - `./gradlew assembleDebug --no-daemon` succeeds.
  - Source check fails if floating Fabric plugin, JCenter, or Crashlytics processing returns.
- **Verification:** Gradle commands and `scripts/check-baseline.sh`

### U3. Guard Credentials and Repo Hygiene

- **Goal:** Keep sensitive placeholders empty and local IDE files out of source control.
- **Files:** `MainActivity.java`, `AndroidManifest.xml`, `.gitignore`, `README.md`, `scripts/check-baseline.sh`
- **Patterns:** Empty committed placeholders, generated IDE metadata ignored and removed, documented credential policy.
- **Test Scenarios:**
  - Source check fails if Twitter key, Twitter secret, or Fabric API key placeholders are non-empty.
  - Source check fails if `.idea` or `.iml` files are tracked.
- **Verification:** `scripts/check-baseline.sh`

---

## Risks & Dependencies

- Runtime Twitter login and tweet composer behavior still require valid local credentials and a device/emulator.
- Fabric and Twitter Kit are deprecated; a future migration should be planned separately with replacement API decisions.
- Shake threshold behavior is preserved but not hardware-tested in this pass.

---

## Sources / Research

- `app/src/main/java/gpj/tweetshake/ShakeActivity.java` contains accelerometer listener and debounce behavior.
- `app/src/main/java/gpj/tweetshake/ShakeDetector.java` contains testable threshold and debounce behavior.
- `app/src/main/java/gpj/tweetshake/MainActivity.java` contains Twitter auth placeholders.
- `app/src/main/AndroidManifest.xml` contains the Fabric API key placeholder.
- `app/build.gradle` used Fabric plugin `1.+` and build-tools 22.0.1.
- Local Gradle configuration failed with Fabric plugin 1.31.2 against Android Gradle Plugin 1.2.3.
