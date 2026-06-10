#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ROOT_BUILD="$ROOT_DIR/build.gradle"
APP_BUILD="$ROOT_DIR/app/build.gradle"
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/gpj/tweetshake/MainActivity.java"
SHAKE_ACTIVITY="$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeActivity.java"
SHAKE_DETECTOR="$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeDetector.java"
SHAKE_DETECTOR_TEST="$ROOT_DIR/app/src/test/java/gpj/tweetshake/ShakeDetectorTest.java"
THRESHOLD_PLAN="$ROOT_DIR/docs/plans/2026-06-08-shake-threshold-gravity-baseline.md"
FINITE_PLAN="$ROOT_DIR/docs/plans/2026-06-08-shake-finite-acceleration-baseline.md"
LOGIN_FAILURE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-tweet-login-failure-feedback.md"
MAGNITUDE_OVERFLOW_PLAN="$ROOT_DIR/docs/plans/2026-06-09-shake-magnitude-overflow-guard.md"
SENSOR_UNAVAILABLE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-shake-sensor-unavailable-feedback.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
LINT_XML="$ROOT_DIR/app/lint.xml"
COLORS="$ROOT_DIR/app/src/main/res/values/colors.xml"
STRINGS="$ROOT_DIR/app/src/main/res/values/strings.xml"
STYLES="$ROOT_DIR/app/src/main/res/values/styles.xml"
STYLES_V21="$ROOT_DIR/app/src/main/res/values-v21/styles.xml"
ACTIVITY_LAYOUT="$ROOT_DIR/app/src/main/res/layout/activity_main.xml"
SHAKE_LAYOUT="$ROOT_DIR/app/src/main/res/layout/shake_main.xml"

if [ ! -f "$ROOT_DIR/CHANGES.md" ]; then
  printf '%s\n' "CHANGES.md must document repository maintenance." >&2
  exit 1
fi

if [ ! -f "$CI_WORKFLOW" ]; then
  printf '%s\n' "GitHub Actions workflow is missing." >&2
  exit 1
fi

if [ ! -f "$CI_PLAN" ]; then
  printf '%s\n' "CI baseline plan is missing." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/Makefile" ]; then
  printf '%s\n' "Makefile must expose the SDK-free check wrapper." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must run the SDK-free baseline check." >&2
  exit 1
fi

if ! grep -Fq "lint:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a lint gate." >&2
  exit 1
fi

if ! grep -Fq "test:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a test gate." >&2
  exit 1
fi

if ! grep -Fq "build:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a build gate." >&2
  exit 1
fi

if ! grep -Fq "verify: lint test build" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile verify must run lint, test, and build gates." >&2
  exit 1
fi

if [ ! -f "$THRESHOLD_PLAN" ]; then
  printf '%s\n' "Shake threshold gravity plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$THRESHOLD_PLAN" || ! grep -Fq "make check" "$THRESHOLD_PLAN"; then
  printf '%s\n' "Shake threshold gravity plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$FINITE_PLAN" ]; then
  printf '%s\n' "Shake finite acceleration plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$FINITE_PLAN" || ! grep -Fq "make check" "$FINITE_PLAN"; then
  printf '%s\n' "Shake finite acceleration plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$LOGIN_FAILURE_PLAN" ]; then
  printf '%s\n' "Tweet login failure feedback plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$LOGIN_FAILURE_PLAN" || ! grep -Fq "make check" "$LOGIN_FAILURE_PLAN"; then
  printf '%s\n' "Tweet login failure feedback plan must record completed status and make check verification." >&2
  exit 1
fi

if ! grep -Fq "Android Tweet Shake Changes" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "CHANGES.md must identify the project." >&2
  exit 1
fi

for workflow_contract in \
  "permissions:" \
  "contents: read" \
  "timeout-minutes: 5" \
  "workflow_dispatch:" \
  "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" \
  'ANDROID_HOME: ""' \
  'ANDROID_SDK_ROOT: ""' \
  "run: make check"; do
  if ! grep -Fq "$workflow_contract" "$CI_WORKFLOW"; then
    printf '%s\n' "GitHub Actions workflow must keep contract: $workflow_contract" >&2
    exit 1
  fi
