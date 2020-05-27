
import 'dart:io';

import 'package:DocUp/models/FCMEntity.dart';
import 'package:DocUp/models/NewestNotificationResponse.dart';
import 'package:DocUp/networking/ApiProvider.dart';
import 'package:DocUp/utils/Device.dart';

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
  
  Future<NewestNotificationResponse> getNewestNotifications() async {
    final response = await _provider.get('api/newest-notifications', utf8Support: true);
    return NewestNotificationResponse.fromJson(response);
  }


}
