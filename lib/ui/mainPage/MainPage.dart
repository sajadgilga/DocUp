import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

import 'package:docup/ui/mainPage/navigator_destination.dart';
import '../../constants/colors.dart';
import 'NavigatorView.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
    4: GlobalKey<NavigatorState>(),
  };

  void _selectPage(int index) {
    if (_currentIndex == index) {
      _navigatorKeys[index].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  List<BottomNavigationBarItem> _bottomNavigationItems() {
    return navigator_destinations
        .map<BottomNavigationBarItem>((Destination destination) {
      return BottomNavigationBarItem(
          icon: Stack(
            children: <Widget>[
              Align(alignment: Alignment.center, child: (destination.hasImage
                  ? Container(
                      width: 50,
                      child: ClipPolygon(
                        sides: 6,
                        rotate: 90,
                        boxShadows: [
                          PolygonBoxShadow(color: Colors.black, elevation: 1.0),
                          PolygonBoxShadow(color: Colors.grey, elevation: 2.0)
                        ],
                        child: Image(
                          image: destination.image,
                        ),
                      ),
                    )
                  : Icon(
                      destination.icon,
                      size: 30,
                    ))),
//              Align(alignment: Alignment(0, -1), child: Container(
//                decoration:
//                    BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
//                width: 10,
//                height: 10,
//              ))
            ],
          ),
          title: Text(
            destination.title,
          ),
          backgroundColor: Colors.white);
    }).toList();
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      items: _bottomNavigationItems(),
//      tabs: [OverflowBox(maxWidth: 50, maxHeight: 50, child: ,),],
      currentIndex: _currentIndex,
      onTap: (int index) {
        _selectPage(index);
      },
      backgroundColor: Colors.white,
      unselectedItemColor: navigator_destinations[0].color,
      selectedItemColor: IColors.themeColor,
    );
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: NavigatorView(navigatorKey: _navigatorKeys[index], index: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
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
              ],
            )),
        onWillPop: () async {
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