done

if grep -Fq "/home/gjones" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must not embed a maintainer-specific Android SDK path." >&2
  exit 1
fi

if ! grep -Fq "url 'https://repo1.maven.org/maven2'" "$ROOT_BUILD"; then
  printf '%s\n' "Root build must use HTTPS Maven Central." >&2
  exit 1
fi

if grep -Fq "jcenter()" "$ROOT_BUILD"; then
  printf '%s\n' "Root build must not use JCenter." >&2
  exit 1
fi

if ! grep -Fq "classpath 'io.fabric.tools:gradle:1.14.4'" "$APP_BUILD"; then
  printf '%s\n' "Fabric Gradle plugin must stay pinned to 1.14.4." >&2
  exit 1
fi

if grep -Fq "io.fabric.tools:gradle:1.+" "$APP_BUILD"; then
  printf '%s\n' "Fabric Gradle plugin must not use a floating 1.+ version." >&2
  exit 1
fi

if ! grep -Fq "testCompile 'junit:junit:4.12'" "$APP_BUILD"; then
  printf '%s\n' "Shake detector unit tests must have an explicit JUnit dependency." >&2
  exit 1
fi

if ! grep -Fq 'buildToolsVersion "24.0.3"' "$APP_BUILD"; then
  printf '%s\n' "Android build-tools must stay pinned to 24.0.3 for 64-bit aapt." >&2
  exit 1
fi

if [ ! -f "$LINT_XML" ]; then
  printf '%s\n' "Legacy lint configuration must be tracked." >&2
  exit 1
fi

if ! grep -Fq '<issue id="LintError" severity="ignore" />' "$LINT_XML"; then
  printf '%s\n' "The legacy lint API-database runner error should be suppressed." >&2
  exit 1
fi

if ! grep -Fq '<issue id="IconMissingDensityFolder" severity="ignore" />' "$LINT_XML"; then
  printf '%s\n' "The nodpi logo density-folder warning should be suppressed." >&2
  exit 1
fi

if [ "$(grep -Fc "ext.enableCrashlytics = false" "$APP_BUILD")" -lt 2 ]; then
  printf '%s\n' "Crashlytics processing must stay disabled for empty-key local builds." >&2
  exit 1
fi

if ! grep -Fq "sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "ShakeActivity must initialize SensorManager before registering listeners." >&2
  exit 1
fi

if ! grep -Fq "R.string.shake_sensor_unavailable" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "Missing shake sensor support must produce resource-backed user feedback." >&2
  exit 1
fi

if ! grep -Fq "sensorManager == null" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "ShakeActivity must handle missing SensorManager service." >&2
  exit 1
fi

if ! grep -Fq "accelerometer == null" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "ShakeActivity must handle missing accelerometer hardware." >&2
  exit 1
fi

if ! grep -Fq "sensorManager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_NORMAL);" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "ShakeActivity must register the accelerometer listener from lifecycle code." >&2
  exit 1
fi

if ! grep -Fq "sensorManager.unregisterListener(this);" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "ShakeActivity must unregister the sensor listener." >&2
  exit 1
fi

if ! grep -Fq "private final ShakeDetector shakeDetector = new ShakeDetector();" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "ShakeActivity must delegate threshold and debounce decisions to ShakeDetector." >&2
  exit 1
fi

if ! grep -Fq "import android.os.SystemClock;" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "ShakeActivity must use Android's monotonic elapsed realtime clock." >&2
  exit 1
fi

if ! grep -Fq "shakeDetector.shouldTrigger(x, y, z, SystemClock.elapsedRealtime())" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "ShakeActivity must route accelerometer values through ShakeDetector with monotonic time." >&2
  exit 1
fi

