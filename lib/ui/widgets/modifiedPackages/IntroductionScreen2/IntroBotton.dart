import 'package:flutter/material.dart';

class IntroButton2 extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const IntroButton2({Key key, this.onPressed, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      child: child,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }
}
