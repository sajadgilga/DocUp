import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:flutter/material.dart';

class SnackbarHelper {
  static show(context,
      {body, bgColor = Colors.greenAccent, status = 'success'}) {
    Widget icon;
    switch (status) {
      case 'warning':
        icon = Icon(
          Icons.warning,
          color: Colors.orangeAccent,
        );
        break;
      default:
        icon = Icon(
          Icons.check_circle,
          color: Colors.white,
        );
    }
    final snackBar = SnackBar(
      content: AutoText('$body'),
      backgroundColor: bgColor,
    );

    /// flutter upgrade
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // Scaffold.of(context).showSnackBar(snackBar);
  }
}
