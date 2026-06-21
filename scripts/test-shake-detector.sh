#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(dirname -- "$0")
case $SCRIPT_DIR in
  /*) ROOT_DIR=$(CDPATH='' cd "$SCRIPT_DIR/.." && pwd) ;;
  *) ROOT_DIR=$(CDPATH='' cd "./$SCRIPT_DIR/.." && pwd) ;;
esac
OUTPUT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/tweet-shake-detector.XXXXXX")
cleanup() {
  if [ -d "$OUTPUT_DIR" ]; then
    rm -rf -- "$OUTPUT_DIR"
  fi
}
trap cleanup EXIT
trap 'cleanup; exit 1' HUP INT TERM

JAVAC=${JAVAC:-javac}
JAVA=${JAVA:-java}

"$JAVAC" -source 1.7 -target 1.7 -Xlint:-options \
  -d "$OUTPUT_DIR" \
  "$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeDetector.java" \
  "$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeSession.java" \
  "$ROOT_DIR/scripts/ShakeDetectorHostTest.java" \
  "$ROOT_DIR/scripts/ShakeSessionHostTest.java"

"$JAVA" -cp "$OUTPUT_DIR" gpj.tweetshake.ShakeDetectorHostTest
"$JAVA" -cp "$OUTPUT_DIR" gpj.tweetshake.ShakeSessionHostTest
