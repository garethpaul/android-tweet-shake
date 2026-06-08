package gpj.tweetshake;

final class ShakeDetector {
    static final float GRAVITY_EARTH = 9.80665f;
    static final float SHAKE_THRESHOLD_GRAVITY = 2.0f;
    static final long SHAKE_DEBOUNCE_MILLIS = 200L;
    private static final float THRESHOLD_EPSILON = 0.0001f;

    private long lastShakeAtMillis = -SHAKE_DEBOUNCE_MILLIS;

    boolean shouldTrigger(float x, float y, float z, long nowMillis) {
        if (!hasFiniteAcceleration(x, y, z)) {
            return false;
        }

        float accelerationGravity = (float) Math.sqrt((x * x) + (y * y) + (z * z))
                / GRAVITY_EARTH;

        if (accelerationGravity < SHAKE_THRESHOLD_GRAVITY - THRESHOLD_EPSILON) {
            return false;
        }

        if (nowMillis - lastShakeAtMillis < SHAKE_DEBOUNCE_MILLIS) {
            return false;
        }

        lastShakeAtMillis = nowMillis;
        return true;
    }

    private static boolean hasFiniteAcceleration(float x, float y, float z) {
        return isFinite(x) && isFinite(y) && isFinite(z);
    }

    private static boolean isFinite(float value) {
        return !Float.isNaN(value) && !Float.isInfinite(value);
    }
}
