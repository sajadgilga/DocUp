import 'package:flutter/material.dart';

String replaceFarsiNumber(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], farsi[i]);
  }

  return input;
}

bool validatePhoneNumber(String value) {
  Pattern pattern = r'^(\+98|0)?9\d{9}$';
  RegExp regex = new RegExp(pattern);
  return regex.hasMatch(value);
}

void hideKeyboard(context) =>
  FocusScope.of(context).unfocus();

void showNextVersionDialog(context){
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "منتظر ما باشید",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text("این امکان در نسخه‌های بعدی اضافه خواهد شد",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12)),
        );
      });

}

