package gpj.tweetshake;

final class ShakeSession {
    static final class Registration {
        private Registration() {
        }
    }

    private final ShakeDetector shakeDetector = new ShakeDetector();
    private Registration currentRegistration;
    private boolean registrationSucceeded;
    private boolean shareInProgress;

    Registration beginResume() {
        currentRegistration = new Registration();
        registrationSucceeded = false;
        shareInProgress = false;
        return currentRegistration;
    }

    void completeRegistration(Registration registration, boolean succeeded) {
        if (registration == currentRegistration) {
            registrationSucceeded = succeeded;
        }
    }

    void pause() {
        currentRegistration = null;
        registrationSucceeded = false;
    }

    boolean onSensorSample(
            Registration registration,
            float x,
            float y,
            float z,
            long eventTimeMillis) {
        if (registration != currentRegistration || !registrationSucceeded || shareInProgress) {
            return false;
        }

        if (!shakeDetector.shouldTrigger(x, y, z, eventTimeMillis)) {
            return false;
        }

        return requestShare();
    }

    boolean requestShare() {
        if (currentRegistration == null || shareInProgress) {
            return false;
        }

        shareInProgress = true;
        return true;
    }

    void shareLaunchFailed() {
        shareInProgress = false;
    }
}