if grep -Fq "System.currentTimeMillis()" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "Shake debounce timing must not use wall-clock time." >&2
  exit 1
fi

if ! grep -Fq "SHAKE_DEBOUNCE_MILLIS = 200L" "$SHAKE_DETECTOR"; then
  printf '%s\n' "ShakeDetector must preserve the 200ms debounce interval." >&2
  exit 1
fi

if ! grep -Fq "SHAKE_THRESHOLD_GRAVITY = 2.0f" "$SHAKE_DETECTOR"; then
  printf '%s\n' "ShakeDetector must preserve the existing shake threshold." >&2
  exit 1
fi

if ! grep -Fq "lastShakeAtMillis = nowMillis;" "$SHAKE_DETECTOR"; then
  printf '%s\n' "ShakeDetector must update its debounce timestamp after a shake." >&2
  exit 1
fi

if ! grep -Fq "Math.sqrt((x * x) + (y * y) + (z * z))" "$SHAKE_DETECTOR"; then
  if ! grep -Fq "Math.sqrt(accelerationMagnitudeSquared)" "$SHAKE_DETECTOR"; then
    printf '%s\n' "ShakeDetector must compare vector magnitude against the gravity threshold." >&2
    exit 1
  fi
fi

if ! grep -Fq "float accelerationMagnitudeSquared = (x * x) + (y * y) + (z * z);" "$SHAKE_DETECTOR"; then
  printf '%s\n' "ShakeDetector must keep magnitude calculation explicit." >&2
  exit 1
fi

if ! grep -Fq "if (!isFinite(accelerationMagnitudeSquared))" "$SHAKE_DETECTOR"; then
  printf '%s\n' "ShakeDetector must reject overflowed acceleration magnitude." >&2
  exit 1
fi

if ! grep -Fq "hasFiniteAcceleration(x, y, z)" "$SHAKE_DETECTOR"; then
  printf '%s\n' "ShakeDetector must ignore non-finite accelerometer values." >&2
  exit 1
fi

if ! grep -Fq "Float.isNaN(value)" "$SHAKE_DETECTOR" || ! grep -Fq "Float.isInfinite(value)" "$SHAKE_DETECTOR"; then
  printf '%s\n' "ShakeDetector finite checks must reject NaN and infinite values." >&2
  exit 1
fi

if ! grep -Fq "allowsShakeAfterCooldown" "$SHAKE_DETECTOR_TEST"; then
  printf '%s\n' "ShakeDetector unit tests must cover cooldown recovery." >&2
  exit 1
fi

if ! grep -Fq "ignoresMovementBelowConfiguredGravityThreshold" "$SHAKE_DETECTOR_TEST"; then
  printf '%s\n' "ShakeDetector unit tests must cover 1.9g below-threshold movement." >&2
  exit 1
fi

if ! grep -Fq "ignoresNaNAcceleration" "$SHAKE_DETECTOR_TEST" || ! grep -Fq "ignoresInfiniteAcceleration" "$SHAKE_DETECTOR_TEST"; then
  printf '%s\n' "ShakeDetector unit tests must cover non-finite accelerometer values." >&2
  exit 1
fi

if ! grep -Fq "invalidAccelerationDoesNotConsumeDebounceWindow" "$SHAKE_DETECTOR_TEST"; then
  printf '%s\n' "ShakeDetector unit tests must prove invalid values do not consume debounce." >&2
  exit 1
fi

if ! grep -Fq "ignoresOverflowAccelerationMagnitude" "$SHAKE_DETECTOR_TEST"; then
  printf '%s\n' "ShakeDetector unit tests must cover overflowed magnitude inputs." >&2
  exit 1
fi

if ! grep -Fq 'android:allowBackup="false"' "$MANIFEST"; then
  printf '%s\n' "The app must not opt into Android backup by default." >&2
  exit 1
fi

if ! grep -Fq 'android:theme="@style/AppTheme"' "$MANIFEST"; then
  printf '%s\n' "The manifest must use the tracked app theme." >&2
  exit 1
