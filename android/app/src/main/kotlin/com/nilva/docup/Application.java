package com.nilva.docup;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;
//import androidx.multidex.MultiDexApplication;
//import android.support.multidex.MultiDexApplication;

public class Application extends FlutterApplication implements PluginRegistrantCallback {

  @Override
  public void onCreate() {
    super.onCreate();
    FlutterFirebaseMessagingService.setPluginRegistrant(this);
  }

  @Override
  public void registerWith(PluginRegistry registry) {
    FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
  }
//  @Override
//  protected void attachBaseContext(Context base) {
//    super.attachBaseContext(base);
//    MultiDex.install(this);
//  }
}