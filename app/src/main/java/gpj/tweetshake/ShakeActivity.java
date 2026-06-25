package gpj.tweetshake;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.Toast;

import java.util.concurrent.TimeUnit;

public class ShakeActivity extends Activity {

    private final ShakeSession shakeSession = new ShakeSession();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private SensorManager sensorManager;
    private Sensor accelerometer;
    private SensorEventListener sensorListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.shake_main);
        sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        if (sensorManager == null) {
            showSensorUnavailable();
            return;
        }

        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        if (accelerometer == null) {
            showSensorUnavailable();
        }
    }

    private SensorEventListener createSensorListener(
            final ShakeSession.Registration registration) {
        return new SensorEventListener() {
            @Override
            public void onSensorChanged(SensorEvent event) {
                checkShake(registration, event);
            }

            @Override
            public void onAccuracyChanged(Sensor sensor, int accuracy) {
            }
        };
    }

    private void checkShake(ShakeSession.Registration registration, SensorEvent event) {
        if (event == null || event.values == null || event.values.length < 3) {
            return;
        }

        long eventTimeMillis = TimeUnit.NANOSECONDS.toMillis(event.timestamp);
        if (shakeSession.onSensorSample(
                registration,
                event.values[0],
                event.values[1],
                event.values[2],
                eventTimeMillis)) {
            showShareComposer();
        }
    }

    public void onShareRequested(View view) {
        if (shakeSession.requestShare()) {
            showShareComposer();
        }
    }

    private void showShareComposer() {
        if (isFinishing() || isDestroyed()) {
            shakeSession.shareLaunchFailed();
            return;
        }

        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setType("text/plain");
        shareIntent.putExtra(Intent.EXTRA_TEXT, getString(R.string.share_text));
        try {
            startActivity(Intent.createChooser(
                    shareIntent,
                    getString(R.string.share_chooser_title)));
        } catch (ActivityNotFoundException exception) {
            recoverFromShareLaunchFailure();
        } catch (SecurityException exception) {
            recoverFromShareLaunchFailure();
        }
    }

    private void recoverFromShareLaunchFailure() {
        shakeSession.shareLaunchFailed();
        showShareUnavailable();
    }

    private void showSensorUnavailable() {
        Toast.makeText(this, R.string.shake_sensor_unavailable, Toast.LENGTH_SHORT).show();
    }

    private void showShareUnavailable() {
        Toast.makeText(this, R.string.share_unavailable, Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onResume() {
        super.onResume();
        ShakeSession.Registration registration = shakeSession.beginResume();
        if (sensorManager == null || accelerometer == null) {
            return;
        }

        SensorEventListener listener = createSensorListener(registration);
        sensorListener = listener;
        boolean registered = sensorManager.registerListener(
                listener,
                accelerometer,
                SensorManager.SENSOR_DELAY_NORMAL,
                mainHandler);
        shakeSession.completeRegistration(registration, registered);
        if (!registered) {
            sensorListener = null;
            showSensorUnavailable();
        }
    }

    @Override
    protected void onPause() {
        shakeSession.pause();
        SensorEventListener listener = sensorListener;
        sensorListener = null;
        if (sensorManager != null && listener != null) {
            sensorManager.unregisterListener(listener);
        }
        super.onPause();
    }
}