fi

USES_PERMISSION_LINE=$(grep -n '<uses-permission android:name="android.permission.INTERNET"' "$MANIFEST" | cut -d: -f1)
APPLICATION_LINE=$(grep -n '<application' "$MANIFEST" | head -n 1 | cut -d: -f1)
if [ -z "$USES_PERMISSION_LINE" ] || [ -z "$APPLICATION_LINE" ] || [ "$USES_PERMISSION_LINE" -gt "$APPLICATION_LINE" ]; then
  printf '%s\n' "Internet permission must be declared before the application element." >&2
  exit 1
fi

if ! grep -Fq 'private static final String TWITTER_KEY = "";' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Committed Twitter key placeholder must stay empty." >&2
  exit 1
fi

if ! grep -Fq 'private static final String TWITTER_SECRET = "";' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Committed Twitter secret placeholder must stay empty." >&2
  exit 1
fi

if ! grep -Fq "private static boolean hasTwitterCredentials()" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Twitter credential availability must be centralized." >&2
  exit 1
fi

if ! grep -Fq "TWITTER_KEY.length() > 0 && TWITTER_SECRET.length() > 0" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Twitter credentials must require both key and secret before SDK initialization." >&2
  exit 1
fi

if ! grep -Fq "if (!hasTwitterCredentials())" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Empty Twitter credentials must stop login initialization." >&2
  exit 1
fi

if grep -Fq "Do something on failure" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Twitter login failures must not stay as a placeholder comment." >&2
  exit 1
fi

if ! grep -Fq "R.string.twitter_login_failed" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Twitter login failures must show a resource-backed generic message." >&2
  exit 1
fi

if ! grep -Fq "if (loginButton == null)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Twitter login button lookup must be guarded." >&2
  exit 1
fi

if ! grep -Fq "R.string.twitter_login_unavailable" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Missing Twitter login button feedback must use a string resource." >&2
  exit 1
fi

if ! grep -Fq "if (loginButton != null)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Twitter login activity results must only forward to an available button." >&2
  exit 1
fi

if ! grep -Fq 'name="twitter_login_failed"' "$STRINGS"; then
  printf '%s\n' "Twitter login failure message must live in string resources." >&2
  exit 1
fi

if ! grep -Fq 'name="twitter_login_unavailable"' "$STRINGS"; then
  printf '%s\n' "Twitter login unavailable message must live in string resources." >&2
  exit 1
fi

if ! grep -Fq 'name="shake_sensor_unavailable"' "$STRINGS"; then
  printf '%s\n' "Shake sensor unavailable message must live in string resources." >&2
  exit 1
fi

if grep -Fq "exception.printStackTrace()" "$MAIN_ACTIVITY" || grep -Fq "Log." "$MAIN_ACTIVITY"; then
  printf '%s\n' "Twitter login failures must not log exception or session details." >&2
  exit 1
fi

if ! grep -Fq 'android:value=""' "$MANIFEST"; then
  printf '%s\n' "Committed Fabric API key placeholder must stay empty." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/app/src/main/res/drawable-nodpi/logo.png" ]; then
  printf '%s\n' "The legacy bitmap logo must stay in drawable-nodpi." >&2
  exit 1
fi

if [ -f "$ROOT_DIR/app/src/main/res/drawable/logo.png" ]; then
  printf '%s\n' "Bitmap logo must not be tracked in densityless drawable/." >&2
  exit 1
fi

if grep -Fq 'android:background="#31AA39"' "$ACTIVITY_LAYOUT" "$SHAKE_LAYOUT"; then
  printf '%s\n' "Screen background must be provided by the app theme to avoid overdraw." >&2
  exit 1
fi

if ! grep -Fq '<color name="tweet_shake_background">#31AA39</color>' "$COLORS"; then
  printf '%s\n' "Tweet Shake background color must stay in resources." >&2
  exit 1
fi

