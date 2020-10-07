import 'package:flutter/material.dart';
import 'package:icon_shadow/icon_shadow.dart';

typedef ActionCallBack = void Function();

class ActionButton extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final Color textColor;
  final String title;
  final Icon icon;
  final ActionCallBack callBack;
  final bool rtl;
  final double borderRadius;
  final bool boxShadowFlag;
  final double fontSize;
  final FontWeight fontWeight;

  ActionButton(
      {Key key,
      this.width,
      this.height,
      this.color,
      this.textColor,
      this.title,
      this.icon,
      this.callBack,
      this.rtl,
      this.boxShadowFlag = false,
      this.fontSize = 14,
      this.fontWeight=FontWeight.w500,
      this.borderRadius = 20.0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        boxShadow: widget.boxShadowFlag
            ? [
                BoxShadow(
                  color: widget.color,
                  blurRadius: 4,
                  spreadRadius: 0.0,
                ),
                BoxShadow(
                  color: Color.fromARGB(50, 0, 0, 0),
                  blurRadius: 4,
                  spreadRadius: 0.0,
                )
              ]
            : [],
        borderRadius: new BorderRadius.circular(widget.borderRadius),
      ),
      child: RaisedButton.icon(
        color: widget.color,
        textColor: Colors.white,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(widget.borderRadius),
            side: BorderSide(color: widget.color)),
        label: Padding(
          padding: EdgeInsets.only(bottom: 10.0, top: 10.0, right: 10.0),
          child: Text(
            widget.title != null ? widget.title : "",
            style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.textColor,
                fontWeight: widget.fontWeight),
            textAlign: TextAlign.center,
          ),
        ),
        icon: Padding(
            padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: widget.icon),
        onPressed: widget.callBack,
      ),
    );
  }
}
