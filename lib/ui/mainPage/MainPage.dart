import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/PanelBloc.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/ApiProvider.dart';
import 'package:Neuronio/repository/UtilRepository.dart';
import 'package:Neuronio/services/FirebaseService.dart';
import 'package:Neuronio/ui/mainPage/navigator_destination.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/utils/CrossPlatformSvg.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/WebsocketHelper.dart';
import 'package:Neuronio/utils/entityUpdater.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../../constants/colors.dart';
import 'NavigatorView.dart';

class MainPage extends StatefulWidget {
  final Function(String, dynamic) pushOnBase;

  MainPage({Key key, this.pushOnBase}) : super(key: key);

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  ProgressDialog _progressDialogue;
  Map<int, GlobalKey<NavigatorViewState>> _children = {
    0: GlobalKey<NavigatorViewState>(),
    1: GlobalKey<NavigatorViewState>(),
    2: GlobalKey<NavigatorViewState>(),
    3: GlobalKey<NavigatorViewState>(),
    4: GlobalKey<NavigatorViewState>(),
  };

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

    /// start updater if it is not started already
    checkAppVersion();
    EntityAndPanelUpdater.start(_entityBloc, _panelBloc);

    NotificationAndFirebaseService.initFCM(context, widget.pushOnBase);
    super.initState();
  }

  checkAppVersion() {
    if(!kIsWeb){
      UtilRepository utilRepository = UtilRepository();
      utilRepository.getLatestAppBuildNumber().then((value) async {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        int currentBuildNumber = intPossible(await packageInfo.buildNumber);
        print(value);
        if (currentBuildNumber < value) {
          showOneButtonDialog(
              context,
              "نسخه اپلیکیشن کنونی شما قدیمی است. با زدن بر روی دکمه زیر برای اپدیت اپ اقدام کنید و اطلاعات بیشتری را از سایت نورونیو دریافت کنید.",
              "تایید", () {
            launchURL("https://neuronio.ir");
          }, barrierDismissible: false);
        }
      });
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
                          ? CrossPlatformSvg.asset(
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
          title: AutoText(
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
        // if (section == 1) {
        // _chatPage(section);
        // } else {
        _selectPage(section);
        // }
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
