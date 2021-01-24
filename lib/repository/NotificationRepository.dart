import 'dart:io';

import 'package:docup/blocs/NotificationBloc.dart';
import 'package:docup/models/FCMEntity.dart';
import 'package:docup/models/NewestNotificationResponse.dart';
import 'package:docup/networking/ApiProvider.dart';
import 'package:docup/utils/CrossPlatformDeviceDetection.dart';
import 'package:docup/utils/Device.dart';
import 'package:flutter/foundation.dart';

class NotificationRepository {
  ApiProvider _provider = ApiProvider();

  Future<RegisterDeviceResponse> registerDevice(String fcmToken) async {
    try {
      final deviceId = await getDeviceId();
      final response = await _provider.post("devices/", body: {
        "registration_id": fcmToken,
        "type": PlatformDetection.isWeb ? 'web' : (PlatformDetection.isAndroid ? "android" : "ios"),
        "device_id": deviceId
      });
      return RegisterDeviceResponse.fromJson(response);
    } catch (_) {
      print('problem in register device');
    }
  }

  Future<NewestNotificationResponse> getNewestNotifications() async {
    final response =
        await _provider.get('api/newest-notifications', utf8Support: true);
    return NewestNotificationResponse.fromJson(response);
  }

  Future<AddToSeenResponse> addNotifToSeen(int notifId) async {
    final response =
        await _provider.patch('api/newest-notifications/?notif_id=$notifId');
    return AddToSeenResponse.fromJson(response);
  }
}
