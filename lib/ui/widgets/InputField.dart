// ignore: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InputField extends StatelessWidget {
  String inputHint;
  TextEditingController controller;

  InputField({this.inputHint, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
          hintText: inputHint,
          hintStyle: TextStyle(color: Colors.black, fontSize: 16.0),
          labelStyle: TextStyle(color: Colors.black)),
    );
  }
}
