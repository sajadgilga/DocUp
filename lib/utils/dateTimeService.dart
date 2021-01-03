import 'package:ntp/ntp.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'Utils.dart';

class DateTimeService {
  static DateTime currentNTPDateTime;
  static DateTime currentMobileDateTime;

  static loadCurrentDateTimes() async {
    try{
      currentNTPDateTime = await NTP.now();
      currentMobileDateTime = DateTime.now();
    }catch(e){

    }
  }

  static DateTime getCurrentDateTime() {
    DateTime now;
    if (currentMobileDateTime == null || currentNTPDateTime == null) {
      now = DateTime.now();
      print("mobile now:" + now.toString());
    } else {
      Duration delta = DateTime.now().difference(currentMobileDateTime);
      now = currentNTPDateTime.add(delta);
      print("ntp now:" + now.toString());
    }
    loadCurrentDateTimes();
    return now;
  }

  static Jalali getCurrentJalali() {
    return Jalali.fromDateTime(getCurrentDateTime());
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

  static String normalizeDate(String date) {
    final jalaliDate = Jalali.fromDateTime(DateTime(
        int.parse(date.split("-")[0]),
        int.parse(date.split("-")[1]),
        int.parse(date.split("-")[2])));
    return "${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}";
  }

  static String normalizeDateAndTime(String str,
      {bool cutSeconds = true, bool withLabel = true}) {
    String time =
        normalizeTime(str.split("T")[1].split("+")[0], cutSeconds: cutSeconds);
    String finalDate = normalizeDate(str.split("T")[0]);
    if (withLabel) {
      return "تاریخ: $finalDate زمان : $time ";
    } else {
      return "$finalDate $time";
    }
  }

  static DateTime getDateTimeFromStandardString(String str) {
    return DateTime.parse(str);
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
}
