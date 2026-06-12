---
title: Gradle Wrapper Verification
date: 2026-06-12
status: completed
execution: code
---

# Gradle Wrapper Verification

## Summary

Add a checksum-capable generated Gradle Wrapper bootstrap while preserving the
Tweet Shake sample's Gradle 2.2.1, Java 8, API 22, documented lint warning,
nine gesture tests, lifecycle protection, and user-confirmed sharesheet flow.

## Requirements

- Preserve Gradle 2.2.1, Android Gradle Plugin 1.2.3, Java 8, API 22,
  build-tools 24.0.3, dependencies, app code, and behavior.
- Pin official Gradle 2.2.1 all-distribution SHA-256
  `1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab`.
- Regenerate the bootstrap with official Gradle 8.14.5 tooling and verify JAR
  SHA-256 `7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172`.
- Add exact SDK-free wrapper, documentation, and completed-evidence contracts.
- Pass complete local and final exact-head hosted Android and CodeQL gates.

## Decisions And Scope

Use Gradle 8.14.5 only to generate the bootstrap while retaining the legacy
runtime. Verify downloaded and checked-in artifacts separately, preserve the
all distribution, and document the uncached HTTPS dependency. Defer runtime,
SDK, dependency, gesture, UI, sharesheet, emulator, and device changes.

## Implementation Units

1. Generate the verified wrapper and prove fresh Java 8 success plus
   incorrect-checksum rejection.
2. Add exact static contracts and repository guidance.
3. Run `make check` from repository and external cwd, exercise hostile
   mutations, and require final Check and CodeQL success.

## Risks

- Use a fresh Gradle user home so caches cannot hide verification.
- Reject app, manifest, build-file, workflow, and behavior changes.
- Preserve the existing PR #1 as predecessor history.

## Sources

- [Gradle Wrapper documentation](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
- [Gradle security best practices](https://docs.gradle.org/current/userguide/best_practices_security.html)
- [Gradle 2.2.1 checksum](https://services.gradle.org/distributions/gradle-2.2.1-all.zip.sha256)
- [Gradle 8.14.5 wrapper JAR checksum](https://services.gradle.org/distributions/gradle-8.14.5-wrapper.jar.sha256)

## Work Completed

- Regenerated the wrapper with official Gradle 8.14.5 tooling while retaining
  Gradle 2.2.1 and the existing Android runtime.
- Added exact wrapper, documentation, and completed evidence contracts without
  changing app, manifest, build, or workflow files.

## Verification Completed

- A fresh temporary Gradle user home reported Gradle 2.2.1 on Java 8.
- A disposable wrapper proved the incorrect checksum was rejected before execution.
- SDK-backed `make check` passed with the documented lint warning, nine tests
  on both variants, and debug assembly from the repository and an external working directory.
- Focused hostile mutations rejected wrapper properties, JAR, launcher,
  documentation, and incomplete plan evidence.
- Shell syntax and `git diff --check` passed.

## Hosted Verification

Hosted evidence will be recorded after the exact implementation head passes.
