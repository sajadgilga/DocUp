import 'package:ntp/ntp.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'Utils.dart';

class DateTimeService {
  static DateTime _currentNTPDateTime;
  static DateTime _currentMobileDateTime;

  static loadCurrentDateTimes() async {
    try {
      _currentNTPDateTime = await NTP.now();
      _currentMobileDateTime = DateTime.now();
    } catch (e) {}
  }

  static Jalali getNewestJalaliSaturday() {
    Jalali now = getCurrentJalali();
    now = now.add(days: -1 * (now.weekDay - 1));
    return now;
  }

  static DateTime getCurrentDateTime() {
    DateTime now;
    if (_currentMobileDateTime == null || _currentNTPDateTime == null) {
      now = DateTime.now();
    } else {
      Duration delta = DateTime.now().difference(_currentMobileDateTime);
      now = _currentNTPDateTime.add(delta);
    }
    loadCurrentDateTimes();
    return now;
  }

  static String getCurrentTime() {
    DateTime now;
    if (_currentMobileDateTime == null || _currentNTPDateTime == null) {
      now = DateTime.now();
    } else {
      Duration delta = DateTime.now().difference(_currentMobileDateTime);
      now = _currentNTPDateTime.add(delta);
    }
    loadCurrentDateTimes();
    return "${now.hour}:${now.minute}:${now.second}";
  }

  static Jalali getJalaliformDateTime(DateTime date) {
    return Jalali.fromDateTime(date);
  }

  static Jalali getCurrentJalali() {
    return Jalali.fromDateTime(getCurrentDateTime());
  }

  static String getJalaliStringFromJalali(Jalali j) {
    final date = "${j.year}" +
        "/" +
        "${addExtraZeroOnLeftSideIfNeeded(j.month.toString())}" +
        "/" +
        "${addExtraZeroOnLeftSideIfNeeded(j.day.toString())}";
    return date;
  }

  static String getYesterdayInJalilyString() {
    DateTime dt = DateTimeService.getCurrentDateTime();
    dt = dt.subtract(Duration(days: 1));
    Jalali jalali = Jalali.fromDateTime(dt);
    final date = "${jalali.year}/${jalali.month}/${jalali.day}";
    return date;
  }

  static String getTodayInJalaliString() {
    final jalali = getCurrentJalali();
    final now = "${jalali.year}/${jalali.month}/${jalali.day}";
    return now;
  }

  static Jalali getTodayInJalali() {
    return Jalali.fromDateTime(DateTimeService.getCurrentDateTime());
  }

  static String getDateStringFormDateTime(DateTime date,
      {String dateSeparator = "-"}) {
    try {
      return "${date.year}$dateSeparator${date.month}$dateSeparator${date.day}";
    } catch (e) {
      return null;
    }
  }

  static String getTomorrowInJalali() {
    DateTime dt = DateTimeService.getCurrentDateTime();
    dt = dt.add(Duration(days: 1));
    final jalali = Jalali.fromDateTime(dt);
    final tomorrow = "${jalali.year}/${jalali.month}/${jalali.day}";
    return tomorrow;
  }

  static int getTimeMinute(String time) {
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

  static String convertMinuteToTimeString(int lessonsMinute) {
    int hour = ((lessonsMinute / 60).floor());
    int minute = lessonsMinute % 60;
    String hourString = hour < 10 ? "0" + hour.toString() : hour.toString();
    String minuteString =
        minute < 10 ? "0" + minute.toString() : minute.toString();
    return hourString + ":" + minuteString;
  }

  static String normalizeTime(String timeString, {bool cutSeconds = false}) {
    if (cutSeconds && timeString.split(":").length == 3) {
      return timeString.split(":")[0] + ":" + timeString.split(":")[1];
    }
    return timeString;
  }

  static DateTime getDateTimeFromDateString(String date) {
    return DateTime(
        int.parse(date.split(new RegExp(r"/|-|\\"))[0]),
        int.parse(date.split(new RegExp(r"/|-|\\"))[1]),
        int.parse(date.split(new RegExp(r"/|-|\\"))[2]));
  }

  static String getJalaliStringFormGeorgianDateTimeString(String date) {
    try {
      if (date.split("T").length > 1) {
        date = date.split("T")[0];
      }
      final jalaliDate = Jalali.fromDateTime(getDateTimeFromDateString(date));
      return "${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}";
    } catch (e) {
      return null;
    }
  }

  static String normalizeDateAndTime(String str,
      {bool cutSeconds = true, bool withLabel = true}) {
    String time =
        normalizeTime(str.split("T")[1].split("+")[0], cutSeconds: cutSeconds);
    String finalDate = getJalaliStringFormGeorgianDateTimeString(str);
    if (withLabel) {
      return "تاریخ: $finalDate زمان : $time ";
    } else {
      return "$finalDate $time";
    }
  }

  static DateTime getDateTimeFromStandardString(String str) {
    return DateTime.parse(str);
  }

  static String getTimeStringFromDateTime(DateTime dateTime,
      {bool withSeconds = true}) {
    return "${dateTime.hour}:${dateTime.minute}" +
        (withSeconds ? ":${dateTime.second}" : "");
  }

  static DateTime getDateAndTimeFromWS(String str) {
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

  static DateTime getDateAndTimeFromJalali(String jalaiDateStr,
      {String timeStr = "00:00"}) {
    var array = jalaiDateStr.split("/");
    var georgianDate =
        Jalali(int.parse(array[0]), int.parse(array[1]), int.parse(array[2]))
            .toGregorian();
    var timeArray = timeStr.split(":");
    return DateTime(georgianDate.year, georgianDate.month, georgianDate.day,
        int.parse(timeArray[0]), int.parse(timeArray[1]));
  }

  static Jalali getJalalyDateFromJalilyString(String jalalyDate) {
    try {
      var array = jalalyDate.split("/");
      return Jalali(
          int.parse(array[0]), int.parse(array[1]), int.parse(array[2]));
    } catch (e) {}
    return null;
  }

  static DateTime getDateTimeFromDateStringAndTimeStringSlash(
      String dateString, String timeString) {
    List<String> dateDetail = dateString.split("/");
    List<String> timeDetail = timeString.split(":");
    int year = intPossible(dateDetail[0]);
    int month = intPossible(dateDetail[1]);
    int day = intPossible(dateDetail[2]);
    int hour = intPossible(timeDetail[0]);
    int minute = intPossible(timeDetail[1]);
    return DateTime(year, month, day, hour, minute);
  }
}
