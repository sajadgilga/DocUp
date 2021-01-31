import 'package:Neuronio/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'AutoText.dart';

class AutoCompleteTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final InputBorder border;
  final List<String> items;
  final bool forced;
  final String emptyFieldError;
  final String notFoundError;

  AutoCompleteTextField(
      {Key key,
      @required this.items,
      @required this.controller,
      this.hintText,
      this.emptyFieldError,
      this.notFoundError,
      this.forced = false,
      this.border = const UnderlineInputBorder()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
      hideOnEmpty: true,
      direction: AxisDirection.up,
      textFieldConfiguration: TextFieldConfiguration(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hintText,
            border: border,
            hintStyle: TextStyle(color: Colors.black, fontSize: 16.0),
          )),
      suggestionsCallback: (pattern) {
        if (pattern.length <= 1) {
          return [];
        }
        return [for (var city in items) city]..removeWhere((element) {
            if (element.contains(pattern)) {
              return false;
            }
            return true;
          });
      },
      itemBuilder: (context, suggestion) {
        return Container(
          child: Column(
            children: [
              AutoText(
                suggestion,
                style: TextStyle(color: Colors.black, fontSize: 13.0),
              ),
              Container(
                height: 2,
                color: IColors.grey,
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              )
            ],
          ),
          alignment: Alignment.center,
          color: Colors.white,
        );
      },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      onSuggestionSelected: (suggestion) {
        controller.text = suggestion;
      },
      validator: (value) {
        if (value.isEmpty && forced) {
          return emptyFieldError;
        } else if (value.isNotEmpty && !items.contains(value)) {
          return notFoundError;
        }
        return null;
      },
    );
  }
}
