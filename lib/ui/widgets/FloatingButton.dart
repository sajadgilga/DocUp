import 'package:docup/constants/colors.dart';
import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final Function() callback;
  final String label;
  final IconData icon;

  const FloatingButton({Key key, this.callback, this.label, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: IColors.themeColor,
            child: Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              callback();
            },
          ),
          Container(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ))
        ],
      ),
    );
  }
}