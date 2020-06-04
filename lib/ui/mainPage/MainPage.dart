import 'dart:async';
import 'dart:convert';

import 'package:docup/networking/CustomException.dart';
import 'package:docup/services/FirebaseService.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/PatientBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/main.dart';
import 'package:docup/models/AgoraChannelEntity.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/Panel.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/NotificationRepository.dart';
import 'package:docup/ui/doctorDetail/DoctorDetailPage.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/panel/videoCallPage/call.dart';
import 'package:docup/ui/start/RoleType.dart';
import 'package:docup/utils/WebsocketHelper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

import 'package:docup/ui/mainPage/navigator_destination.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/colors.dart';
import 'CallRepo.dart';
import 'NavigatorView.dart';

class MainPage extends StatefulWidget {
  Function(String, dynamic) pushOnBase;

  MainPage({Key key, this.pushOnBase}) : super(key: key);

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  ProgressDialog _progressDialogue;
  Map<int, GlobalKey<NavigatorViewState>> _children = {
    0: GlobalKey<NavigatorViewState>(),
    1: GlobalKey<NavigatorViewState>(),
    2: GlobalKey<NavigatorViewState>(),
    3: GlobalKey<NavigatorViewState>(),
    4: GlobalKey<NavigatorViewState>(),
  };
  Timer _timer;

  int _currentIndex = 0;
  Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
    4: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {

    // initialize socket helper for web socket messages
    SocketHelper().init('185.252.30.163');


    // get user entity & panels, also periodically update entity's info
    final _entityBloc = BlocProvider.of<EntityBloc>(context);
    _entityBloc.add(EntityGet());
    var _panelBloc = BlocProvider.of<PanelBloc>(context);
    _panelBloc.add(GetMyPanels());
    _entityBloc.listen((data) {
      if (_timer == null)
        _timer = Timer.periodic(Duration(seconds: 15), (Timer t) {
          _entityBloc.add(EntityUpdate());
          _panelBloc.add(GetMyPanels());
        });
    });
    // firebase initialization for notifications & push notifications
//    try {
//      _firebaseMessaging.getToken().then((String fcmToken) {
//        if (fcmToken == null) {
//          super.initState();
//          return;
//        }
//        print("FCM " + fcmToken);
//        try {
//          NotificationRepository().registerDevice(fcmToken);
//        } on BadRequestException{
//          print('kooooooft');
//        }
//        catch(_) {
//          print('register device failed fcm');
//        }
//      });
//
//      _firebaseMessaging.configure(
//        onMessage: (Map<String, dynamic> message) async {
//          print("onMessage: $message");
//          await _showNotificationWithDefaultSound(
//              message['notification']['title'],
//              message['notification']['body']);
//        },
//        onBackgroundMessage: myBackgroundMessageHandler,
//        onLaunch: (Map<String, dynamic> message) async {
//          print("onLaunch: $message");
//        },
//        onResume: ( Map<String, dynamic> message) async {
//          print("onResume: $message");
//        },
//      );
//
//      var initializationSettingsAndroid =
//      new AndroidInitializationSettings('mipmap/ic_launcher');
//      var initializationSettingsIOS = new IOSInitializationSettings();
//
//      var initializationSettings = new InitializationSettings(
//          initializationSettingsAndroid, initializationSettingsIOS);
//
//      flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//      flutterLocalNotificationsPlugin.initialize(initializationSettings,
//          onSelectNotification: onSelectNotification);
//    } catch(_) {
//      print("oh oh");
//    }
    super.initState();

  }

  Future _showNotificationWithDefaultSound(String title, String body) async {
    var jsonBody = json.decode(body);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      title,
      platformChannelSpecifics,
      payload: jsonBody['payload'],
    );
  }

  Future onSelectNotification(String payload) async {
    joinVideoCall(context, payload);
  }


  void _selectPage(int index) {
    if (_currentIndex == index) {
      _navigatorKeys[index].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  List<BottomNavigationBarItem> _bottomNavigationItems(Entity entity) {
    if (entity != null && entity.mEntity != null && entity.avatar != null)
      navigator_destinations[4].img = Image.network(entity.avatar);
    return navigator_destinations
        .map<BottomNavigationBarItem>((Destination destination) {
      return BottomNavigationBarItem(
          icon: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.center,
                  child: (destination.isProfile
                      ? Container(
                          width: 50,
                          child: ClipPolygon(
                              sides: 6,
                              rotate: 90,
                              boxShadows: [
                                PolygonBoxShadow(
                                    color: Colors.black, elevation: 1.0),
                                PolygonBoxShadow(
                                    color: Colors.grey, elevation: 2.0)
                              ],
                              child: (destination.img != null
                                  ? destination.img
                                  : Image.asset(Assets.emptyAvatar))),
                        )
                      : (destination.hasImage
                          ? SvgPicture.asset(
                              destination.image,
                              color: (_currentIndex == 1
                                  ? IColors.themeColor
                                  : Colors.grey),
                              width: 25,
                            )
                          : Icon(
                              destination.icon,
                              size: 30,
                            )))),
//              Align(alignment: Alignment(0, -1), child: Container(
//                decoration:
//                    BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
//                width: 10,
//                height: 10,
//              ))
            ],
          ),
          title: Text(
            '',
          ),
          backgroundColor: Colors.white);
    }).toList();
  }

  Widget _bottomNavigationBar() {
    return BlocBuilder<EntityBloc, EntityState>(
      builder: (context, state) {
        return BottomNavigationBar(
          items: _bottomNavigationItems(state.entity),
//      tabs: [OverflowBox(maxWidth: 50, maxHeight: 50, child: ,),],
          currentIndex: _currentIndex,
          onTap: (int index) {
            _selectPage(index);
          },
          backgroundColor: Colors.white,
          unselectedItemColor: navigator_destinations[0].color,
          selectedItemColor: IColors.themeColor,
        );
      },
    );
  }

  void _chatPage(int section) {
    _selectPage(2);
    _children[2].currentState.push(null, NavigatorRoutes.panel, detail: 'chat');
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
        offstage: _currentIndex != index, child: _buildNavigator(index));
  }

  Widget _buildNavigator(int index) {
    return NavigatorView(
      selectPage: (int section) {
        _chatPage(section);
      },
      navigatorKey: _navigatorKeys[index],
      index: index,
      pushOnBase: widget.pushOnBase,
      key: _children[index],
    );
  }

  Widget _mainPage() {
    return Scaffold(
        backgroundColor: IColors.background,
        bottomNavigationBar: SizedBox(
          child: _bottomNavigationBar(),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: <Widget>[
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
            _buildOffstageNavigator(3),
            _buildOffstageNavigator(4),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    _progressDialogue =
        ProgressDialog(context, type: ProgressDialogType.Normal);
    _progressDialogue.style(message: "لطفا منتظر بمانید");

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    return WillPopScope(
        child: BlocBuilder<EntityBloc, EntityState>(builder: (context, state) {
      return _mainPage();
    }), onWillPop: () async {
      final isFirstRouteInCurrentRoute =
          !await _navigatorKeys[_currentIndex].currentState.maybePop();
      if (isFirstRouteInCurrentRoute) {
        if (_currentIndex != 0) {
          _selectPage(0);
          return false;
        }
      }
      return isFirstRouteInCurrentRoute;
    });
  }
}
