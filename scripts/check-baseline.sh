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
SHAKE_SESSION="$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeSession.java"
SHAKE_DETECTOR_TEST="$ROOT_DIR/app/src/test/java/gpj/tweetshake/ShakeDetectorTest.java"
SHAKE_HOST_TEST="$ROOT_DIR/scripts/ShakeDetectorHostTest.java"
SHAKE_SESSION_HOST_TEST="$ROOT_DIR/scripts/ShakeSessionHostTest.java"
SHAKE_HOST_RUNNER="$ROOT_DIR/scripts/test-shake-detector.sh"
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
REGISTRATION_OWNERSHIP_PLAN="$ROOT_DIR/docs/plans/2026-06-14-shake-registration-ownership-guard.md"
PORTABLE_DETECTOR_PLAN="$ROOT_DIR/docs/plans/2026-06-14-portable-shake-detector-tests.md"
DEVICE_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-android-tweet-shake-device-verification-checklist.md"
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
  "$SHAKE_SESSION" \
  "$SHAKE_DETECTOR_TEST" \
  "$SHAKE_HOST_TEST" \
  "$SHAKE_SESSION_HOST_TEST" \
  "$SHAKE_HOST_RUNNER" \
  "$SHAKE_LAYOUT" \
  "$STRINGS"; do
  if [ ! -f "$file" ]; then
    printf '%s\n' "Required baseline file is missing: $file" >&2
    exit 1
  fi
done

for session_contract in \
  'rejectsCallbacksBeforeRegistrationCompletes' \
  'failedRegistrationNeverOwnsCallbacks' \
  'pauseInvalidatesQueuedCallbacks' \
  'lateRegistrationResultCannotReactivatePausedSession' \
  'staleCallbacksStayInvalidAfterResume' \
  'staleRegistrationResultCannotClaimNewResume' \
  'acceptedShakeLocksShareLaunchAtomically' \
  'failedShareLaunchAllowsRetry' \
  'resumeClearsPreviousShareLock' \
  'Portable shake session tests passed:'; do
  if ! grep -Fq "$session_contract" "$SHAKE_SESSION_HOST_TEST"; then
    printf '%s\n' "Portable shake session coverage is missing: $session_contract" >&2
    exit 1
  fi
done

for host_contract in \
  'ignoresMovementBelowThreshold' \
  'ignoresNaNAcceleration' \
  'ignoresInfiniteAcceleration' \
  'invalidAccelerationDoesNotConsumeDebounceWindow' \
  'ignoresOverflowAccelerationMagnitude' \
  'triggersAtConfiguredThreshold' \
  'rejectsAdjacentValueBelowThreshold' \
  'firstShakeAtMaximumTimestampTriggers' \
  'backwardTimestampDoesNotReplaceAcceptedShakeTime' \
  'negativeTimestampDoesNotConsumeDebounceWindow' \
  'ignoresMovementBelowConfiguredGravityThreshold' \
  'debouncesConsecutiveShakes' \
  'allowsShakeAtCooldownBoundary' \
  'Portable shake detector tests passed:'; do
  if ! grep -Fq "$host_contract" "$SHAKE_HOST_TEST"; then
    printf '%s\n' "Portable shake detector coverage is missing: $host_contract" >&2
    exit 1
  fi
done

for runner_contract in \
  'OUTPUT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/tweet-shake-detector.XXXXXX")' \
  'if [ -d "$OUTPUT_DIR" ]; then' \
  'rm -rf -- "$OUTPUT_DIR"' \
  'trap cleanup EXIT' \
  'trap '\''cleanup; exit 1'\'' HUP INT TERM' \
  'JAVAC=${JAVAC:-javac}' \
  'JAVA=${JAVA:-java}' \
  '"$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeDetector.java"' \
  '"$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeSession.java"' \
  '"$ROOT_DIR/scripts/ShakeDetectorHostTest.java"' \
  '"$ROOT_DIR/scripts/ShakeSessionHostTest.java"' \
  '"$JAVA" -cp "$OUTPUT_DIR" gpj.tweetshake.ShakeDetectorHostTest' \
  '"$JAVA" -cp "$OUTPUT_DIR" gpj.tweetshake.ShakeSessionHostTest'; do
  if ! grep -Fq "$runner_contract" "$SHAKE_HOST_RUNNER"; then
    printf '%s\n' "Portable shake detector runner changed: $runner_contract" >&2
    exit 1
  fi
done
if ! grep -Fq 'if (test.cases != 13)' "$SHAKE_HOST_TEST"; then
  printf '%s\n' "Portable shake detector runner must require all thirteen cases." >&2
  exit 1
fi
if ! grep -Fq 'if (test.cases != 9)' "$SHAKE_SESSION_HOST_TEST"; then
  printf '%s\n' "Portable shake session runner must require all nine cases." >&2
  exit 1
