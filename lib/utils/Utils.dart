import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/Waiting.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
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
  if (input == null) return "";
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
        initial: DateTimeService.getTodayInJalaliString(),
        min: DateTimeService.getTodayInJalaliString(),
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

String getInitialDate(Map<int, String> disableDays) {
  DateTime now = DateTimeService.getCurrentDateTime();
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

void showOneButtonDialog(
    context, String message, String action, Function callback,
    {Color color,
    bool barrierDismissible = true,
    bool callCallBackAfterDialogDispose = false}) {
  bool callBackHadCalled = false;
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
          callBackHadCalled = true;
          Navigator.pop(dialogContext);
          callback();
        },
      ),
    ),
  );
  showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        dialogContext = context;
        return dialog;
      }).then((value) {
    if (callCallBackAfterDialogDispose && !callBackHadCalled) {
      callback();
    }
  });
}

void showTwoButtonDialog(context, String message, String applyTitle,
    String rejectTitle, Function applyCallBack, Function rejectCallBack,
    {Color color, bool barrierDismissible = true}) {
  BuildContext dialogContext;
  AlertDialog dialog = AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    title: Text(
      message,
      style: TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    ),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 80,
          child: ActionButton(
            color: color == null ? IColors.red : color,
            title: rejectTitle,
            height: 45,
            callBack: () {
              Navigator.pop(dialogContext);
              rejectCallBack();
            },
          ),
        ),
        Container(
          width: 80,
          child: ActionButton(
            color: color == null ? IColors.themeColor : color,
            title: applyTitle,
            height: 45,
            callBack: () {
              Navigator.pop(dialogContext);
              applyCallBack();
            },
          ),
        ),
      ],
    ),
  );
  showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
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

void toast(context, String message, {int secs = 4}) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: AutoText(message),
    duration: Duration(seconds: secs),
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

String utf8IfPossible(String text) {
  try {
    text = utf8.decode(text.codeUnits);
  } catch (e) {}
  return text;
}

int intPossible(var text, {int defaultValues}) {
  try {
    if (text is int) {
      return text;
    } else if (text is String) {
      return int.parse(text);
    }
  } catch (e) {}
  return defaultValues;
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
}
