import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher.dart';

enum WeekDay { SATURDAY, SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY }

extension WeekDaysExtension on WeekDay {
  String get name {
    switch (this) {
      case WeekDay.SATURDAY:
        return "شنبه";
      case WeekDay.SUNDAY:
        return "یکشنبه";
      case WeekDay.MONDAY:
        return "دوشنبه";
      case WeekDay.TUESDAY:
        return "سه شنبه";
      case WeekDay.WEDNESDAY:
        return "چهارشنبه";
      case WeekDay.THURSDAY:
        return "پنجشنبه";
      case WeekDay.FRIDAY:
        return "جمعه";
    }
  }
}

String replaceFarsiNumber(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], farsi[i]);
  }

  return input;
}

String normalizeDateAndTime(String str, {bool cutSeconds = false}) {
  String date = str.split("T")[0];
  String time = str.split("T")[1].split("+")[0];
  if (cutSeconds && time.split(":").length == 3) {
    time = time.split(":")[0] + ":" + time.split(":")[1];
  }
  final jalaliDate = Jalali.fromDateTime(DateTime(int.parse(date.split("-")[0]),
      int.parse(date.split("-")[1]), int.parse(date.split("-")[2])));
  String finalDate = "${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}";
  return "تاریخ: $finalDate زمان : $time ";
}

DateTime getDateAndTimeFromWS(String str) {
  String date = str.split("T")[0];
  String time = str.split("T")[1];
  final timeArray = time.split(":");
  return DateTime(
      int.parse(date.split("-")[0]),
      int.parse(date.split("-")[1]),
      int.parse(date.split("-")[2]),
      int.parse(timeArray[0]),
      int.parse(timeArray[1]),
      int.parse(timeArray[2]));
}

DateTime getDateAndTimeFromJalali(String jalaiDateStr,
    {String timeStr = "00:00"}) {
  var array = jalaiDateStr.split("/");
  var georgianDate =
      Jalali(int.parse(array[0]), int.parse(array[1]), int.parse(array[2]))
          .toGregorian();
  var timeArray = timeStr.split(":");
  return DateTime(georgianDate.year, georgianDate.month, georgianDate.day,
      int.parse(timeArray[0]), int.parse(timeArray[1]));
}

Jalali getJalalyDateFromJalilyString(String jalalyDate) {
  try {
    var array = jalalyDate.split("/");
    return Jalali(
        int.parse(array[0]), int.parse(array[1]), int.parse(array[2]));
  } catch (e) {}
  return null;
}

bool validatePhoneNumber(String value) {
  Pattern pattern = r'^(\+98|0)?9\d{9}$';
  RegExp regex = new RegExp(pattern);
  return regex.hasMatch(value);
}

String normalizeCredit(String credit) {
  if (credit.contains(".")) {
    return credit.split(".")[0];
  } else
    return credit;
}

String getJalaliDateStringFromJalali(Jalali jalali) {
  return "${jalali.year}/${jalali.month}/${jalali.day}";
}

String getTimeStringFromDateTime(DateTime dateTime, {bool withSeconds = true}) {
  return "${dateTime.hour}:${dateTime.minute}" +
      (withSeconds ? ":${dateTime.second}" : "");
}

String convertToGeorgianDate(String jalaliDate) {
  var array = jalaliDate.split("/");
  var georgianDate =
      Jalali(int.parse(array[0]), int.parse(array[1]), int.parse(array[2]))
          .toGregorian();
  return "${georgianDate.year}-${georgianDate.month}-${georgianDate.day}";
}

void hideKeyboard(context) => FocusScope.of(context).unfocus();

class LoadingAlertDialog {
  BuildContext dialogContext;
  BuildContext context;

  LoadingAlertDialog(this.context);

  void showLoading() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          this.dialogContext = context;
          return getLoadingDialog();
        });
  }

  void disposeDialog() {
    Navigator.maybePop(dialogContext);
  }
}

AlertDialog getLoadingDialog() => AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    content: Waiting());

void showDatePickerDialog(
    context, List<int> availableDays, TextEditingController controller) {
  showDialog(
    context: context,
    builder: (BuildContext _) {
      return PersianDateTimePicker(
        color: IColors.themeColor,
        type: "date",
        initial: getTodayInJalaliString(),
        min: getTodayInJalaliString(),
        disable: getDisableDays(availableDays),
        onSelect: (date) {
          controller.text = date;
        },
      );
    },
  );
}

Map<int, String> getDisableDays(List<int> availableDays) {
  Map<int, String> disableDays = {};
  for (int i = 0; i < 7; i++) {
    if (!availableDays.contains(i)) disableDays[i] = WeekDay.values[i].name;
  }
  return disableDays;
}

String getTodayInJalaliString() {
  final jalali = Jalali.fromDateTime(DateTime.now());
  final now = "${jalali.year}/${jalali.month}/${jalali.day}";
  return now;
}

