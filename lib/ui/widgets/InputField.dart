// ignore: must_be_immutable

import 'package:docup/constants/colors.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InputField extends StatefulWidget {
  String inputHint;
  TextEditingController controller;
  TextInputType textInputType;
  Function(String) validationCallback;
  bool needToHideKeyboard;
  String errorMessage;
  bool obscureText;
  ValueChanged<String> onChanged;
  bool disableInvalidIcon;

  InputField(
      {this.inputHint,
      this.controller,
      this.textInputType,
      this.needToHideKeyboard = true,
      this.validationCallback,
      this.errorMessage,
      this.onChanged,
      this.disableInvalidIcon = true,
      this.obscureText = false});

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool isValid = false;

  @override
  void initState() {
    setState(() {
      isValid = widget.validationCallback(widget.controller.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.obscureText,
      controller: widget.controller,
      textAlign: TextAlign.right,
      keyboardType: widget.textInputType,
      validator: (value) {
        if (widget.validationCallback(value)) {
          return null;
        } else {
          return widget.errorMessage;
        }
      },
      onChanged: (text) {
        if (widget.onChanged != null) {
          widget.onChanged(text);
        }
        setState(() {
          isValid = widget.validationCallback(text);
        });
        if (isValid && widget.needToHideKeyboard) {
          hideKeyboard(context);
        }
      },
      decoration: InputDecoration(
          prefixIcon: isValid
              ? Icon(
                  Icons.check,
                  color: null,
                )
              : Visibility(
                  child: Icon(
                    Icons.close,
                    color: IColors.red,
                  ),
                  visible: !widget.disableInvalidIcon,
                ),
          hintText: widget.inputHint,
          hintStyle: TextStyle(color: Colors.black, fontSize: 16.0),
          labelStyle: TextStyle(color: Colors.black)),
    );
  }
}
