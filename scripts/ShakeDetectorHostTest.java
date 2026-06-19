package gpj.tweetshake;

public final class ShakeDetectorHostTest {
    private int cases;

    public static void main(String[] args) {
        ShakeDetectorHostTest test = new ShakeDetectorHostTest();
        test.run();
        if (test.cases != 13) {
            throw new AssertionError("Expected 13 cases, ran " + test.cases);
        }
        System.out.println("Portable shake detector tests passed: " + test.cases + " cases.");
    }

    private void run() {
        ignoresMovementBelowThreshold();
        ignoresNaNAcceleration();
        ignoresInfiniteAcceleration();
        invalidAccelerationDoesNotConsumeDebounceWindow();
        ignoresOverflowAccelerationMagnitude();
        triggersAtConfiguredThreshold();
        rejectsAdjacentValueBelowThreshold();
        firstShakeAtMaximumTimestampTriggers();
        backwardTimestampDoesNotReplaceAcceptedShakeTime();
        negativeTimestampDoesNotConsumeDebounceWindow();
        ignoresMovementBelowConfiguredGravityThreshold();
        debouncesConsecutiveShakes();
        allowsShakeAtCooldownBoundary();
    }

    private void ignoresMovementBelowThreshold() {
        ShakeDetector detector = new ShakeDetector();
        expectFalse(detector.shouldTrigger(ShakeDetector.GRAVITY_EARTH, 0f, 0f, 1000L));
        cases++;
    }

    private void ignoresNaNAcceleration() {
        ShakeDetector detector = new ShakeDetector();
        expectFalse(detector.shouldTrigger(Float.NaN, 0f, 0f, 1000L));
        cases++;
    }

    private void ignoresInfiniteAcceleration() {
        ShakeDetector detector = new ShakeDetector();
        expectFalse(detector.shouldTrigger(Float.POSITIVE_INFINITY, 0f, 0f, 1000L));
        cases++;
    }

    private void invalidAccelerationDoesNotConsumeDebounceWindow() {
        ShakeDetector detector = new ShakeDetector();
        float threshold = ShakeDetector.GRAVITY_EARTH * 2f;
        expectFalse(detector.shouldTrigger(Float.NaN, 0f, 0f, 1000L));
        expectTrue(detector.shouldTrigger(threshold, 0f, 0f, 1001L));
        cases++;
    }

    private void ignoresOverflowAccelerationMagnitude() {
        ShakeDetector detector = new ShakeDetector();
        expectFalse(detector.shouldTrigger(
                Float.MAX_VALUE,
                Float.MAX_VALUE,
                Float.MAX_VALUE,
                1000L));
        cases++;
    }

    private void triggersAtConfiguredThreshold() {
        ShakeDetector detector = new ShakeDetector();
        float threshold = ShakeDetector.GRAVITY_EARTH * 2f;
        expectTrue(detector.shouldTrigger(threshold, 0f, 0f, 1000L));
        cases++;
    }

    private void rejectsAdjacentValueBelowThreshold() {
        ShakeDetector detector = new ShakeDetector();
        float threshold = ShakeDetector.GRAVITY_EARTH * 2f;
        float immediatelyBelow = Math.nextAfter(threshold, Float.NEGATIVE_INFINITY);
        expectFalse(detector.shouldTrigger(immediatelyBelow, 0f, 0f, 1000L));
        cases++;
    }

    private void firstShakeAtMaximumTimestampTriggers() {
        ShakeDetector detector = new ShakeDetector();
        float threshold = ShakeDetector.GRAVITY_EARTH * 2f;
        expectTrue(detector.shouldTrigger(threshold, 0f, 0f, Long.MAX_VALUE));
        cases++;
    }

    private void backwardTimestampDoesNotReplaceAcceptedShakeTime() {
        ShakeDetector detector = new ShakeDetector();
        float threshold = ShakeDetector.GRAVITY_EARTH * 2f;
        expectTrue(detector.shouldTrigger(threshold, 0f, 0f, 1000L));
        expectFalse(detector.shouldTrigger(threshold, 0f, 0f, 999L));
        expectTrue(detector.shouldTrigger(threshold, 0f, 0f, 1200L));
        cases++;
    }

    private void negativeTimestampDoesNotConsumeDebounceWindow() {
        ShakeDetector detector = new ShakeDetector();
        float threshold = ShakeDetector.GRAVITY_EARTH * 2f;
        expectFalse(detector.shouldTrigger(threshold, 0f, 0f, -1L));
        expectTrue(detector.shouldTrigger(threshold, 0f, 0f, 0L));
        cases++;
    }

    private void ignoresMovementBelowConfiguredGravityThreshold() {
        ShakeDetector detector = new ShakeDetector();
        float belowThreshold = ShakeDetector.GRAVITY_EARTH * 1.9f;
        expectFalse(detector.shouldTrigger(belowThreshold, 0f, 0f, 1000L));
        cases++;
    }

    private void debouncesConsecutiveShakes() {
        ShakeDetector detector = new ShakeDetector();
        float threshold = ShakeDetector.GRAVITY_EARTH * 2f;
        expectTrue(detector.shouldTrigger(threshold, 0f, 0f, 1000L));
        expectFalse(detector.shouldTrigger(threshold, 0f, 0f, 1199L));
        cases++;
    }

    private void allowsShakeAtCooldownBoundary() {
        ShakeDetector detector = new ShakeDetector();
        float threshold = ShakeDetector.GRAVITY_EARTH * 2f;
        expectTrue(detector.shouldTrigger(threshold, 0f, 0f, 1000L));
        expectTrue(detector.shouldTrigger(threshold, 0f, 0f, 1200L));
        cases++;
    }

    private static void expectTrue(boolean value) {
        if (!value) {
            throw new AssertionError("Expected true");
        }
    }

    private static void expectFalse(boolean value) {
        if (value) {
            throw new AssertionError("Expected false");
        }
    }
}
