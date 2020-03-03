import 'package:flutter/material.dart';

typedef ActionCallBack = void Function();

class ActionButton extends StatefulWidget {
  final Color color;
  final String title;
  final Icon icon;
  final ActionCallBack callBack;
  final bool rtl;

  ActionButton(
      {Key key, this.color, this.title, this.icon, this.callBack, this.rtl})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return Wrap(children: <Widget>[
      RaisedButton.icon(
        color: widget.color,
        textColor: Colors.white,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(25.0),
            side: BorderSide(color: widget.color)),
        label: Padding(
          padding: EdgeInsets.only(bottom: 10.0, top: 10.0, right: 10.0),
          child: Text(
            widget.title != null ? widget.title : "",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        icon: Padding(
            padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: widget.icon),
        onPressed: widget.callBack,
      )
    ]);
  }
}
