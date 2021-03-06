import 'dart:async';
import 'dart:convert';

import 'package:Neuronio/blocs/NotificationBloc.dart';
import 'package:Neuronio/models/NewestNotificationResponse.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/CustomException.dart';
import 'package:Neuronio/repository/NotificationRepository.dart';
import 'package:Neuronio/services/NotificationNavigationService.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationAndFirebaseService {
  static final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static BuildContext context;
  static bool _isFCMConfigured = false;
  static NotificationNavigationService notifNavRepo;
  static MapEntry<String, Map> currentPageAndData;

  static Future initFCM(context, Function onPush) async {
    NotificationAndFirebaseService.context = context;
    NotificationAndFirebaseService.notifNavRepo =
        NotificationNavigationService(onPush);

    /// TODO web
    if (!_isFCMConfigured && !kIsWeb) {
      try {
        _firebaseMessaging.configure(
          onMessage: onMessage,
          onBackgroundMessage: myBackgroundMessageHandler,
          onLaunch: onLaunch,
          onResume: onResume,
        );

        if (CrossPlatformDeviceDetection.isIOS) {
          _firebaseMessaging.requestNotificationPermissions(
              const IosNotificationSettings(
                  sound: true, badge: true, alert: true, provisional: true));
          _firebaseMessaging.onIosSettingsRegistered
              .listen((IosNotificationSettings settings) {
            print("Settings registered: $settings");
          });
        }

        _firebaseMessaging.getToken().then((String fcmToken) {
          assert(fcmToken != null);
          print("FCM " + fcmToken);
          try {
            NotificationRepository().registerDevice(fcmToken);
          } on BadRequestException {
            print('error');
            _isFCMConfigured = true;
            return;
          } catch (_) {
            print('register device failed fcm');
            _isFCMConfigured = true;
            return;
          }
        });

        var initializationSettingsAndroid =
            new AndroidInitializationSettings('mipmap/ic_launcher');
        var initializationSettingsIOS = new IOSInitializationSettings();

        var initializationSettings = new InitializationSettings(
            initializationSettingsAndroid, initializationSettingsIOS);

        flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
        flutterLocalNotificationsPlugin.initialize(initializationSettings,
            onSelectNotification: onSelectNotification);
      } catch (_) {
        print("oh oh");
        _isFCMConfigured = true;
        return;
      }
    }
  }

  static Future<dynamic> onResume(Map<String, dynamic> message) async {
    print("onResume: $message");

    Map<String, dynamic> data = new Map<String, dynamic>.from(message['data']);
    handleNotifNavigation(intPossible(data['notif_id']), data['payload'],
        intPossible(data['type']));
  }

  static Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    print("onLaunch: $message");

    Map<String, dynamic> data = new Map<String, dynamic>.from(message['data']);
    handleNotifNavigation(intPossible(data['notif_id']), data['payload'],
        intPossible(data['type']));
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    print("onBackgroundMessageHandler: $message");
    Map<String, dynamic> data = new Map<String, dynamic>.from(message['data']);
    handleNotifNavigation(intPossible(data['notif_id']), data['payload'],
        intPossible(data['type']));

    // Or do other work.
  }

  static Future<dynamic> onMessage(Map<String, dynamic> message) async {
    try {
      print("onMessage: $message");
      String title = message['notification']['title'];
      String body = message['notification']['body'];
      String dataJson = json.encode(message['data']);
      int notifId = intPossible(message['data']['notif_id']);
      int type = intPossible(message['data']['type']);
      Map payloadMap = json.decode(message['data']['payload'].isEmpty
          ? "{}"
          : message['data']['payload']);

      /// TODO filter notification to be shown; prevent from showing message if current page is chat page
      if (type == 10 && currentPageAndData?.key == "_ChatPageState") {
        if ((currentPageAndData.value['entity'] as Entity).iPanelId !=
            intPossible(payloadMap['panel_id'])) {
          await _showNotificationWithDefaultSound(
              notifId, title, body, dataJson);
        }
      } else {
        await _showNotificationWithDefaultSound(notifId, title, body, dataJson);
      }
    } catch (e) {
      print(e.toString());
    } finally {
      BlocProvider.of<NotificationBloc>(context).add(GetNewestNotifications());
    }
  }

  static Future onSelectNotification(String payload) async {
    try {
      print("OnSelection: $payload");
      var jsonBody = json.decode(payload);

      int type = intPossible(jsonBody['type']);
      int notifId = intPossible(jsonBody['notif_id']);
      String pPayload = jsonBody['payload'];
      handleNotifNavigation(notifId, pPayload, type);
    } catch (e) {
      print("OnNotification Tap Error:" + e.toString());
    }
  }

  static void handleNotifNavigation(int notifId, String payload, int type,
      {String title, String description, String time, String date}) {
    NewestNotif notif = NewestNotif.getChildFromJsonAndData(
        notifId,
        "",
        "",
        "00:00:00",
        "2020/01/01",
        json.decode(payload.isEmpty ? "{}" : payload),
        type,
        false);

    NotificationAndFirebaseService.notifNavRepo.navigate(context, notif);

    // BlocProvider.of<NotificationBloc>(context).add(AddNotifToSeen(notifId));
  }

  static Future _showNotificationWithDefaultSound(
      int notifId, String title, String body, String payload) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notifId,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
