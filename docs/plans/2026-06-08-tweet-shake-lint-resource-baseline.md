# Tweet Shake Lint Resource Baseline

## Goal

Make the legacy Android Tweet Shake project pass its documented quality gates without changing the Twitter login or shake-to-compose behavior.

## Scope

- Keep Fabric/Twitter credentials as empty placeholders.
- Preserve the existing shake detector threshold and debounce behavior.
- Clean resource and manifest lint issues surfaced by the current Android SDK.
- Add a changelog and source-only baseline checks for the cleaned lint state.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
