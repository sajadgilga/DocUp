import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Neuronio/blocs/NotificationBloc.dart';
import 'package:Neuronio/models/NewestNotificationResponse.dart';
import 'package:Neuronio/networking/CustomException.dart';
import 'package:Neuronio/repository/NotificationRepository.dart';
import 'package:Neuronio/ui/mainPage/NotifNavigationRepo.dart';
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
  static NotificationNavigationRepo notifNavRepo;

  static Future initFCM(context, Function onPush) async {
    NotificationAndFirebaseService.context = context;
    NotificationAndFirebaseService.notifNavRepo =
        NotificationNavigationRepo(onPush);
    /// TODO web
    if (!_isFCMConfigured && !kIsWeb) {
      try {
        _firebaseMessaging.configure(
          onMessage: onMessage,
          onBackgroundMessage: myBackgroundMessageHandler,
          onLaunch: onLaunch,
          onResume: onResume,
        );

        if (PlatformDetection.isIOS) {
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
      await _showNotificationWithDefaultSound(notifId, title, body, dataJson);
      BlocProvider.of<NotificationBloc>(context).add(GetNewestNotifications());

      // Map<String, dynamic> data =
      //     new Map<String, dynamic>.from(message['data']);
      // if (data.containsKey('payload')) {
      //   if ([5, 6].contains(data['type'])) {
      //     NewestVisit visit = NewestVisit.fromJson(data['payload']);
      //
      //     /// notification bloc events
      //     // ignore: close_sinks
      //     NotificationBloc notificationBloc =
      //         BlocProvider.of<NotificationBloc>(context);
      //
      //     /// TODO amir: this condition should check type of notification later
      //   } else if (true) {
      //     /// TODO amir: handling event type of notification
      //   }
      // }
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
        notifId, "", "", "00:00:00", "2020/01/01", json.decode(payload), type);

    NotificationAndFirebaseService.notifNavRepo.navigate(context, notif);

    BlocProvider.of<NotificationBloc>(context).add(AddNotifToSeen(notifId));
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
