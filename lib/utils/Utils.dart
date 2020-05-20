import 'dart:typed_data';

import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

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

normalizeCredit(String credit) {
  if (credit.contains(".")) {
    return credit.split(".")[0];
  } else
    return credit;
}

normalizeTime(String visitTime) {
  var date = visitTime.split("T")[0].split("-");
  var jajaliDate =
  Gregorian(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]))
      .toJalali();
  return replaceFarsiNumber(
      "${jajaliDate.year}/${jajaliDate.month}/${jajaliDate.day}");
}

String convertToGeorgianDate(String jalaliDate) {
  var array = jalaliDate.split("/");
  var georgianDate =
      Jalali(int.parse(array[0]), int.parse(array[1]), int.parse(array[2]))
          .toGregorian();
  return "${georgianDate.year}-${georgianDate.month}-${georgianDate.day}";
}

void hideKeyboard(context) => FocusScope.of(context).unfocus();

getLoadingDialog() => AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    content: Waiting());

void showOneButtonDialog(
    context, String message, String action, Function callback) {
  BuildContext dialogContext;
  AlertDialog dialog = AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    title: Text(
      message,
      style: TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
    ),
    content: ActionButton(
      color: IColors.themeColor,
      title: action,
      callBack: () {
        Navigator.pop(dialogContext);
        callback();
      },
    ),
  );
  showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return dialog;
      });
}

void showUnsupportedSessionDialog(context, Function callback) {
  showOneButtonDialog(
      context, "ویزیت مجازی در حال حاضر وجود ندارد", "رزرو ویزیت", callback);
}

void showMessageEmptyDialog(context, Function callback) {
  showOneButtonDialog(context, "پیام خالی ارسال نمی‌شود", "باشه", () {});
}

void showPicUploadedDialog(context, Function callback) {
  showOneButtonDialog(context, "تصویر ارسال شد", "باشه", callback);
}

void showAlertDialog(context, String text, Function callback) {
  showOneButtonDialog(context, text, "باشه", callback);
}

void showNextVersionDialog(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "منتظر ما باشید",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text("این امکان در نسخه‌های بعدی اضافه خواهد شد",
              textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),
        );
      });
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      .buffer
      .asUint8List();
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void toast(context, String message) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: 3),
  ));
}
