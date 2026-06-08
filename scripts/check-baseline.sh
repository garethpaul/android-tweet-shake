#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ROOT_BUILD="$ROOT_DIR/build.gradle"
APP_BUILD="$ROOT_DIR/app/build.gradle"
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/gpj/tweetshake/MainActivity.java"
SHAKE_ACTIVITY="$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeActivity.java"
SHAKE_DETECTOR="$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeDetector.java"
SHAKE_DETECTOR_TEST="$ROOT_DIR/app/src/test/java/gpj/tweetshake/ShakeDetectorTest.java"
MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"

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

if [ "$(grep -Fc "ext.enableCrashlytics = false" "$APP_BUILD")" -lt 2 ]; then
  printf '%s\n' "Crashlytics processing must stay disabled for empty-key local builds." >&2
  exit 1
fi

if ! grep -Fq "sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "ShakeActivity must initialize SensorManager before registering listeners." >&2
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

if ! grep -Fq "shakeDetector.shouldTrigger(x, y, z, System.currentTimeMillis())" "$SHAKE_ACTIVITY"; then
  printf '%s\n' "ShakeActivity must route accelerometer values through ShakeDetector." >&2
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

if ! grep -Fq "allowsShakeAfterCooldown" "$SHAKE_DETECTOR_TEST"; then
  printf '%s\n' "ShakeDetector unit tests must cover cooldown recovery." >&2
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

if ! grep -Fq 'android:value=""' "$MANIFEST"; then
  printf '%s\n' "Committed Fabric API key placeholder must stay empty." >&2
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

printf '%s\n' "Android Tweet Shake baseline checks passed."
