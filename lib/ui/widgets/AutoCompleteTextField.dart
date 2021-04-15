import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/ui/widgets/Waiting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'AutoText.dart';
//ignore: must_be_immutable
class AutoCompleteTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final InputBorder border;
  List<String> items;
  final bool forced;
  final String emptyFieldError;
  final String notFoundError;
  final Function(String) onChanged;
  final Function(String) suggestionsCallback;

  AutoCompleteTextField(
      {Key key,
      @required this.controller,
      this.items,
      this.suggestionsCallback,
      this.hintText,
      this.emptyFieldError,
      this.notFoundError,
      this.forced = false,
      this.onChanged,
      this.border = const UnderlineInputBorder()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
      direction: AxisDirection.up,
      textFieldConfiguration: TextFieldConfiguration(
          controller: controller,
          textAlign: TextAlign.right,
          onChanged: this.onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            border: border,
            hintStyle: TextStyle(color: Colors.black, fontSize: 16.0),
          )),
      suggestionsCallback: (pattern) async {
        if (suggestionsCallback != null) {
          List<String> results = await suggestionsCallback(pattern);
          items = results;
          return results;
        } else {
          if (pattern.length <= 1) {
            return [];
          }
          return [for (var city in items) city]..removeWhere((element) {
              if (element.contains(pattern)) {
                return false;
              }
              return true;
            });
        }
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
      keepSuggestionsOnLoading: false,
      keepSuggestionsOnSuggestionSelected: false,
      hideOnLoading: false,
      hideOnEmpty: false,
      loadingBuilder: (context) {
        return Waiting(
          gifFlag: false,
        );
      },
      onSuggestionSelected: (suggestion) {
        controller.text = suggestion;
      },
      validator: (value) {
        if (value.isEmpty && forced) {
          return emptyFieldError;
        } else if (value.isNotEmpty && !(items?.contains(value) ?? false)) {
          return notFoundError;
        }
        return null;
      },
    );
  }
}
