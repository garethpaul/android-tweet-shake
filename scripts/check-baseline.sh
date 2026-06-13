#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APP_BUILD="$ROOT_DIR/app/build.gradle"
ROOT_BUILD="$ROOT_DIR/build.gradle"
SETTINGS_GRADLE="$ROOT_DIR/settings.gradle"
GRADLE_PROPERTIES="$ROOT_DIR/gradle.properties"
WRAPPER_PROPERTIES="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"
GRADLEW="$ROOT_DIR/gradlew"
GRADLEW_BAT="$ROOT_DIR/gradlew.bat"
WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"
MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
SHAKE_ACTIVITY="$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeActivity.java"
SHAKE_DETECTOR="$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeDetector.java"
SHAKE_DETECTOR_TEST="$ROOT_DIR/app/src/test/java/gpj/tweetshake/ShakeDetectorTest.java"
SHAKE_LAYOUT="$ROOT_DIR/app/src/main/res/layout/shake_main.xml"
STRINGS="$ROOT_DIR/app/src/main/res/values/strings.xml"
COLORS="$ROOT_DIR/app/src/main/res/values/colors.xml"
STYLES="$ROOT_DIR/app/src/main/res/values/styles.xml"
STYLES_V21="$ROOT_DIR/app/src/main/res/values-v21/styles.xml"
README="$ROOT_DIR/README.md"
SECURITY="$ROOT_DIR/SECURITY.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CODEOWNERS="$ROOT_DIR/.github/CODEOWNERS"
FOREGROUND_CALLBACK_PLAN="$ROOT_DIR/docs/plans/2026-06-12-shake-foreground-callback-guard.md"
HOSTED_ANDROID_PLAN="$ROOT_DIR/docs/plans/2026-06-12-hosted-android-verification.md"
CI_BASELINE_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
WRAPPER_PLAN="$ROOT_DIR/docs/plans/2026-06-12-gradle-wrapper-verification.md"
DEBOUNCE_TIMESTAMP_PLAN="$ROOT_DIR/docs/plans/2026-06-13-shake-debounce-timestamp-guard.md"
SHARE_SECURITY_PLAN="$ROOT_DIR/docs/plans/2026-06-13-share-security-exception-recovery.md"
EXPECTED_FILE=$(mktemp "${TMPDIR:-/tmp}/android-tweet-shake-expected.XXXXXX")
trap 'rm -f "$EXPECTED_FILE"' EXIT HUP INT TERM

require_sha256() {
  file=$1
  expected=$2
  message=$3

  if [ "$(sha256sum "$file" | awk '{print $1}')" != "$expected" ]; then
    printf '%s\n' "$message" >&2
    exit 1
  fi
}

for file in \
  "$APP_BUILD" \
  "$ROOT_BUILD" \
  "$MANIFEST" \
  "$SHAKE_ACTIVITY" \
  "$SHAKE_DETECTOR" \
  "$SHAKE_DETECTOR_TEST" \
  "$SHAKE_LAYOUT" \
  "$STRINGS"; do
  if [ ! -f "$file" ]; then
    printf '%s\n' "Required baseline file is missing: $file" >&2
    exit 1
  fi
done

if git -C "$ROOT_DIR" ls-files -s | awk '$1 == "120000" { found = 1 } END { exit found ? 0 : 1 }'; then
  printf '%s\n' "Tracked symbolic links are outside the audited repository baseline." >&2
  exit 1
fi

source_paths=$(find "$ROOT_DIR/app/src" -type f \( -name '*.java' -o -name '*.kt' \) -print | LC_ALL=C sort)
expected_source_paths=$(printf '%s\n' \
  "$ROOT_DIR/app/src/androidTest/java/gpj/tweetshake/ApplicationTest.java" \
  "$SHAKE_ACTIVITY" \
  "$SHAKE_DETECTOR" \
  "$SHAKE_DETECTOR_TEST" | LC_ALL=C sort)
if [ "$source_paths" != "$expected_source_paths" ]; then
  printf '%s\n' "Android source inventory must match the audited sharesheet app." >&2
  exit 1
fi

manifest_paths=$(find "$ROOT_DIR/app/src" -type f -name 'AndroidManifest.xml' -print | LC_ALL=C sort)
if [ "$manifest_paths" != "$MANIFEST" ]; then
  printf '%s\n' "The fixed legacy app must keep one audited Android manifest." >&2
  exit 1
