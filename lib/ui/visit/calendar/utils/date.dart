import 'package:Neuronio/ui/visit/calendar/utils/consts.dart';
import 'package:Neuronio/utils/DateTimeService.dart';
import 'package:shamsi_date/shamsi_date.dart';

class CalendarDateUtils {
  dynamic availableDates;
  String min;
  String max;
  String type;
  List<String> dayNames;

  CalendarDateUtils() {
    availableDates = Global.availableDates;
    min = Global.min;
    max = Global.max;
    type = Global.pickerType;
    dayNames = [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سه شنبه',
      'چهارشنبه',
      'پنجشنبه',
      'جمعه',
    ];
  }

  bool isDisable(String str) {
    bool isDisable = false;
    switch (type) {
      case 'date':
        isDisable = _inDisableDateList(str);
        break;
      case 'datetime':
        break;
      case 'year':
        isDisable = _inDisableYearList(str);
        break;
      case 'month':
        isDisable = _inDisableMonthList(str);
        break;
      case 'time':
        isDisable = _inDisableTimeList(str);
        break;
      case 'rangedate':
        break;
      default:
    }
    return isDisable;
  }

  static bool isValidDate(String date) {
    // 1.YYYY/MM/DD
    // 2.YYYY/MM/D
    // 3.YYYY/M/DD
    // 4.YYYY/M/D

    String pattern = r'^(\d{4})\/(0?[1-9]|1[012])\/(0?[1-9]|[12][0-9]|3[01])$';
    RegExp regExp = new RegExp(pattern);
    if (regExp.hasMatch(date)) {
      return true;
    }
    return false;
  }

  static bool isValidTime(String time) {
    // 1.10:05
    // 1.1:5
    // 1.1:50
    // 1.10:5
    String pattern = r'^([0[0-9]|1[0-9]|2[0-3]):([0-5][0-9]|[0-9])$';
    RegExp regExp = new RegExp(pattern);
    if (regExp.hasMatch(time)) {
      return true;
    }
    return false;
  }

  static int comparTime(String time1, String time2) {
    // 1.time1 > time2 return 1
    // 1.time1 < time2 return -1
    // 1.time1 = time2 return 0
    List<int> splitTime1 = time1.split(':').map(int.parse).toList();
    List<int> splitTime2 = time2.split(':').map(int.parse).toList();
    if (splitTime1[0] > splitTime2[0]) return 1;
    if (splitTime1[0] < splitTime2[0]) return -1;
    if (splitTime1[0] == splitTime2[0]) {
      if (splitTime1[1] > splitTime2[1]) return 1;
      if (splitTime1[1] < splitTime2[1]) return -1;
      if (splitTime1[1] == splitTime2[1]) return 0;
    }
  }

  static Jalali stringToJalali(String date) {
    List split = date.split('/');
    return Jalali(
            int.parse(split[0]), int.parse(split[1]), int.parse(split[2])) ??
        DateTimeService.getCurrentJalali();
  }

  static String jalaliToString(Date date) {
    final f = date.formatter;

    return '${f.yyyy}/${f.mm}/${f.dd}';
  }

  bool _isInRangeDate(String date) {
    bool isDisable = false;

    if (isValidDate(date) && isValidDate(min) && !isDisable) {
      isDisable = stringToJalali(date) <= stringToJalali(min);
    }
    if (isValidDate(date) && isValidDate(max) && !isDisable) {
      isDisable = stringToJalali(date) >= stringToJalali(max);
    }

    return isDisable;
  }

  bool _isDisableDate(String date, disable) {
    bool isDisable = false;

    if (dayNames.indexOf(disable.toLowerCase()) != -1 && !isDisable) {
      isDisable = stringToJalali(date).weekDay == dayNames.indexOf(disable) + 1;
    }
    if (isValidDate(date) && isValidDate(disable) && !isDisable) {
      isDisable = stringToJalali(date) == stringToJalali(disable);
    }

    return isDisable;
  }

  bool _inDisableDateList(dateString) {
    bool inDisable = false;
    if (availableDates != null) {
      String availableDatesTypeData = availableDates.runtimeType.toString();

      switch (availableDatesTypeData) {
        case 'String':
          inDisable =
              isValidDate(dateString) ? (dateString != availableDates) : false;
          break;
        case 'List<String>':
        case '_GrowableList<String>':
          inDisable = !availableDates.contains(dateString);
          break;
        case '_InternalLinkedHashMap<int, String>':
          List<int> keys = (availableDates as Map).keys.toList();
          for (var i = 0; i < keys.length; i++) {
            int key = keys[i];
            String value = (availableDates as Map)[key];
            inDisable = isValidDate(dateString)
                ? _isDisableDate(dateString, value)
                : false;
            if (inDisable) break;
          }
          break;
        default:
      }
    }

    if (min != '' && dateString != '' && !inDisable) {
      inDisable = isValidDate(dateString) ? _isInRangeDate(dateString) : false;
    }
    if (max != '' && dateString != '' && !inDisable) {
      inDisable = isValidDate(dateString) ? _isInRangeDate(dateString) : false;
    }
    return inDisable;
  }

  bool _inDisableMonthList(month) {
    bool inDisable = false;

    if (availableDates != null) {
      String disableTypeData = availableDates.runtimeType.toString();
      List monthNums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
      switch (disableTypeData) {
        case 'String':
          inDisable = monthNums.indexOf(int.parse(month)) != -1
              ? (int.parse(month) == int.parse(availableDates))
              : false;
          break;
        case 'List<String>':
          for (var i = 0; i < availableDates.length; i++) {
            inDisable = monthNums.indexOf(int.parse(month)) != -1
                ? (int.parse(month) == int.parse(availableDates[i]))
                : false;
            if (inDisable) break;
          }
          break;
        default:
      }
    }

    return inDisable;
  }

  bool _inDisableYearList(year) {
    bool inDisable = false;
    if (availableDates != null) {
      String disableTypeData = availableDates.runtimeType.toString();
      switch (disableTypeData) {
        case 'String':
          inDisable = (0 < int.parse(year) && int.parse(year) < 2000)
              ? (int.parse(year) == int.parse(availableDates))
              : false;
          break;
        case 'List<String>':
          for (var i = 0; i < availableDates.length; i++) {
            inDisable = (0 < int.parse(year) && int.parse(year) < 2000)
                ? (int.parse(year) == int.parse(availableDates[i]))
                : false;
            if (inDisable) break;
          }
          break;
        default:
      }
    }

    return inDisable;
  }

  bool _inDisableTimeList(time) {
    bool inDisable = false;

    if (availableDates != null) {
      String disableTypeData = availableDates.runtimeType.toString();

      switch (disableTypeData) {
        case 'String':
          inDisable = isValidTime(time) && isValidTime(availableDates)
              ? (comparTime(time, availableDates) == 0)
              : false;
          break;
        case 'List<String>':
          for (var i = 0; i < availableDates.length; i++) {
            inDisable = isValidTime(time) && isValidTime(availableDates[i])
                ? (comparTime(time, availableDates[i]) == 0)
                : false;
            if (inDisable) break;
          }
          break;
        case '_GrowableList<String>':
          for (var i = 0; i < availableDates.length; i++) {
            inDisable = isValidTime(time) && isValidTime(availableDates[i])
                ? (comparTime(time, availableDates[i]) == 0)
                : false;
            if (inDisable) break;
          }
          break;
        default:
      }
    }

    return inDisable;
  }
}
