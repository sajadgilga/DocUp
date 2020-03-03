
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef ActionCallBack = void Function();

// ignore: must_be_immutable
class ActionButton extends StatelessWidget {
  Color color;
  String title;
  Icon icon;
  bool rtl;
  ActionCallBack callback;

  ActionButton(Color color, String title, Icon icon, bool rtl, ActionCallBack callback) {
    this.color = color;
    this.title = title;
    this.icon = icon;
    this.rtl = rtl;
    this.callback = callback;
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      color: color,
      textColor: Colors.white,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
          side: BorderSide(color: color)),
      label: Padding(
        padding: EdgeInsets.only(bottom: 10.0, top: 10.0, right: 10.0),
        child: Text(title, style: TextStyle(fontSize: 16)),
      ),
      icon: Padding(
          padding: EdgeInsets.only(bottom: 10.0, top: 10.0), child: icon), onPressed: callback,
    );
  }
}
