import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

showSnackBar(GlobalKey<ScaffoldState> _scaffoldKey, String message,
    {int secs = 3, BuildContext context}) {
  if (_scaffoldKey == null && context == null) {
    throw Exception("show snack bar context and scaffold key not provided");
  } else if (_scaffoldKey != null) {
    /// flutter upgrade
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: AutoText(
        message,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      ),
      duration: Duration(seconds: secs),
    ));
    // _scaffoldKey.currentState.showSnackBar(SnackBar(
    //   content: AutoText(
    //     message,
    //     textDirection: TextDirection.rtl,
    //     textAlign: TextAlign.right,
    //   ),
    //   duration: Duration(seconds: secs),
    // ));
  } else {
    /// flutter upgrade
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: AutoText(
        message,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      ),
      duration: Duration(seconds: secs),
    ));
  }
}
