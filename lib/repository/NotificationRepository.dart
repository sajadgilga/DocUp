
import 'dart:io';

import 'package:docup/models/FCMEntity.dart';
import 'package:docup/networking/ApiProvider.dart';
import 'package:docup/utils/Device.dart';

class NotificationRepository {
  ApiProvider _provider = ApiProvider();

  Future<RegisterDeviceResponse> registerDevice(String fcmToken) async {
    final deviceId = await getDeviceId();
    final response = await _provider.post("devices/",
    body: {
      "registration_id" : fcmToken,
      "type" : Platform.isAndroid ? "android" : "ios",
      "device_id" : deviceId});
    return RegisterDeviceResponse.fromJson(response);
  }


}
