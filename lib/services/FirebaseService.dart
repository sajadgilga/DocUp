import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/NotificationBloc.dart';
import 'package:docup/models/NewestNotificationResponse.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/networking/CustomException.dart';
import 'package:docup/repository/NotificationRepository.dart';
import 'package:docup/ui/mainPage/NotifNavigationRepo.dart';
import 'package:docup/utils/Utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    if (!_isFCMConfigured) {
      try {
        _firebaseMessaging.configure(
          onMessage: onMessage,
          onBackgroundMessage: myBackgroundMessageHandler,
          onLaunch: onLaunch,
          onResume: onResume,
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
    handleNotifNavigation(data['payload'], intPossible(data['type']));
  }

  static Future<dynamic> onLaunch(Map<String, dynamic> message) async {
    print("onLaunch: $message");

    Map<String, dynamic> data = new Map<String, dynamic>.from(message['data']);
    handleNotifNavigation(data['payload'], intPossible(data['type']));
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    print("onBackgroundMessageHandler: $message");
    Map<String, dynamic> data = new Map<String, dynamic>.from(message['data']);
    handleNotifNavigation(data['payload'], intPossible(data['type']));

    // Or do other work.
  }

  static Future<dynamic> onMessage(Map<String, dynamic> message) async {
    try {
      print("onMessage: $message");
      String title = message['notification']['title'];
      String body = message['notification']['body'];
      String dataJson = json.encode(message['data']);
      await _showNotificationWithDefaultSound(title, body, dataJson);

      Map<String, dynamic> data =
          new Map<String, dynamic>.from(message['data']);
      if (data.containsKey('payload')) {
        if ([5, 6].contains(data['type'])) {
          NewestVisit visit = NewestVisit.fromJson(data['payload']);

          /// notification bloc events
          // ignore: close_sinks
          NotificationBloc notificationBloc =
              BlocProvider.of<NotificationBloc>(context);

          /// TODO amir: this condition should check type of notification later
          notificationBloc.add(AddNewestVisitNotification(newVisit: visit));
        } else if (true) {
          /// TODO amir: handling event type of notification
        }
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

      int type = jsonBody['type'] is int
          ? jsonBody['type']
          : int.parse(jsonBody['type']);
      String pPayload = jsonBody['payload'];
      handleNotifNavigation(pPayload, type);
    } catch (e) {
      print("OnNotification Tap Error:" + e.toString());
    }
  }

  static void handleNotifNavigation(String payload, int type) {
    void navigate() {
      if (type == 1) {
        /// voice or video call
        var data = json.decode(payload);
        User user = User.fromJson(data['partner_info']);
        int visitType = intPossible(data['visit_type']);
        String channelName = data['channel_name'];
        NotificationAndFirebaseService.notifNavRepo
            .joinVideoOrVoiceCall(context, channelName, visitType, user);
      } else if (type == 2) {
        /// test send and response
        NewestMedicalTest medicalTest =
            NewestMedicalTest.fromJson(json.decode(payload));
        NotificationAndFirebaseService.notifNavRepo
            .navigateToTestPage(medicalTest, context);
      } else if ([5, 6].contains(type)) {
        /// visit
        NewestVisit visit = NewestVisit.fromJson(json.decode(payload));
        NotificationAndFirebaseService.notifNavRepo
            .navigateToPanel(visit, context);
      }
    }

    EntityBloc _bloc = BlocProvider.of<EntityBloc>(context);
    print(_bloc.state);
    if (_bloc.state is EntityLoaded || _bloc.state.entity != null) {
      navigate();
    } else {
      StreamSubscription streamSubscription;
      streamSubscription = _bloc.listen((data) {
        print(data);
        if (data is EntityLoaded) {
          navigate();
          streamSubscription.cancel();
        }
      });
    }
  }

  static Future _showNotificationWithDefaultSound(
      String title, String body, String payload) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      payload.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
