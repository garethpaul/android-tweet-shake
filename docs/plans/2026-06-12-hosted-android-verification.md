# Hosted Android Verification

## Status: Completed

## Context

The canonical workflow clears Android SDK variables and therefore runs only
the static baseline. The legacy application now passes lint, JVM tests, and
debug assembly locally with Android API 22, build-tools 24.0.3, and Java 8.

## Goal

Make the hosted pull-request and default-branch gate execute the same complete
Android verification that succeeds locally.

## Changes

- Install Android platform-tools, API 22, and build-tools 24.0.3 before
  selecting Java 8 for the legacy Gradle build.
- Run the canonical `make check` target with the hosted SDK configured.
- Increase the job timeout to cover SDK setup and the complete Gradle gate.
- Pin and allowlist every GitHub Action and keep permissions read-only with
  checkout credentials disabled.
- Update the checker, README, and CI plan to require the hosted Android
  contract and truthful verification evidence.

## Verification

- Passed the SDK-backed lint, JVM test, and debug assembly gate with
  `ANDROID_HOME=/home/gjones/android-sdk ANDROID_SDK_ROOT=/home/gjones/android-sdk make check`.
- Passed the same complete gate from an external working directory.
- Confirmed lint reports exactly one `OldTargetApi` warning.
- Confirmed eight hostile workflow, checker, documentation, and plan-status
  mutations are rejected.
- Passed `git diff --check`.
- GitHub Actions `pull_request` run `27401082896` passed the complete hosted
  Android gate in 50 seconds for implementation commit
  `b28501b5f9567d8116af8f6955d96e5012eb84e8`.

## Boundaries

- Do not change `targetSdkVersion 22` or suppress its compatibility warning.
- Do not modernize Gradle, the Android plugin, JUnit, or application behavior.
- Do not add credentials, signing material, or new runtime dependencies.
