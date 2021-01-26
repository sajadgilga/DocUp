import 'dart:io';

import 'package:Neuronio/blocs/NotificationBloc.dart';
import 'package:Neuronio/models/FCMEntity.dart';
import 'package:Neuronio/models/NewestNotificationResponse.dart';
import 'package:Neuronio/networking/ApiProvider.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/Device.dart';
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