fi
if [ "$(grep -Fc '$(ROOT)scripts/test-shake-detector.sh' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Make test must run the portable shake detector suite exactly once." >&2
  exit 1
fi
if [ ! -f "$PORTABLE_DETECTOR_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$PORTABLE_DETECTOR_PLAN" || \
   ! grep -Fq "make check" "$PORTABLE_DETECTOR_PLAN" || \
   ! grep -Fq "hostile mutations" "$PORTABLE_DETECTOR_PLAN"; then
  printf '%s\n' "Portable shake detector plan must record completed verification." >&2
  exit 1
fi
if ! grep -Fq 'Portable detector tests: `scripts/test-shake-detector.sh`' "$ROOT_DIR/AGENTS.md" || \
   ! grep -Fq 'always runs portable shake-detector tests' "$README" || \
   ! grep -Fq 'portable host regression tests for shake detection' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Portable shake detector documentation is incomplete." >&2
  exit 1
fi

for required_device_path in "$ROOT_DIR/DEVICE_VERIFICATION.md" "$DEVICE_VERIFICATION_PLAN"; do
  if [ ! -f "$required_device_path" ]; then
    printf '%s\n' "Required Tweet Shake device verification file is missing: ${required_device_path#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

for device_contract in \
  'commit SHA and pull request' \
  'synthetic share text' \
  'Accelerometer unavailable' \
  'Listener registration failure' \
  'Below-threshold motion' \
  'Threshold shake' \
  'Rapid repeated shakes' \
  'Debounce boundary' \
  'Pause before callback' \
  'Resume registration' \
  'Chooser already opening' \
  'Missing share activity' \
  'Permission-rejected launch' \
  'Do not convert `not run` into passing evidence.' \
  'device identifiers, sensor dumps, account names' \
  'every Android, accelerometer, chooser, and lifecycle row as unexecuted'; do
  if ! grep -Fq "$device_contract" "$ROOT_DIR/DEVICE_VERIFICATION.md"; then
    printf '%s\n' "Tweet Shake device checklist must keep contract: $device_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'DEVICE_VERIFICATION.md' "$README" || \
   ! grep -Fq 'explicit unexecuted rows' "$README" || \
   ! grep -Fq 'Tweet Shake device verification matrix' "$ROOT_DIR/VISION.md" || \
   ! grep -Fq 'every runtime row explicitly unexecuted' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' 'Repository guidance must document the unexecuted Tweet Shake device matrix.' >&2
  exit 1
fi

for device_plan_contract in \
  'Status: Completed' \
  'make check' \
  'hostile mutations' \
  'No emulator, accelerometer injection, physical device, share target, or live chooser scenario was executed'; do
  if ! grep -Fq "$device_plan_contract" "$DEVICE_VERIFICATION_PLAN"; then
    printf '%s\n' "Tweet Shake device plan must keep completion evidence: $device_plan_contract" >&2
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
  "$SHAKE_SESSION" \
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
979d6ed34ea779c06f50d5efc9e8131d6d64fa993534733836c7e32b71c8101d  app/src/main/java/gpj/tweetshake/ShakeActivity.java
4a55c086ac9e0b028fb3b32390a5235cb81ba7e5b4b6fbbcd652a20e23fcda97  app/src/main/java/gpj/tweetshake/ShakeDetector.java
78683f9a3227e0771cae154c326c1a4abd0f73b55c143e644d36af2c02fd14e2  app/src/main/java/gpj/tweetshake/ShakeSession.java
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

require_sha256 "$APP_BUILD" "b0bfe3513416b43eeeabe3e30221bf647f3a79a9240ea9a9d7e3745fcd0a8b3c" \
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

if ! grep -Fq "testCompile 'junit:junit:4.13.2'" "$APP_BUILD"; then
  printf '%s\n' "JUnit must stay on the patched 4.13.2 test dependency." >&2
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
  "if (isFinishing() || isDestroyed())" \
  "new Intent(Intent.ACTION_SEND)" \
  'shareIntent.setType("text/plain")' \
  "shareIntent.putExtra(Intent.EXTRA_TEXT, getString(R.string.share_text))" \
  "Intent.createChooser(" \
  "R.string.share_chooser_title" \
  "catch (ActivityNotFoundException exception)" \
  "catch (SecurityException exception)" \
  "private void recoverFromShareLaunchFailure()" \
  "shakeSession.shareLaunchFailed()" \
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
   [ "$(printf '%s\n' "$SHARE_COMPOSER" | grep -Fc "shakeSession.shareLaunchFailed();")" -ne 2 ] || \
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

if grep -Eq 'get(Intent|StringExtra|CharSequenceExtra)|getExtras\(' "$SHAKE_ACTIVITY"; then
  printf '%s\n' "Exported launcher activity must not trust inbound share data." >&2
  exit 1
fi

for sensor_contract in \
  "event == null || event.values == null || event.values.length < 3" \
  "TimeUnit.NANOSECONDS.toMillis(event.timestamp)" \
  "sensorManager == null" \
  "accelerometer == null" \
  "new Handler(Looper.getMainLooper())" \
  "createSensorListener(registration)" \
  "shakeSession.beginResume()" \
  "sensorManager.registerListener(" \
  "mainHandler" \
  "shakeSession.completeRegistration(registration, registered)" \
  "shakeSession.pause()" \
  "sensorManager.unregisterListener(listener)" \
  "R.string.shake_sensor_unavailable"; do
  if ! grep -Fq "$sensor_contract" "$SHAKE_ACTIVITY"; then
    printf '%s\n' "Missing shake sensor lifecycle contract: $sensor_contract" >&2
    exit 1
  fi
done

ON_RESUME=$(sed -n '/protected void onResume()/,/protected void onPause()/p' "$SHAKE_ACTIVITY")
ON_PAUSE=$(sed -n '/protected void onPause()/,/^    }/p' "$SHAKE_ACTIVITY")

for ownership_contract in \
  'static final class Registration' \
  'currentRegistration = new Registration()' \
  'registration == currentRegistration' \
  'currentRegistration = null' \
  'registration != currentRegistration || !registrationSucceeded || shareInProgress' \
  'shareInProgress = true' \
  'shareInProgress = false'; do
  if ! grep -Fq "$ownership_contract" "$SHAKE_SESSION"; then
    printf '%s\n' "Missing executable shake ownership contract: $ownership_contract" >&2
    exit 1
  fi
done

if grep -Fq 'implements SensorEventListener' "$SHAKE_ACTIVITY" || \
   grep -Fq 'SystemClock.elapsedRealtime()' "$SHAKE_ACTIVITY"; then
  printf '%s\n' "Shake callbacks must use per-resume listeners and sensor event time." >&2
  exit 1
fi

if [ ! -f "$REGISTRATION_OWNERSHIP_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$REGISTRATION_OWNERSHIP_PLAN" || \
   ! grep -Fq "make check" "$REGISTRATION_OWNERSHIP_PLAN" || \
   ! grep -Fq "focused hostile mutations" "$REGISTRATION_OWNERSHIP_PLAN"; then
  printf '%s\n' "Shake registration-ownership plan must record completed verification." >&2
  exit 1
fi

for registration_doc in "$README" "$SECURITY" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fq "current successful accelerometer registration" "$registration_doc"; then
    printf '%s\n' "$registration_doc must document callback registration ownership." >&2
    exit 1
  fi
done

RESUME_SUPER_LINE=$(printf '%s\n' "$ON_RESUME" | grep -nF "super.onResume();" | cut -d: -f1)
RESUME_SESSION_LINE=$(printf '%s\n' "$ON_RESUME" | grep -nF "shakeSession.beginResume();" | cut -d: -f1)
RESUME_REGISTER_LINE=$(printf '%s\n' "$ON_RESUME" | grep -nF "boolean registered = sensorManager.registerListener(" | cut -d: -f1)
if [ "$RESUME_SUPER_LINE" -ge "$RESUME_SESSION_LINE" ] || \
   [ "$RESUME_SESSION_LINE" -ge "$RESUME_REGISTER_LINE" ]; then
  printf '%s\n' "Shake activity must establish a fresh token before listener registration." >&2
  exit 1
fi

PAUSE_INVALIDATE_LINE=$(printf '%s\n' "$ON_PAUSE" | grep -nF "shakeSession.pause();" | cut -d: -f1)
PAUSE_UNREGISTER_LINE=$(printf '%s\n' "$ON_PAUSE" | grep -nF "sensorManager.unregisterListener(listener);" | cut -d: -f1)
PAUSE_SUPER_LINE=$(printf '%s\n' "$ON_PAUSE" | grep -nF "super.onPause();" | cut -d: -f1)
if [ "$PAUSE_INVALIDATE_LINE" -ge "$PAUSE_UNREGISTER_LINE" ] || \
   [ "$PAUSE_UNREGISTER_LINE" -ge "$PAUSE_SUPER_LINE" ]; then
  printf '%s\n' "Shake activity must invalidate ownership before listener teardown and superclass pause." >&2
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
  "rejectsAdjacentValueBelowThreshold" \
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
  'override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  'ANDROID_HOME ?=' \
  'ANDROID_SDK_ROOT ?=' \
  'GRADLE ?= $(ROOT)gradlew' \
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))' \
  'verify: lint test build'; do
  if ! grep -Fxq "$make_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Makefile must keep contract: $make_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc '$(ROOT)scripts/check-baseline.sh' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Makefile lint must run the baseline checker from the protected root." >&2
  exit 1
fi
for gradle_contract in \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) lint --no-daemon; \' \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) test --no-daemon; \' \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) assembleDebug --no-daemon; \' ; do
  if [ "$(grep -Fc "$gradle_contract" "$ROOT_DIR/Makefile")" -ne 1 ]; then
    printf '%s\n' "Makefile must keep one complete rooted Gradle contract: $gradle_contract" >&2
    exit 1
  fi
done
if ! grep -Fxq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-14-android-tweet-shake-make-root-override-protection.md"; then
  printf '%s\n' "Tweet Shake Make root protection plan must record completed status." >&2
  exit 1
fi

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