fi

cat > "$EXPECTED_FILE" <<'EOF'
a6ad0975f40ef1d7ece2d2889b5533689695d815407bd177012d9083bcac310e  app/src/main/AndroidManifest.xml
e712bcac817d4b5a3605e8fe4a66d3e7184d8e94647822752796cd8449f87ebb  app/src/main/java/gpj/tweetshake/ShakeActivity.java
d0e77a3a107080adae2503b121f41c1d388e3efd4a3b03f51057a8c9fb0c7a24  app/src/main/java/gpj/tweetshake/ShakeDetector.java
6f1229c3150be8c5e2535c7df9ae8f9492a57f0a7299bd5615aca6af88175d76  app/src/main/res/drawable-nodpi/logo.png
90bf617d42708937a9d8db2e3de002b1b5dbee8411482897b23523d849117db1  app/src/main/res/layout/shake_main.xml
820e323f5506dc1dda3fad164e5fa0acd56a8266e4ea441db94e60fd9972d28a  app/src/main/res/mipmap-hdpi/ic_launcher.png
90f5bc4bf1364152b1943933b6910bafc913e7a813de5c1b0ba4723e33e58975  app/src/main/res/mipmap-mdpi/ic_launcher.png
552f9a01050827cc24c9bf50569fe8b0a121fb93297106e224986e7a4e9cc747  app/src/main/res/mipmap-xhdpi/ic_launcher.png
c6e7620e6c5d9bf8020f7216117d8cb799f7936f232e28732443b1fe79521d6c  app/src/main/res/mipmap-xxhdpi/ic_launcher.png
24ae0c6e407500210f38b31fc40dedc9105b66b0543ef920e485fca20f7c5990  app/src/main/res/values-v21/styles.xml
7b12b0133d18e5e90fa63f123c78437e1a6599510865b658cecfe545faa59e98  app/src/main/res/values/colors.xml
ec06db62c6c767a44e49c767a19592e37c8a71ef076ee0780bb0410136f089d3  app/src/main/res/values/strings.xml
2eeed855c9cc5993950b4722f90d32df4724d55a7e2e2470edbaa801c976805f  app/src/main/res/values/styles.xml
EOF
actual_app_inventory=$(cd "$ROOT_DIR" && find app/src/main -type f -print | LC_ALL=C sort | xargs sha256sum)
if [ "$actual_app_inventory" != "$(cat "$EXPECTED_FILE")" ]; then
  printf '%s\n' "Production app files must match the audited sharesheet inventory and hashes." >&2
  exit 1
fi

if find "$ROOT_DIR/app" -type f \( -name '*.so' -o -name '*.dex' -o -name '*.jar' -o -name '*.aar' -o -name '*.apk' \) \
  ! -path "$ROOT_DIR/app/build/*" -print | grep -q .; then
  printf '%s\n' "Packaged Android binary payloads are outside the auditable source baseline." >&2
  exit 1
fi

gradle_paths=$(find "$ROOT_DIR" \
  -path "$ROOT_DIR/.git" -prune -o \
  -path "$ROOT_DIR/app/build" -prune -o \
  -type f \( -name '*.gradle' -o -name 'gradle.properties' -o -name 'gradle-wrapper.properties' \) \
  -print | LC_ALL=C sort)
expected_gradle_paths=$(printf '%s\n' \
  "$APP_BUILD" \
  "$ROOT_BUILD" \
  "$GRADLE_PROPERTIES" \
  "$WRAPPER_PROPERTIES" \
  "$SETTINGS_GRADLE" | LC_ALL=C sort)
if [ "$gradle_paths" != "$expected_gradle_paths" ]; then
  printf '%s\n' "The fixed legacy build must not add executable Gradle configuration." >&2
  exit 1
fi

if [ -e "$ROOT_DIR/buildSrc" ] || [ -L "$ROOT_DIR/buildSrc" ]; then
  printf '%s\n' "Gradle buildSrc is an unapproved implicit executable build input." >&2
  exit 1
fi

require_sha256 "$APP_BUILD" "acef00c121527e0ce476bad5b410ef6b06a0c43c7654c8f87a9b3d42d0794471" \
  "App Gradle configuration must match the audited sharesheet baseline."
require_sha256 "$ROOT_BUILD" "14a3eb90ed06d4a557c987fe38659fc025fff85a4dee555990fe58b4a85a59e5" \
  "Root Gradle configuration must match the audited sharesheet baseline."
