#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APP_BUILD="$ROOT_DIR/app/build.gradle"
ROOT_BUILD="$ROOT_DIR/build.gradle"
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
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
SHARESHEET_PLAN="$ROOT_DIR/docs/plans/2026-06-10-platform-sharesheet.md"
SHARE_LAUNCH_PLAN="$ROOT_DIR/docs/plans/2026-06-10-sharesheet-launch-compatibility.md"

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
  "shareInProgress = true" \
  "shareInProgress = false" \
  "R.string.share_unavailable"; do
  if ! grep -Fq "$share_contract" "$SHAKE_ACTIVITY"; then
    printf '%s\n' "Missing platform sharesheet contract: $share_contract" >&2
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

for detector_contract in \
  "static final float GRAVITY_EARTH = 9.80665f" \
  "static final float SHAKE_THRESHOLD_GRAVITY = 2.0f" \
  "static final long SHAKE_DEBOUNCE_MILLIS = 200L" \
  "if (!hasFiniteAcceleration(x, y, z))" \
  "if (!isFinite(accelerationMagnitudeSquared))" \
  "nowMillis - lastShakeAtMillis < SHAKE_DEBOUNCE_MILLIS"; do
  if ! grep -Fq "$detector_contract" "$SHAKE_DETECTOR"; then
    printf '%s\n' "Missing tested shake detector contract: $detector_contract" >&2
    exit 1
  fi
done

for test_contract in \
  "ignoresMovementBelowThreshold" \
  "ignoresNaNAcceleration" \
  "ignoresInfiniteAcceleration" \
  "invalidAccelerationDoesNotConsumeDebounceWindow" \
  "ignoresOverflowAccelerationMagnitude" \
  "triggersAboveThreshold" \
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

for readme_contract in \
  "make check" \
  "GitHub Actions" \
  'Android sharesheet' \
  'does not request the `INTERNET` permission' \
  "register the accelerometer listener"; do
  if ! grep -Fq "$readme_contract" "$README"; then
    printf '%s\n' "README must document contract: $readme_contract" >&2
    exit 1
  fi
done

if [ ! -f "$CI_WORKFLOW" ]; then
  printf '%s\n' "GitHub Actions check workflow is missing." >&2
  exit 1
fi

for workflow_contract in \
  "permissions:" \
  "contents: read" \
  "runs-on: ubuntu-24.04" \
  "cancel-in-progress: true" \
  "timeout-minutes: 5" \
  "workflow_dispatch:" \
  "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" \
  'ANDROID_HOME: ""' \
  'ANDROID_SDK_ROOT: ""' \
  "run: make check"; do
  if ! grep -Fq "$workflow_contract" "$CI_WORKFLOW"; then
    printf '%s\n' "GitHub Actions check workflow must keep contract: $workflow_contract" >&2
    exit 1
  fi
done

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

if [ ! -f "$CI_PLAN" ] || ! grep -Fq "Status: Completed" "$CI_PLAN" || ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "Tweet Shake CI plan must record completed make check verification." >&2
  exit 1
fi

if [ ! -f "$SHARESHEET_PLAN" ] || ! grep -Fq "Status: Completed" "$SHARESHEET_PLAN" || ! grep -Fq "make check" "$SHARESHEET_PLAN"; then
  printf '%s\n' "Platform sharesheet plan must record completed make check verification." >&2
  exit 1
fi

if [ ! -f "$SHARE_LAUNCH_PLAN" ] || ! grep -Fq "Status: Completed" "$SHARE_LAUNCH_PLAN" || \
   ! grep -Fq "make check" "$SHARE_LAUNCH_PLAN"; then
  printf '%s\n' "Sharesheet launch compatibility plan must record completed make check verification." >&2
  exit 1
fi

if git -C "$ROOT_DIR" ls-files '.idea/*' '*.iml' | grep -q .; then
  printf '%s\n' "Generated IDE metadata must not be tracked." >&2
  exit 1
fi

printf '%s\n' "Android Tweet Shake baseline checks passed."
