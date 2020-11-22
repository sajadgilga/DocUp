import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:docup/blocs/NotificationBloc.dart';
import 'package:docup/models/NewestNotificationResponse.dart';
import 'package:docup/networking/CustomException.dart';
import 'package:docup/repository/NotificationRepository.dart';
import 'package:docup/ui/mainPage/CallRepo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationAndFirebaseService{
  static final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static BuildContext context;
  static bool _isFCMConfigured = false;

  static Future initFCM(context) async {
    NotificationAndFirebaseService.context = context;
    if (!_isFCMConfigured) {
      try {
        _firebaseMessaging.configure(
          onMessage: onMessage,
          onBackgroundMessage: myBackgroundMessageHandler,
          onLaunch: onLaunch,
          onResume: (Map<String, dynamic> message) async {
            print("onResume: $message");
          },
        );

        if (Platform.isIOS) {
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
            print('kooooooft');
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

  static Future onSelectNotification(String body) async {
    var jsonBody = json.decode(body);

    int type = jsonBody['type'];
    String payload = jsonBody['payload'];
    if (type == 1) {
      joinVideoCall(context, payload);
    }
  }

  static Future<dynamic> onResume(Map<String, dynamic> message) async {
    print("onLaunch: $message");
  }

  static Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    print("onLaunch: $message");
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (Platform.isIOS) return null;
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  static Future<dynamic> onMessage(Map<String, dynamic> message) async {
    try {
      print("onMessage: $message");
      String title = message['notification']['title'];
      String body = message['notification']['body'];
      await _showNotificationWithDefaultSound(title, body);

      // Map<String, dynamic> data =
      //     new Map<String, dynamic>.from(message['data']);
      // NewestVisit visit;
      // if (data.containsKey('json')) {
      //   visit = NewestVisit.fromJson(data);
      //
      //   /// notification bloc events
      //   // ignore: close_sinks
      //   NotificationBloc notificationBloc =
      //       BlocProvider.of<NotificationBloc>(context);
      //   if ([5, 6].contains(data['type'])) {
      //     /// TODO amir: this condition should check type of notification later
      //     notificationBloc.add(AddNewestVisitNotification(newVisit: visit));
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

  static Future _showNotificationWithDefaultSound(
      String title, String body) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: body,
    );
  }
}