require_sha256 "$SETTINGS_GRADLE" "4b919cfffaed71637d1ee9c89f21f4247273e14eb8433afdcd0672eba906b41f" \
  "Gradle settings must keep the single audited app module."
require_sha256 "$GRADLE_PROPERTIES" "1cce242f70d5d96dc4415d2258063984df33e44fa37a3daa75d7a2b22c14f23d" \
  "Gradle properties must match the audited legacy baseline."
require_sha256 "$WRAPPER_PROPERTIES" "42874592f15508aa0a9135568ad3f9705b5f35bf987591bc73dd428f2250de5d" \
  "Gradle wrapper properties must retain the reviewed URL and checksum."
require_sha256 "$MANIFEST" "a6ad0975f40ef1d7ece2d2889b5533689695d815407bd177012d9083bcac310e" \
  "Android manifest must match the audited no-network sharesheet baseline."
require_sha256 "$GRADLEW" "b187b4c52e749f5760afdd6fadc31b2a98ad35fb249bf0dff03b72650f320409" \
  "The Unix Gradle wrapper must match the recorded trusted hash."
require_sha256 "$GRADLEW_BAT" "94102713eb8fb22d032397924c0f38ab2da783ba60d07054339f1190a0c4e2cd" \
  "The Windows Gradle wrapper must match the recorded trusted hash."
require_sha256 "$WRAPPER_JAR" "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172" \
  "The Gradle wrapper JAR must match the recorded trusted hash."

if ! grep -Fq "url 'https://repo1.maven.org/maven2'" "$ROOT_BUILD"; then
  printf '%s\n' "Build repositories must use HTTPS Maven Central." >&2
  exit 1
fi

if grep -Fq "jcenter()" "$ROOT_BUILD" "$APP_BUILD"; then
  printf '%s\n' "Build repositories must not use JCenter." >&2
  exit 1
fi

if ! grep -Fq "classpath 'com.android.tools.build:gradle:1.2.3'" "$ROOT_BUILD"; then
  printf '%s\n' "Legacy Android Gradle Plugin must remain pinned for this toolchain." >&2
  exit 1
fi

if ! grep -Fq 'buildToolsVersion "24.0.3"' "$APP_BUILD"; then
  printf '%s\n' "Android build-tools must stay pinned to 24.0.3 for 64-bit aapt." >&2
  exit 1
fi

if grep -Eiq 'fabric|com\.twitter|tweetcomposer|twitterlogin|twitter_key|twitter_secret|/opt/twitter' \
  "$APP_BUILD" "$ROOT_DIR/app/proguard-rules.pro" "$MANIFEST" "$SHAKE_ACTIVITY" "$STRINGS"; then
  printf '%s\n' "Retired Fabric and Twitter Kit integration must not be restored." >&2
  exit 1
fi

if find "$ROOT_DIR/app/src" -type f \( -name '*.java' -o -name '*.kt' \) \
  -exec grep -E 'java\.net|android\.net|HttpURLConnection|URLConnection|Socket|WebView|org\.apache\.http|okhttp|retrofit' {} + | grep -q .; then
  printf '%s\n' "Sharesheet source must not add direct network clients." >&2
  exit 1
fi

if grep -Fq 'android.permission.INTERNET' "$MANIFEST"; then
  printf '%s\n' "Platform sharing must not request direct network access." >&2
  exit 1
fi

for removed_path in \
  "$ROOT_DIR/app/src/main/java/gpj/tweetshake/MainActivity.java" \
  "$ROOT_DIR/app/src/main/res/layout/activity_main.xml" \
  "$ROOT_DIR/app/src/main/res/menu/menu_main.xml" \
  "$ROOT_DIR/proguard-com.twitter.sdk.android.twitter.txt"; do
  if [ -e "$removed_path" ]; then
    printf '%s\n' "Retired integration file must stay removed: $removed_path" >&2
    exit 1
  fi
done

for manifest_contract in \
  'android:allowBackup="false"' \
  'android:theme="@style/AppTheme"' \
  'android:name="android.hardware.sensor.accelerometer"' \
  'android:required="false"' \
  'android:name=".ShakeActivity"' \
  'android:exported="true"' \
  'android.intent.action.MAIN' \
  'android.intent.category.LAUNCHER'; do
  if ! grep -Fq "$manifest_contract" "$MANIFEST"; then
    printf '%s\n' "Missing launcher manifest contract: $manifest_contract" >&2
    exit 1
  fi
