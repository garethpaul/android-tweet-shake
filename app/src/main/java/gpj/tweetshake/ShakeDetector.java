package gpj.tweetshake;

final class ShakeDetector {
    static final float GRAVITY_EARTH = 9.80665f;
    static final float SHAKE_THRESHOLD_GRAVITY = 2.0f;
    static final long SHAKE_DEBOUNCE_MILLIS = 200L;
    private static final float THRESHOLD_EPSILON = 0.0001f;

    private boolean hasAcceptedShake;
    private long lastShakeAtMillis;

    boolean shouldTrigger(float x, float y, float z, long nowMillis) {
        if (!hasFiniteAcceleration(x, y, z)) {
            return false;
        }

        float accelerationMagnitudeSquared = (x * x) + (y * y) + (z * z);
        if (!isFinite(accelerationMagnitudeSquared)) {
            return false;
        }

        float accelerationGravity = (float) Math.sqrt(accelerationMagnitudeSquared)
                / GRAVITY_EARTH;

        if (accelerationGravity < SHAKE_THRESHOLD_GRAVITY - THRESHOLD_EPSILON) {
            return false;
        }

        if (nowMillis < 0L) {
            return false;
        }

        if (hasAcceptedShake
                && (nowMillis < lastShakeAtMillis
                || nowMillis - lastShakeAtMillis < SHAKE_DEBOUNCE_MILLIS)) {
            return false;
        }

        hasAcceptedShake = true;
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
