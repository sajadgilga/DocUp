import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:docup/networking/ApiProvider.dart';
import 'package:docup/networking/CustomException.dart';
import 'package:docup/services/FirebaseService.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/repository/NotificationRepository.dart';
import 'package:docup/utils/WebsocketHelper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

import 'package:docup/ui/mainPage/navigator_destination.dart';
import 'package:progress_dialog/progress_dialog.dart';
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
  bool _isFCMConfiged = false;

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
    SocketHelper().init(ApiProvider.URL_IP);
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
//      _enableFCM();
//      setState(() {
//        _isFCMConfiged = true;
//      });
    super.initState();
  }

  Future _enableFCM() async {
    try {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          await _showNotificationWithDefaultSound(
              message['notification']['title'],
              message['notification']['body']);
        },
        onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
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
          _isFCMConfiged = true;
          return;
        } catch (_) {
          print('register device failed fcm');
          _isFCMConfiged = true;
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
      _isFCMConfiged = true;
      return;
    }
  }

  Future _showNotificationWithDefaultSound(String title, String body) async {
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
      payload: body,
    );
  }

  Future onSelectNotification(String body) async {
    var jsonBody = json.decode(body);

    int type = jsonBody['type'];
    String payload = jsonBody['payload'];
    if (type == 1) {
      joinVideoCall(context, payload);
    }
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

  void _selectPage(int index) {
    if (_currentIndex == index) {
      _navigatorKeys[index].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Color _getBottomNavigationColor(destination,
      {primary, secondary = Colors.transparent}) {
    if (primary == null) primary = IColors.themeColor;
    return _currentIndex == destination.index ? primary : secondary;
  }

  List<BottomNavigationBarItem> _bottomNavigationItems(Entity entity) {
    return navigator_destinations
        .map<BottomNavigationBarItem>((Destination destination) {
      return BottomNavigationBarItem(
          icon: Container(
              constraints: BoxConstraints.expand(
                  width: MediaQuery.of(context).size.width / 4, height: 40),
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      child: (destination.hasImage
                          ? SvgPicture.asset(
                              destination.image,
                              color: _getBottomNavigationColor(destination,
                                  secondary: Colors.grey),
                              width: 25,
                            )
                          : Icon(
                              destination.icon,
                              size: 30,
                            ))),
                  Align(
                      alignment: Alignment(0, -1.65),
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getBottomNavigationColor(destination),
                            boxShadow: [
                              BoxShadow(
                                  color: _getBottomNavigationColor(destination),
                                  offset: Offset(1, 3),
                                  blurRadius: 10)
                            ]),
                        width: 10,
                        height: 10,
                      ))
                ],
              )),
          title: Text(
            destination.title,
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
    _selectPage(1);
    _children[1].currentState.push(null, NavigatorRoutes.panel, detail: 'chat');
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
//            _buildOffstageNavigator(4),
          ],
        ));
  }
}