done

for share_contract in \
  "private void showShareComposer()" \
  "if (shareInProgress || isFinishing() || isDestroyed())" \
  "new Intent(Intent.ACTION_SEND)" \
  'shareIntent.setType("text/plain")' \
  "shareIntent.putExtra(Intent.EXTRA_TEXT, getString(R.string.share_text))" \
  "Intent.createChooser(" \
  "R.string.share_chooser_title" \
  "catch (ActivityNotFoundException exception)" \
  "catch (SecurityException exception)" \
  "private void recoverFromShareLaunchFailure()" \
  "shareInProgress = true" \
  "shareInProgress = false" \
  "R.string.share_unavailable"; do
  if ! grep -Fq "$share_contract" "$SHAKE_ACTIVITY"; then
    printf '%s\n' "Missing platform sharesheet contract: $share_contract" >&2
    exit 1
  fi
done

SHARE_COMPOSER=$(sed -n \
  '/private void showShareComposer()/,/private void showSensorUnavailable()/p' \
  "$SHAKE_ACTIVITY")
if [ "$(printf '%s\n' "$SHARE_COMPOSER" | grep -Fc "recoverFromShareLaunchFailure();")" -ne 2 ] || \
   [ "$(printf '%s\n' "$SHARE_COMPOSER" | grep -Fc "shareInProgress = false;")" -ne 1 ] || \
   [ "$(printf '%s\n' "$SHARE_COMPOSER" | grep -Fc "showShareUnavailable();")" -ne 1 ]; then
  printf '%s\n' "Both narrow sharesheet launch catches must use one reviewed recovery path." >&2
  exit 1
fi
if printf '%s\n' "$SHARE_COMPOSER" | \
    grep -Eq 'catch \((RuntimeException|Throwable|[[:alnum:]_.$]*Error)([[:space:]]|\))'; then
  printf '%s\n' "Sharesheet launch must not catch broad runtime or fatal exceptions." >&2
  exit 1
fi
if [ ! -f "$SHARE_SECURITY_PLAN" ] || \
   ! grep -Fq "## Status: Completed" "$SHARE_SECURITY_PLAN" || \
   ! grep -Fq "make check" "$SHARE_SECURITY_PLAN" || \
   ! grep -Fq "hostile mutations" "$SHARE_SECURITY_PLAN"; then
  printf '%s\n' "Share security-exception plan must record completed verification." >&2
  exit 1
fi
for share_security_doc in "$ROOT_DIR/AGENTS.md" "$README" "$SECURITY" \
  "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! tr '\n' ' ' < "$share_security_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "permission-rejected chooser launches"; then
    printf '%s\n' "$share_security_doc must document permission-rejected chooser launches." >&2
    exit 1
  fi
done

if grep -Fq ".resolveActivity(" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "Sharesheet launch must not depend on a package-visibility query." >&2
  exit 1
fi

for sensor_contract in \
  "event == null || event.values == null || event.values.length < 3" \
  "SystemClock.elapsedRealtime()" \
  "sensorManager == null" \
  "accelerometer == null" \
  "sensorRegistered = sensorManager.registerListener(" \
  "if (!sensorRegistered)" \
  "if (sensorManager != null && sensorRegistered)" \
  "sensorManager.unregisterListener(this)" \
  "sensorRegistered = false" \
  "R.string.shake_sensor_unavailable"; do
  if ! grep -Fq "$sensor_contract" "$SHAKE_ACTIVITY"; then
    printf '%s\n' "Missing shake sensor lifecycle contract: $sensor_contract" >&2
    exit 1
  fi
done

CHECK_SHAKE=$(sed -n '/private void checkShake(SensorEvent event)/,/private void showShareComposer()/p' "$SHAKE_ACTIVITY")
ON_RESUME=$(sed -n '/protected void onResume()/,/protected void onPause()/p' "$SHAKE_ACTIVITY")
ON_PAUSE=$(sed -n '/protected void onPause()/,/^    }/p' "$SHAKE_ACTIVITY")

if [ "$(grep -Fc "private boolean activityResumed;" "$SHAKE_ACTIVITY" || true)" -ne 1 ]; then
  printf '%s\n' "Shake activity must declare exactly one foreground-state field." >&2
  exit 1
fi

