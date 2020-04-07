import 'package:flutter/material.dart';

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

enum Theme {
  PATIENT,
  DOCTOR,
  CLINIC
}

class IColors {
  static const Color red = Color.fromRGBO(254, 95, 85, 1);
  static const Color blue = Color.fromRGBO(50, 200, 240, 1);
  static const Color green = Color.fromRGBO(254, 95, 85, 1);
  static const Color background = Color.fromRGBO(242, 242, 242, 1);
  static const Color doctorChatBubble = Color.fromRGBO(242, 242, 242, 1);
  static Color themeColor = blue;
  static Color selfChatBubble = themeColor;
  static Color doctorChatText = Colors.black;
  static Color selfChatText = Colors.white;
  static Color grey = Color.fromRGBO(245, 245, 245, 1);
  static Color darkGrey = Color.fromRGBO(144, 144, 144, 1);

  static void changeThemeColor(Theme theme) {
    switch(theme) {
      case Theme.PATIENT:
        themeColor = blue;
        break;
      case Theme.CLINIC:
        themeColor = red;
        break;
      case Theme.DOCTOR:
        themeColor = green;
    }
    selfChatBubble = themeColor;
  }
}