Jalali getTodayInJalali() {
  return Jalali.fromDateTime(DateTime.now());
}

String getInitialDate(Map<int, String> disableDays) {
  DateTime now = DateTime.now();
  for (int i = 0; i < 7; i++) {
    DateTime date = now.add(Duration(days: i));
    Jalali dateJ = Jalali.fromDateTime(date);
    if (!(disableDays.keys.toList()).contains(dateJ.weekDay - 1)) {
      return "${dateJ.year}/${dateJ.month}/${dateJ.day}";
    }
  }
  Jalali dateJ = Jalali.fromDateTime(now.add(Duration(days: 7)));
  return "${dateJ.year}/${dateJ.month}/${dateJ.day}";
}

String getYesterdayInJalilyString() {
  DateTime dt = DateTime.now();
  dt = dt.subtract(Duration(days: 1));
  Jalali jalali = Jalali.fromDateTime(dt);
  final date = "${jalali.year}/${jalali.month}/${jalali.day}";
  return date;
}

String getTomorrowInJalali() {
  DateTime dt = DateTime.now();
  dt = dt.add(Duration(days: 1));
  final jalali = Jalali.fromDateTime(dt);
  final tomorrow = "${jalali.year}/${jalali.month}/${jalali.day}";
  return tomorrow;
}

void showOneButtonDialog(
    context, String message, String action, Function callback,
    {Color color}) {
  BuildContext dialogContext;
  AlertDialog dialog = AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    title: Text(
      message,
      style: TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    ),
    content: Container(
      width: 10,
      child: ActionButton(
        color: color == null ? IColors.themeColor : color,
        title: action,
        height: 45,
        callBack: () {
          Navigator.pop(dialogContext);
          callback();
        },
      ),
    ),
  );
  showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return dialog;
      });
}

void showListDialog(
    context, List<String> items, String action, Function callback) {
  BuildContext dialogContext;

  AlertDialog dialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      content: Container(
        height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
                      title:
                          AutoText(items[index], textAlign: TextAlign.center),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        callback(index);
                      },
                    )),
          ],
        ),
      ));
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

void showPicUploadedDialog(context, text, Function callback) {
  showOneButtonDialog(context, text, "باشه", callback);
}

void showAlertDialog(context, String text, Function callback) {
  showOneButtonDialog(context, text, "باشه", callback);
}

void showNextVersionDialog(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoText(
            "منتظر ما باشید",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: AutoText("این امکان در نسخه‌های بعدی اضافه خواهد شد",
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
    content: AutoText(message),
    duration: Duration(seconds: 3),
  ));
}

String getCreditCardFourParts(String accountNumber) {
  accountNumber = accountNumber.replaceAll(" ", "");
  List<String> res = [];
  for (int i = 0; i < (accountNumber.length / 4).ceil(); i++) {
    res.add(
        accountNumber.substring(i * 4, min(accountNumber.length, 4 * (i + 1))));
  }
  return res.join(" ");
}

String replaceEnglishWithPersianNumber(String text) {
  List<String> persianNumber = [
    "۰",
    "۱",
    "۲",
    "۳",
    "۴",
    "۵",
    "۶",
    "۷",
    "۸",
    "۹"
  ];
  for (int i = 0; i < persianNumber.length; i++) {
    text = text.replaceAll(i.toString(), persianNumber[i]);
  }
  return text;
}

String replacePersianWithEnglishNumber(String text) {
  List<String> persianNumber = [
    "۰",
    "۱",
    "۲",
    "۳",
    "۴",
    "۵",
    "۶",
    "۷",
    "۸",
    "۹"
  ];
  for (int i = 0; i < persianNumber.length; i++) {
    text = text.replaceAll(persianNumber[i], i.toString());
  }
  return text;
}

int getTimeMinute(String time) {
  String removeAllSpace(String text) {
    return text.replaceAll(" ", "");
  }

  time = removeAllSpace(time);
  time = replacePersianWithEnglishNumber(time);
  try {
    if (time.contains(":")) {
      int hour = int.parse(time.split(":")[0]);
      int minute = int.parse(time.split(":")[1]);
      return (60 * hour) + minute;
    } else {
      int minute = int.parse(time);
      return minute;
    }
  } catch (Exception) {
    return 0;
  }
}

String convertMinuteToTimeString(int lessonsMinute) {
  int hour = ((lessonsMinute / 60).floor());
  int minute = lessonsMinute % 60;
  String hourString = hour < 10 ? "0" + hour.toString() : hour.toString();
  String minuteString =
      minute < 10 ? "0" + minute.toString() : minute.toString();
  return hourString + ":" + minuteString;
}

String utf8IfPossible(String text) {
  try {
    text = utf8.decode(text.codeUnits);
  } catch (e) {}
  return text;
}

int intPossible(var text) {
  try {
    if (text is int) {
      return text;
    } else if (text is String) {
      return int.parse(text);
    }
  } catch (e) {}
  return null;
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
}
