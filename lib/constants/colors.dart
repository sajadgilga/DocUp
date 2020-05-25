import 'package:docup/ui/start/RoleType.dart';
import 'package:flutter/material.dart';

import 'assets.dart';

const Map<int, Color> swatch = {
  50: Color.fromRGBO(254, 95, 85, .1),
  100: Color.fromRGBO(254, 95, 85, .2),
  200: Color.fromRGBO(254, 95, 85, .3),
  300: Color.fromRGBO(254, 95, 85, .4),
  400: Color.fromRGBO(254, 95, 85, .5),
  500: Color.fromRGBO(254, 95, 85, .6),
  600: Color.fromRGBO(254, 95, 85, .7),
  700: Color.fromRGBO(254, 95, 85, .8),
  800: Color.fromRGBO(254, 95, 85, .9),
  900: Color.fromRGBO(254, 95, 85, 1),
};

class IColors {
  static const Color red = Color.fromRGBO(254, 95, 85, 1);
  static const Color blue = Color.fromRGBO(50, 200, 240, 1);
  static const Color green = Color.fromRGBO(74, 157, 134, 1);
  static const Color darkBlue = Color.fromRGBO(44, 62, 80, 1);
  static const Color background = Color.fromRGBO(242, 242, 242, 1);
  static const Color doctorChatBubble = Color.fromRGBO(242, 242, 242, 1);
  static const Color disabledButton = Colors.black54;
  static Color themeColor = blue;
  static Color selfChatBubble = themeColor;
  static Color doctorChatText = Colors.black;
  static Color selfChatText = Colors.white;
  static Color grey = Color.fromRGBO(245, 245, 245, 1);
  static Color transparentGrey = Color.fromRGBO(10, 10, 10, 1);
  static Color darkGrey = Color.fromRGBO(144, 144, 144, 1);
  static const Color deactivePanelMenu = Colors.black38;
  static const Color activePanelMenu = Colors.black54;

  static const Color trackingVisitPending = Color.fromRGBO(242, 51, 51, 1);
  static const Color trackingCuring = Colors.black;
  static const Color trackingCured = Color.fromRGBO(38, 163, 10, 1);

  static const Color visitRequest = Color.fromRGBO(254, 95, 85, 1);
  static const Color virtualVisitRequest = Color.fromRGBO(254, 95, 85, 1);
  static const Color inContact = green;
  static const Color cured = activePanelMenu;

  static void changeThemeColor(RoleType roleType) {
    Assets.changeIcons(roleType);
    switch(roleType) {
      case RoleType.PATIENT:
        themeColor = blue;
        break;
      case RoleType.CLINIC:
        themeColor = red;
        break;
      case RoleType.DOCTOR:
        themeColor = green;
    }
    selfChatBubble = themeColor;
  }
}