if [ "$(printf '%s\n' "$CHECK_SHAKE" | grep -Fc "if (!activityResumed)" || true)" -ne 1 ]; then
  printf '%s\n' "Queued shake callbacks must be ignored outside the resumed activity state." >&2
  exit 1
fi

CHECK_GUARD_LINE=$(printf '%s\n' "$CHECK_SHAKE" | grep -nF "if (!activityResumed)" | cut -d: -f1)
CHECK_EVENT_LINE=$(printf '%s\n' "$CHECK_SHAKE" | grep -nF "event == null" | cut -d: -f1)
if [ "$CHECK_GUARD_LINE" -ge "$CHECK_EVENT_LINE" ]; then
  printf '%s\n' "Foreground state must be checked before reading queued sensor callbacks." >&2
  exit 1
fi

if [ "$(printf '%s\n' "$ON_RESUME" | grep -Fc "activityResumed = true;" || true)" -ne 1 ]; then
  printf '%s\n' "Shake activity must mark itself resumed before processing callbacks." >&2
  exit 1
fi

RESUME_SUPER_LINE=$(printf '%s\n' "$ON_RESUME" | grep -nF "super.onResume();" | cut -d: -f1)
RESUME_ACTIVE_LINE=$(printf '%s\n' "$ON_RESUME" | grep -nF "activityResumed = true;" | cut -d: -f1)
RESUME_REGISTER_LINE=$(printf '%s\n' "$ON_RESUME" | grep -nF "sensorRegistered = sensorManager.registerListener(" | cut -d: -f1)
if [ "$RESUME_SUPER_LINE" -ge "$RESUME_ACTIVE_LINE" ] || \
   [ "$RESUME_ACTIVE_LINE" -ge "$RESUME_REGISTER_LINE" ]; then
  printf '%s\n' "Shake activity must become active after superclass resume and before listener registration." >&2
  exit 1
fi

if [ "$(printf '%s\n' "$ON_PAUSE" | grep -Fc "activityResumed = false;" || true)" -ne 1 ]; then
  printf '%s\n' "Shake activity must become inactive before listener teardown." >&2
  exit 1
fi

PAUSE_INACTIVE_LINE=$(printf '%s\n' "$ON_PAUSE" | grep -nF "activityResumed = false;" | cut -d: -f1)
PAUSE_UNREGISTER_LINE=$(printf '%s\n' "$ON_PAUSE" | grep -nF "sensorManager.unregisterListener(this);" | cut -d: -f1)
PAUSE_SUPER_LINE=$(printf '%s\n' "$ON_PAUSE" | grep -nF "super.onPause();" | cut -d: -f1)
if [ "$PAUSE_INACTIVE_LINE" -ge "$PAUSE_UNREGISTER_LINE" ] || \
   [ "$PAUSE_UNREGISTER_LINE" -ge "$PAUSE_SUPER_LINE" ]; then
  printf '%s\n' "Shake activity must become inactive before listener teardown and superclass pause." >&2
  exit 1
fi