if ! grep -Fq '<item name="android:windowBackground">@color/tweet_shake_background</item>' "$STYLES"; then
  printf '%s\n' "Base theme must provide the Tweet Shake background." >&2
  exit 1
fi

if ! grep -Fq '<item name="android:windowBackground">@color/tweet_shake_background</item>' "$STYLES_V21"; then
  printf '%s\n' "API 21 theme must provide the Tweet Shake background." >&2
  exit 1
fi

if grep -Fq "Hello world!" "$STRINGS"; then
  printf '%s\n' "Starter template hello_world string must not be tracked." >&2
  exit 1
fi

if grep -Fq 'android:text="Shake to Tweet"' "$SHAKE_LAYOUT"; then
  printf '%s\n' "Shake screen title must use a string resource." >&2
  exit 1
fi

if ! grep -Fq 'android:text="@string/shake_to_tweet_title"' "$SHAKE_LAYOUT"; then
  printf '%s\n' "Shake screen title string resource must be wired into the layout." >&2
  exit 1
fi

if ! grep -Fq 'android:contentDescription="@string/tweet_shake_logo_description"' "$SHAKE_LAYOUT"; then
  printf '%s\n' "Shake logo must have an accessibility description." >&2
  exit 1
fi

if git -C "$ROOT_DIR" ls-files '.idea/*' '*.iml' | grep -q .; then
  printf '%s\n' "Generated IDE metadata must not be tracked." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the baseline check." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the make check wrapper." >&2
  exit 1
fi

if ! grep -Fq "./gradlew lint --no-daemon" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the lint gate." >&2
  exit 1
fi

if ! grep -Fq "./gradlew test --no-daemon" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the unit test gate." >&2
  exit 1
fi

if ! grep -Fq "./gradlew assembleDebug --no-daemon" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the debug assemble gate." >&2
  exit 1
fi

if ! grep -Fq "CHANGES.md" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must point to CHANGES.md." >&2
  exit 1
fi

if ! grep -Fq "empty Twitter credentials stop SDK initialization" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the empty Twitter credential guard." >&2
  exit 1
fi

if ! grep -Fq "Shake debounce uses Android's monotonic elapsed realtime clock" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document monotonic shake debounce timing." >&2
  exit 1
fi

if ! grep -Fq "Overflowed acceleration magnitude is rejected before shake debounce" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document shake magnitude overflow handling." >&2
  exit 1
fi

if ! grep -Fq "Missing shake sensor support shows generic unavailable feedback" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document missing shake sensor feedback." >&2
  exit 1
fi

if ! grep -Fq "GitHub Actions" "$ROOT_DIR/README.md" ||
  ! grep -Fq "docs/plans/2026-06-10-ci-baseline.md" "$ROOT_DIR/README.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project docs must record the GitHub Actions CI baseline." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-tweet-empty-credential-guard.md"; then
  printf '%s\n' "Tweet empty credential guard plan must document make check verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-shake-monotonic-debounce-time.md"; then
  printf '%s\n' "Shake monotonic debounce plan must document make check verification." >&2
  exit 1
fi

if [ ! -f "$MAGNITUDE_OVERFLOW_PLAN" ]; then
  printf '%s\n' "Shake magnitude overflow guard plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$MAGNITUDE_OVERFLOW_PLAN" || ! grep -Fq "make check" "$MAGNITUDE_OVERFLOW_PLAN"; then
  printf '%s\n' "Shake magnitude overflow guard plan must document completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$SENSOR_UNAVAILABLE_PLAN" ]; then
  printf '%s\n' "Shake sensor unavailable feedback plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$SENSOR_UNAVAILABLE_PLAN" || ! grep -Fq "make check" "$SENSOR_UNAVAILABLE_PLAN"; then
  printf '%s\n' "Shake sensor unavailable feedback plan must document completed status and make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CI_PLAN" || ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "CI baseline plan must document completed status and make check verification." >&2
  exit 1
fi

printf '%s\n' "Android Tweet Shake baseline checks passed."
