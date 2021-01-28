import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'AutoText.dart';

class CityAutoComplete extends StatelessWidget{
  final String hintText;
  final TextEditingController controller;
  final InputBorder border;

  CityAutoComplete({Key key, this.hintText, this.controller,this.border=const UnderlineInputBorder()}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
      hideOnEmpty: true,
      direction:  AxisDirection.up,
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
        return Strings.cities.keys.toList()
          ..removeWhere((element) {
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
        if (value.isEmpty) {
          return 'لظفا شهری را وارد کنید';
        } else {
          if (Strings.cities.keys.contains(value)) {
            return null;
          } else {
            return "شهر موردنظر یافت نشد";
          }
        }
      },
    );
  }
}