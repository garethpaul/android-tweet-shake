#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUTPUT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/tweet-shake-detector.XXXXXX")
cleanup() {
  if [ -d "$OUTPUT_DIR" ]; then
    rm -rf -- "$OUTPUT_DIR"
  fi
}
trap cleanup EXIT
trap 'cleanup; exit 1' HUP INT TERM

javac -source 1.7 -target 1.7 -Xlint:-options \
  -d "$OUTPUT_DIR" \
  "$ROOT_DIR/app/src/main/java/gpj/tweetshake/ShakeDetector.java" \
  "$ROOT_DIR/scripts/ShakeDetectorHostTest.java"

java -cp "$OUTPUT_DIR" gpj.tweetshake.ShakeDetectorHostTest