if [ ! -f "$FOREGROUND_CALLBACK_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$FOREGROUND_CALLBACK_PLAN" || \
   ! grep -Fq "make check" "$FOREGROUND_CALLBACK_PLAN"; then
  printf '%s\n' "Shake foreground callback plan must record completed make check verification." >&2
  exit 1
fi

if [ ! -f "$DEBOUNCE_TIMESTAMP_PLAN" ] || \
   ! grep -Fq "status: completed" "$DEBOUNCE_TIMESTAMP_PLAN" || \
   ! grep -Fq "## Status: Completed" "$DEBOUNCE_TIMESTAMP_PLAN" || \
   ! grep -Fq 'SDK-backed `make check` passed' "$DEBOUNCE_TIMESTAMP_PLAN" || \
   ! grep -Fq "Ten isolated hostile mutations were rejected" "$DEBOUNCE_TIMESTAMP_PLAN"; then
  printf '%s\n' "Shake debounce timestamp plan must record completed status and verification." >&2
  exit 1
fi

for detector_contract in \
  "static final float GRAVITY_EARTH = 9.80665f" \
  "static final float SHAKE_THRESHOLD_GRAVITY = 2.0f" \
  "static final long SHAKE_DEBOUNCE_MILLIS = 200L" \
  "private boolean hasAcceptedShake;" \
  "if (!hasFiniteAcceleration(x, y, z))" \
  "if (!isFinite(accelerationMagnitudeSquared))" \
  "if (nowMillis < 0L)" \
  "if (hasAcceptedShake" \
  "nowMillis < lastShakeAtMillis" \
  "nowMillis - lastShakeAtMillis < SHAKE_DEBOUNCE_MILLIS" \
  "hasAcceptedShake = true;"; do
  if ! grep -Fq "$detector_contract" "$SHAKE_DETECTOR"; then
    printf '%s\n' "Missing tested shake detector contract: $detector_contract" >&2
    exit 1
  fi
done

if grep -Fq "lastShakeAtMillis = -SHAKE_DEBOUNCE_MILLIS" "$SHAKE_DETECTOR"; then
  printf '%s\n' "Shake detector must not use overflow-prone negative timestamp initialization." >&2
  exit 1
fi

if ! grep -Fq "Queued accelerometer callbacks are ignored after the activity pauses" "$README"; then
  printf '%s\n' "README must document the foreground shake callback guard." >&2
  exit 1
fi

for test_contract in \
  "ignoresMovementBelowThreshold" \
  "ignoresNaNAcceleration" \
  "ignoresInfiniteAcceleration" \
  "invalidAccelerationDoesNotConsumeDebounceWindow" \
  "ignoresOverflowAccelerationMagnitude" \
  "triggersAboveThreshold" \
  "firstShakeAtMaximumTimestampTriggers" \
  "backwardTimestampDoesNotReplaceAcceptedShakeTime" \
  "negativeTimestampDoesNotConsumeDebounceWindow" \
  "debouncesConsecutiveShakes" \
  "allowsShakeAfterCooldown"; do
  if ! grep -Fq "$test_contract" "$SHAKE_DETECTOR_TEST"; then
    printf '%s\n' "Missing shake detector regression test: $test_contract" >&2
    exit 1
  fi
done

if [ ! -f "$ROOT_DIR/app/src/main/res/drawable-nodpi/logo.png" ]; then
  printf '%s\n' "The legacy bitmap logo must stay in drawable-nodpi." >&2
  exit 1
fi

if grep -Fq 'android:background="#31AA39"' "$SHAKE_LAYOUT"; then
  printf '%s\n' "Screen background must be provided by the app theme." >&2
  exit 1
fi

for resource_contract in \
  'android:text="@string/shake_to_tweet_title"' \
  'android:contentDescription="@string/tweet_shake_logo_description"'; do
  if ! grep -Fq "$resource_contract" "$SHAKE_LAYOUT"; then
    printf '%s\n' "Missing layout resource contract: $resource_contract" >&2
    exit 1
  fi
done

for string_contract in \
  'name="shake_sensor_unavailable"' \
  'name="share_chooser_title"' \
  'name="share_text"' \
  'name="share_unavailable"'; do
  if ! grep -Fq "$string_contract" "$STRINGS"; then
    printf '%s\n' "Missing resource-backed message: $string_contract" >&2
    exit 1
  fi
done

if ! grep -Fq '<color name="tweet_shake_background">#31AA39</color>' "$COLORS" || \
   ! grep -Fq '<item name="android:windowBackground">@color/tweet_shake_background</item>' "$STYLES" || \
   ! grep -Fq '<item name="android:windowBackground">@color/tweet_shake_background</item>' "$STYLES_V21"; then
  printf '%s\n' "Tweet Shake theme background contract is incomplete." >&2
  exit 1
fi

if [ ! -f "$CI_WORKFLOW" ]; then
  printf '%s\n' "GitHub Actions check workflow is missing." >&2
  exit 1
fi

workflow_paths=$(find "$ROOT_DIR/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) -print | LC_ALL=C sort)
if [ "$workflow_paths" != "$CI_WORKFLOW" ]; then
  printf '%s\n' "The canonical check workflow must be the only GitHub Actions workflow." >&2
  exit 1
fi

cat > "$EXPECTED_FILE" <<'EOF'
name: Check

on:
  pull_request:
  push:
    branches:
      - master
  workflow_dispatch:

permissions:
  contents: read

env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true

concurrency:
  group: check-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  check:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    steps:
      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false
      - name: Install Android SDK packages
        run: '"${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-22" "build-tools;24.0.3"'
      - name: Set up Java 8
        uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 # v5.2.0
        with:
          distribution: corretto
          java-version: "8"
      - name: Run full verification
        run: make check
EOF
if ! cmp -s "$CI_WORKFLOW" "$EXPECTED_FILE"; then
  printf '%s\n' "GitHub Actions check workflow must match the canonical credential-free contract." >&2
  exit 1
fi

if [ ! -f "$HOSTED_ANDROID_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "make check" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "OldTargetApi" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq 'GitHub Actions `pull_request` run `27401082896` passed' "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "b28501b5f9567d8116af8f6955d96e5012eb84e8" "$HOSTED_ANDROID_PLAN"; then
  printf '%s\n' "Hosted Android verification plan must record completed local and hosted evidence." >&2
  exit 1
fi

if ! grep -Fq "canonical GitHub Actions workflow installs Android API 22" "$README" || \
   ! grep -Fq "2026-06-12-hosted-android-verification.md" "$README"; then
  printf '%s\n' "README must document the hosted Android gate and plan." >&2
  exit 1
fi

if [ ! -f "$CI_BASELINE_PLAN" ] || \
   ! grep -Fq "build-tools 24.0.3" "$CI_BASELINE_PLAN" || \
   ! grep -Fq 'complete `make check` gate' "$CI_BASELINE_PLAN" || \
   ! grep -Fq "Exact-head pull-request workflow" "$CI_BASELINE_PLAN"; then
  printf '%s\n' "CI baseline plan must document the complete hosted Android gate." >&2
  exit 1
fi

cat > "$EXPECTED_FILE" <<'EOF'
* @garethpaul
/.github/CODEOWNERS @garethpaul
/.github/workflows/ @garethpaul
/Makefile @garethpaul
/scripts/check-baseline.sh @garethpaul
/build.gradle @garethpaul
/settings.gradle @garethpaul
/gradle.properties @garethpaul
/gradle/ @garethpaul
/gradlew @garethpaul
/gradlew.bat @garethpaul
/app/ @garethpaul
EOF
if [ ! -f "$CODEOWNERS" ] || ! cmp -s "$CODEOWNERS" "$EXPECTED_FILE"; then
  printf '%s\n' "CODEOWNERS must protect the repository and explicit trust boundaries." >&2
  exit 1
fi

for make_contract in \
  'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))' \
  "verify: lint test build"; do
  if ! grep -Fq "$make_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Makefile must keep contract: $make_contract" >&2
    exit 1
  fi
done

if grep -Eq '/(home|Users)/[^/]+/.+android-sdk' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must not embed a maintainer-specific Android SDK path." >&2
  exit 1
fi

if git -C "$ROOT_DIR" ls-files '.idea/*' '*.iml' | grep -q .; then
  printf '%s\n' "Generated IDE metadata must not be tracked." >&2
  exit 1
fi

if ! grep -Fq 'distributionSha256Sum=1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab' "$WRAPPER_PROPERTIES" || \
   ! grep -Fq 'distributionUrl=https\://services.gradle.org/distributions/gradle-2.2.1-all.zip' "$WRAPPER_PROPERTIES"; then
  printf '%s\n' "Gradle wrapper properties must authenticate the official Gradle 2.2.1 distribution." >&2; exit 1
fi
if ! grep -Fq "Gradle start up script for POSIX generated by Gradle." "$GRADLEW" || ! grep -Fq "Gradle startup script for Windows" "$GRADLEW_BAT"; then
  printf '%s\n' "Gradle wrapper launchers must retain generated provenance markers." >&2; exit 1
fi
if [ ! -f "$WRAPPER_PLAN" ] || ! grep -Fq "status: completed" "$WRAPPER_PLAN" || ! grep -Fq "fresh temporary Gradle user home" "$WRAPPER_PLAN" || ! grep -Fq "incorrect checksum was rejected" "$WRAPPER_PLAN" || ! grep -Fq 'SDK-backed `make check` passed' "$WRAPPER_PLAN" || ! grep -Fq "external working directory" "$WRAPPER_PLAN" || ! grep -Fq "hostile mutations rejected" "$WRAPPER_PLAN"; then
  printf '%s\n' "Gradle wrapper plan must record completed local verification evidence." >&2; exit 1
fi
if ! grep -Fq "distributionSha256Sum" "$README" || ! grep -Fq "uncached build offline-reproducible" "$README" || ! grep -Fq "wrapper JAR and Gradle distribution checksums" "$SECURITY"; then
  printf '%s\n' "Repository docs must describe wrapper verification and its online boundary." >&2; exit 1
fi

printf '%s\n' "Android Tweet Shake baseline checks passed."
