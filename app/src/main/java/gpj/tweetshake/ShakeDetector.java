package gpj.tweetshake;

final class ShakeDetector {
    static final float GRAVITY_EARTH = 9.80665f;
    static final float SHAKE_THRESHOLD_GRAVITY = 2.0f;
    static final long SHAKE_DEBOUNCE_MILLIS = 200L;
    private static final float THRESHOLD_EPSILON = 0.0001f;

    private long lastShakeAtMillis = -SHAKE_DEBOUNCE_MILLIS;

    boolean shouldTrigger(float x, float y, float z, long nowMillis) {
        float accelerationRatio = ((x * x) + (y * y) + (z * z))
                / (GRAVITY_EARTH * GRAVITY_EARTH);

        if (accelerationRatio < SHAKE_THRESHOLD_GRAVITY - THRESHOLD_EPSILON) {
            return false;
        }

        if (nowMillis - lastShakeAtMillis < SHAKE_DEBOUNCE_MILLIS) {
            return false;
        }

        lastShakeAtMillis = nowMillis;
        return true;
    }
}
