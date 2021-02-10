
import 'dart:io';

import 'package:device_info/device_info.dart';

import 'CrossPlatformDeviceDetection.dart';

Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (CrossPlatformDeviceDetection.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId; // unique ID on Android
  }
}