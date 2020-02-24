// ignore: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InputField extends StatelessWidget {
  String inputHint;

  InputField(String inputHint) {
    this.inputHint = inputHint;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.right,
      decoration: InputDecoration(
          hintText: inputHint,
          hintStyle: TextStyle(color: Colors.black, fontSize: 16.0),
          labelStyle: TextStyle(color: Colors.black)),
    );
  }
}
