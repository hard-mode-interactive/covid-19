package com.hardmodeinteractive.coronavirus;


import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.location.Location;
import android.os.IBinder;
import android.preference.PreferenceManager;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import android.Manifest;

import android.content.pm.PackageManager;

import android.net.Uri;

import android.provider.Settings;
import androidx.annotation.NonNull;
import com.google.android.material.snackbar.Snackbar;
import androidx.core.app.ActivityCompat;

import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import java.util.Iterator;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class  MainActivity extends FlutterActivity implements
        SharedPreferences.OnSharedPreferenceChangeListener {
  private static final String TAG = MainActivity.class.getSimpleName();

  // Used in checking for runtime permissions.
  private static final int REQUEST_PERMISSIONS_REQUEST_CODE = 34;

  // The BroadcastReceiver used to listen from broadcasts from the service.
  private MyReceiver myReceiver;

  // A reference to the service used to get location updates.
  private LocationUpdatesService mService = null;

  // Tracks the bound state of the service.
  private boolean mBound = false;

  // UI elements.
//  private Button mRequestLocationUpdatesButton;
//  private Button mRemoveLocationUpdatesButton;

  // Monitors the state of the connection to the service.
  private final ServiceConnection mServiceConnection = new ServiceConnection() {

    @Override
    public void onServiceConnected(ComponentName name, IBinder service) {
      LocationUpdatesService.LocalBinder binder = (LocationUpdatesService.LocalBinder) service;
      mService = binder.getService();

      mBound = true;
    }

    @Override
    public void onServiceDisconnected(ComponentName name) {
      mService = null;
      mBound = false;
    }
  };

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    myReceiver = new MyReceiver();

    boolean requestingLocationUpdates = Utils.requestingLocationUpdates(this);


    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),"com.murgasmedia.messages")
            .setMethodCallHandler(new MethodChannel.MethodCallHandler() {

              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if(call.method.equals("startService")){
                  String userUid = call.argument("userUid");
                  mService.userUid = userUid;

                  if (!checkPermissions()) {
          requestPermissions(userUid);
        } else {
          mService.requestLocationUpdates();
        }
                }

                if(call.method.equals("stopService")){
                  mService.stopServiceFromChannel();
                }
                if(call.method.equals("serviceState")){
                  result.success(requestingLocationUpdates);
                }
              }
            });

  }

  @Override
  protected void onStart() {
    super.onStart();
    PreferenceManager.getDefaultSharedPreferences(this)
            .registerOnSharedPreferenceChangeListener(this);

    bindService(new Intent(this, LocationUpdatesService.class), mServiceConnection,
            Context.BIND_AUTO_CREATE);
  }



  @Override
  protected void onResume() {
    super.onResume();
    LocalBroadcastManager.getInstance(this).registerReceiver(myReceiver,
            new IntentFilter(LocationUpdatesService.ACTION_BROADCAST));
  }

  @Override
  protected void onPause() {
    LocalBroadcastManager.getInstance(this).unregisterReceiver(myReceiver);
    super.onPause();
  }

  @Override
  protected void onStop() {
    if (mBound) {
      // Unbind from the service. This signals to the service that this activity is no longer
      // in the foreground, and the service can respond by promoting itself to a foreground
      // service.
      unbindService(mServiceConnection);
      mBound = false;
    }
    PreferenceManager.getDefaultSharedPreferences(this)
            .unregisterOnSharedPreferenceChangeListener(this);

    super.onStop();
  }

  /**
   * Returns the current state of the permissions needed.
   */
  private boolean checkPermissions() {
    return  PackageManager.PERMISSION_GRANTED == ActivityCompat.checkSelfPermission(this,
            Manifest.permission.ACCESS_FINE_LOCATION);
  }

  private void requestPermissions(String userUid) {
    boolean shouldProvideRationale =
            ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.ACCESS_FINE_LOCATION);

    // Provide an additional rationale to the user. This would happen if the user denied the
    // request previously, but didn't check the "Don't ask again" checkbox.
    if (shouldProvideRationale) {
      Log.i(TAG, "Displaying permission rationale to provide additional context.");
      ActivityCompat.requestPermissions(MainActivity.this,
              new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
              REQUEST_PERMISSIONS_REQUEST_CODE);

    } else {
      Log.i(TAG, "Requesting permission");
      // Request permission. It's possible this can be auto answered if device policy
      // sets the permission in a given state or the user denied the permission
      // previously and checked "Never ask again".
      ActivityCompat.requestPermissions(MainActivity.this,
              new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
              REQUEST_PERMISSIONS_REQUEST_CODE);
    }
  }

  /**
   * Callback received when a permissions request has been completed.
   */



  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                         @NonNull int[] grantResults,String userUid) {
    Log.i(TAG, "onRequestPermissionResult");
    if (requestCode == REQUEST_PERMISSIONS_REQUEST_CODE) {
      if (grantResults.length <= 0) {
        // If user interaction was interrupted, the permission request is cancelled and you
        // receive empty arrays.
        Log.i(TAG, "User interaction was cancelled.");
      } else if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        // Permission was granted.
        mService.requestLocationUpdates();

      } else {
        // Permission denied.

      }
    }
  }

  /**
   * Receiver for broadcasts sent by {@link LocationUpdatesService}.
   */
  private class MyReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
      Location location = intent.getParcelableExtra(LocationUpdatesService.EXTRA_LOCATION);
      if (location != null) {
        Toast.makeText(MainActivity.this, "Tracking activado",
                Toast.LENGTH_SHORT).show();
      }
    }
  }

  @Override
  public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String s) {
    // Update the buttons state depending on whether location updates are being requested.
    if (s.equals(Utils.KEY_REQUESTING_LOCATION_UPDATES)) {
      // return sharedPreferences.getBoolean(Utils.KEY_REQUESTING_LOCATION_UPDATES,false);
    }
  }





}