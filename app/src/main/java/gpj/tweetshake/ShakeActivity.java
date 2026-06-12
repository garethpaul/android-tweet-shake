package gpj.tweetshake;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.SystemClock;
import android.widget.Toast;

public class ShakeActivity extends Activity implements SensorEventListener {

    private SensorManager sensorManager;
    private Sensor accelerometer;
    private final ShakeDetector shakeDetector = new ShakeDetector();
    private boolean sensorRegistered;
    private boolean shareInProgress;
    private boolean activityResumed;

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

    private void checkShake(SensorEvent event) {
        if (!activityResumed) {
            return;
        }

        if (event == null || event.values == null || event.values.length < 3) {
            return;
        }

        float x = event.values[0];
        float y = event.values[1];
        float z = event.values[2];

        if (shakeDetector.shouldTrigger(x, y, z, SystemClock.elapsedRealtime())) {
            showShareComposer();
        }
    }

    private void showShareComposer() {
        if (shareInProgress || isFinishing() || isDestroyed()) {
            return;
        }

        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setType("text/plain");
        shareIntent.putExtra(Intent.EXTRA_TEXT, getString(R.string.share_text));
        shareInProgress = true;
        try {
            startActivity(Intent.createChooser(
                    shareIntent,
                    getString(R.string.share_chooser_title)));
        } catch (ActivityNotFoundException exception) {
            shareInProgress = false;
            showShareUnavailable();
        }
    }

    private void showSensorUnavailable() {
        Toast.makeText(this, R.string.shake_sensor_unavailable, Toast.LENGTH_SHORT).show();
    }

    private void showShareUnavailable() {
        Toast.makeText(this, R.string.share_unavailable, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        checkShake(event);
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    @Override
    protected void onResume() {
        super.onResume();
        activityResumed = true;
        shareInProgress = false;
        if (sensorManager != null && accelerometer != null) {
            sensorRegistered = sensorManager.registerListener(
                    this,
                    accelerometer,
                    SensorManager.SENSOR_DELAY_NORMAL);
            if (!sensorRegistered) {
                showSensorUnavailable();
            }
        }
    }

    @Override
    protected void onPause() {
        activityResumed = false;
        if (sensorManager != null && sensorRegistered) {
            sensorManager.unregisterListener(this);
            sensorRegistered = false;
        }
        super.onPause();
    }
}
