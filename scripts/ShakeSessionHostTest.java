package gpj.tweetshake;

public final class ShakeSessionHostTest {
    private int cases;

    public static void main(String[] args) {
        ShakeSessionHostTest test = new ShakeSessionHostTest();
        test.run();
        if (test.cases != 12) {
            throw new AssertionError("Expected 12 cases, ran " + test.cases);
        }
        System.out.println("Portable shake session tests passed: " + test.cases + " cases.");
    }

    private void run() {
        rejectsCallbacksBeforeRegistrationCompletes();
        failedRegistrationNeverOwnsCallbacks();
        pauseInvalidatesQueuedCallbacks();
        lateRegistrationResultCannotReactivatePausedSession();
        staleCallbacksStayInvalidAfterResume();
        staleRegistrationResultCannotClaimNewResume();
        acceptedShakeLocksShareLaunchAtomically();
        failedShareLaunchAllowsRetry();
        resumeClearsPreviousShareLock();
        manualShareWorksWithoutSensorRegistration();
        manualShareRespectsLifecycleAndDuplicateLock();
        failedManualShareAllowsRetry();
    }

    private void rejectsCallbacksBeforeRegistrationCompletes() {
        ShakeSession session = new ShakeSession();
        ShakeSession.Registration registration = session.beginResume();
        expectFalse(session.onSensorSample(registration, threshold(), 0f, 0f, 1000L));
        cases++;
    }

    private void failedRegistrationNeverOwnsCallbacks() {
        ShakeSession session = new ShakeSession();
        ShakeSession.Registration registration = session.beginResume();
        session.completeRegistration(registration, false);
        expectFalse(session.onSensorSample(registration, threshold(), 0f, 0f, 1000L));
        cases++;
    }

    private void pauseInvalidatesQueuedCallbacks() {
        ActiveSession active = activeSession();
        active.session.pause();
        expectFalse(active.session.onSensorSample(
                active.registration, threshold(), 0f, 0f, 1000L));
        cases++;
    }

    private void lateRegistrationResultCannotReactivatePausedSession() {
        ShakeSession session = new ShakeSession();
        ShakeSession.Registration registration = session.beginResume();
        session.pause();
        session.completeRegistration(registration, true);
        expectFalse(session.onSensorSample(registration, threshold(), 0f, 0f, 1000L));
        cases++;
    }

    private void staleCallbacksStayInvalidAfterResume() {
        ActiveSession active = activeSession();
        active.session.pause();
        ShakeSession.Registration currentRegistration = active.session.beginResume();
        active.session.completeRegistration(currentRegistration, true);
        expectFalse(active.session.onSensorSample(
                active.registration, threshold(), 0f, 0f, 1000L));
        expectTrue(active.session.onSensorSample(
                currentRegistration, threshold(), 0f, 0f, 1000L));
        cases++;
    }

    private void staleRegistrationResultCannotClaimNewResume() {
        ShakeSession session = new ShakeSession();
        ShakeSession.Registration staleRegistration = session.beginResume();
        session.pause();
        ShakeSession.Registration currentRegistration = session.beginResume();
        session.completeRegistration(staleRegistration, true);
        expectFalse(session.onSensorSample(currentRegistration, threshold(), 0f, 0f, 1000L));
        cases++;
    }

    private void acceptedShakeLocksShareLaunchAtomically() {
        ActiveSession active = activeSession();
        expectTrue(active.session.onSensorSample(
                active.registration, threshold(), 0f, 0f, 1000L));
        expectFalse(active.session.onSensorSample(
                active.registration, threshold(), 0f, 0f, 1200L));
        cases++;
    }

    private void failedShareLaunchAllowsRetry() {
        ActiveSession active = activeSession();
        expectTrue(active.session.onSensorSample(
                active.registration, threshold(), 0f, 0f, 1000L));
        active.session.shareLaunchFailed();
        expectTrue(active.session.onSensorSample(
                active.registration, threshold(), 0f, 0f, 1200L));
        cases++;
    }

    private void resumeClearsPreviousShareLock() {
        ActiveSession active = activeSession();
        expectTrue(active.session.onSensorSample(
                active.registration, threshold(), 0f, 0f, 1000L));
        active.session.pause();
        ShakeSession.Registration nextRegistration = active.session.beginResume();
        active.session.completeRegistration(nextRegistration, true);
        expectTrue(active.session.onSensorSample(
                nextRegistration, threshold(), 0f, 0f, 1200L));
        cases++;
    }

    private void manualShareWorksWithoutSensorRegistration() {
        ShakeSession session = new ShakeSession();
        session.beginResume();

        expectTrue(session.requestShare());
        cases++;
    }

    private void manualShareRespectsLifecycleAndDuplicateLock() {
        ShakeSession session = new ShakeSession();
        expectFalse(session.requestShare());
        session.beginResume();
        expectTrue(session.requestShare());
        expectFalse(session.requestShare());
        session.pause();
        expectFalse(session.requestShare());
        cases++;
    }

    private void failedManualShareAllowsRetry() {
        ShakeSession session = new ShakeSession();
        session.beginResume();
        expectTrue(session.requestShare());
        session.shareLaunchFailed();
        expectTrue(session.requestShare());
        cases++;
    }

    private static ActiveSession activeSession() {
        ShakeSession session = new ShakeSession();
        ShakeSession.Registration registration = session.beginResume();
        session.completeRegistration(registration, true);
        return new ActiveSession(session, registration);
    }

    private static float threshold() {
        return ShakeDetector.GRAVITY_EARTH * ShakeDetector.SHAKE_THRESHOLD_GRAVITY;
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

    private static final class ActiveSession {
        private final ShakeSession session;
        private final ShakeSession.Registration registration;

        private ActiveSession(ShakeSession session, ShakeSession.Registration registration) {
            this.session = session;
            this.registration = registration;
        }
    }
}
