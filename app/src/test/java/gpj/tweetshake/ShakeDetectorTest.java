package gpj.tweetshake;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class ShakeDetectorTest {

    @Test
    public void ignoresMovementBelowThreshold() {
        ShakeDetector detector = new ShakeDetector();

        assertFalse(detector.shouldTrigger(ShakeDetector.GRAVITY_EARTH, 0f, 0f, 1000L));
    }

    @Test
    public void ignoresNaNAcceleration() {
        ShakeDetector detector = new ShakeDetector();

        assertFalse(detector.shouldTrigger(Float.NaN, 0f, 0f, 1000L));
    }

    @Test
    public void ignoresInfiniteAcceleration() {
        ShakeDetector detector = new ShakeDetector();

        assertFalse(detector.shouldTrigger(Float.POSITIVE_INFINITY, 0f, 0f, 1000L));
    }

    @Test
    public void invalidAccelerationDoesNotConsumeDebounceWindow() {
        ShakeDetector detector = new ShakeDetector();
        float thresholdAcceleration = ShakeDetector.GRAVITY_EARTH * 2f;

        assertFalse(detector.shouldTrigger(Float.NaN, 0f, 0f, 1000L));
        assertTrue(detector.shouldTrigger(thresholdAcceleration, 0f, 0f, 1001L));
    }

    @Test
    public void triggersAboveThreshold() {
        ShakeDetector detector = new ShakeDetector();
        float thresholdAcceleration = ShakeDetector.GRAVITY_EARTH * 2f;

        assertTrue(detector.shouldTrigger(thresholdAcceleration, 0f, 0f, 1000L));
    }

    @Test
    public void ignoresMovementBelowConfiguredGravityThreshold() {
        ShakeDetector detector = new ShakeDetector();
        float belowThresholdAcceleration = ShakeDetector.GRAVITY_EARTH * 1.9f;

        assertFalse(detector.shouldTrigger(belowThresholdAcceleration, 0f, 0f, 1000L));
    }

    @Test
    public void debouncesConsecutiveShakes() {
        ShakeDetector detector = new ShakeDetector();
        float thresholdAcceleration = ShakeDetector.GRAVITY_EARTH * 2f;

        assertTrue(detector.shouldTrigger(thresholdAcceleration, 0f, 0f, 1000L));
        assertFalse(detector.shouldTrigger(thresholdAcceleration, 0f, 0f, 1199L));
    }

    @Test
    public void allowsShakeAfterCooldown() {
        ShakeDetector detector = new ShakeDetector();
        float thresholdAcceleration = ShakeDetector.GRAVITY_EARTH * 2f;

        assertTrue(detector.shouldTrigger(thresholdAcceleration, 0f, 0f, 1000L));
        assertTrue(detector.shouldTrigger(thresholdAcceleration, 0f, 0f, 1200L));
    }
}
