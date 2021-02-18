import 'dart:ui';

import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/CalendarEvent.dart';
import 'package:Neuronio/ui/visit/VisitUtils.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DoctorPlan {
  static final daysCount = 7;
  static final dayHours = 24;

  /// equal to 15 minute
  static final hourParts = 4;
  static final hourMinutePart = 15;

  /// object fields
  int id;
  List<VisitType> visitTypes;

  Map<String, List<ReservedVisit>> recentVisits;
  String createdDate;
  String modifiedDate;
  bool enabled;

  /// just for keeping same interface as befor
  VisitType getVisitTypeDataWithType(int type) {
    if (type == 0) {
      return physicalVisitType;
    } else if (type == 1) {
      return virtualVisitType;
    }
    return null;
  }

  VisitType get virtualVisitType {
    if (visitTypes != null) {
      for (VisitType visit in visitTypes) {
        if (visit.visitType == 1) {
          return visit;
        }
      }
    }
    return null;
  }

  VisitType get physicalVisitType {
    if (visitTypes != null) {
      for (VisitType visit in visitTypes) {
        if (visit.visitType == 0) {
          return visit;
        }
      }
    }
    return null;
  }

  List<int> get virtualVisitMethod {
    List<int> res = [];
    VisitType virtualVisitType = this.virtualVisitType;
    if (virtualVisitType != null) {
      return virtualVisitType.visitMethod;
    }
    return res;
  }

  int get baseVideoPrice {
    return this.virtualVisitType?.baseVideoPrice ?? 0;
  }

  int get baseVoicePrice {
    return this.virtualVisitType?.baseVoicePrice ?? 0;
  }

  int get baseTextPrice {
    return this.virtualVisitType?.baseTextPrice ?? 0;
  }

  int get basePhysicalVisitPrice {
    return this.physicalVisitType?.basePhysicalVisitPrice ?? 0;
  }

  List<int> get virtualVisitDurationPlan {
    return this.virtualVisitType?.visitDurationPlan ?? [];
  }

  List<int> get physicalVisitDurationPlan {
    return this.physicalVisitType?.visitDurationPlan ?? [];
  }

  List<int> get visitTypesNumber {
    List<int> res = [];
    this.visitTypes?.forEach((element) {
      res.add(element.visitType);
    });
    return res;
  }

  Map<DateTime, DataSourceDailyWorkTimes> get totalWorkTimes {
    Map<String, DataSourceDailyWorkTimes> res = {};

    /// physical date times
    physicalVisitType?.daysWorkTimes?.forEach((dayWorkTime) {
      String dateString =
          DateTimeService.getDateStringFormDateTime(dayWorkTime.date);
      DataSourceDailyWorkTimes d =
          res[dateString] ?? DataSourceDailyWorkTimes(dayWorkTime.date, []);
      dayWorkTime.workTimes?.forEach((workTime) {
        d.dataSourceWorkTimes.add(DataSourceWorkTime(
            eventName: VisitTypes.values[0].title,
            workTime: workTime,
            background: IColors.blue,
            dateString: dateString,
            visitType: 0));
      });
      res[dateString] = d;
    });

    /// virtual date times
    virtualVisitType?.daysWorkTimes?.forEach((dayWorkTime) {
      String dateString =
          DateTimeService.getDateStringFormDateTime(dayWorkTime.date);
      DataSourceDailyWorkTimes d =
          res[dateString] ?? DataSourceDailyWorkTimes(dayWorkTime.date, []);
      dayWorkTime.workTimes?.forEach((workTime) {
        d.dataSourceWorkTimes.add(DataSourceWorkTime(
            eventName: VisitTypes.values[1].title,
            workTime: workTime,
            background: IColors.green,
            dateString: dateString,
            visitType: 1));
      });
      res[dateString] = d;
    });
    return res.map((key, value) =>
        MapEntry(DateTimeService.getDateTimeFormDateString(key), value));
  }

  static int getPartNumberWithIndex(int r, int c) {
    return r * DoctorPlan.hourParts + c;
  }

  //
  // static List<DailyWorkTimes> getWeeklyWorkTimesWithTableData(
  //     List<List<List<int>>> daysPlanTableData) {
  //   /// TODO amir: heavy process
  //   /// this static method gets 7 days 24*4 table data and as a result will update weeklyWorkTimes
  //   ///  the start time and the end times spans as much as possible, remember to handle conflicts for work times
  //   List<List<int>> daysAvailableParts = [];
  //
  //   /// updating daysAvailableParts
  //   for (int dayIndex = 0; dayIndex < DoctorPlan.daysCount; dayIndex++) {
  //     daysAvailableParts.add([]);
  //
  //     /// day table
  //     List<List<int>> dayTableData = daysPlanTableData[dayIndex];
  //     for (int hour = 0; hour < DoctorPlan.dayHours; hour++) {
  //       for (int hPart = 0; hPart < DoctorPlan.hourParts; hPart++) {
  //         int part = getPartNumberWithIndex(hour, hPart);
  //         int value = dayTableData[hour][hPart];
  //         if (value == 1) {
  //           daysAvailableParts[dayIndex].add(part);
  //         }
  //       }
  //     }
  //   }
  //
  //   /// getting work time value start time and end time from daily part of daysAvailableParts
  //   List<DailyWorkTimes> weeklyWorkTimes = [];
  //   for (int dayIndex = 0; dayIndex < DoctorPlan.daysCount; dayIndex++) {
  //     weeklyWorkTimes.add(DailyWorkTimes(dayIndex, []));
  //
  //     /// day table
  //     List<int> dayHourParts = daysAvailableParts[dayIndex];
  //     dayHourParts.sort();
  //     int startPart;
  //     int endPart;
  //     for (int hourIndex = 0; hourIndex < dayHourParts.length; hourIndex++) {
  //       int part = dayHourParts[hourIndex];
  //       if (startPart == null && endPart == null) {
  //         startPart = part;
  //         endPart = part;
  //       } else if (startPart != null && endPart != null) {
  //         if (endPart == part - 1) {
  //           endPart++;
  //         } else {
  //           /// end of a work time
  //           String startTime = DateTimeService.convertMinuteToTimeString(
  //               startPart * DoctorPlan.hourMinutePart);
  //           String endTime = DateTimeService.convertMinuteToTimeString(
  //               (endPart * DoctorPlan.hourMinutePart +
  //                       DoctorPlan.hourMinutePart) %
  //                   (24 * 60));
  //
  //           /// adding workTime to weeklyWorkTimes
  //           weeklyWorkTimes[dayIndex]
  //               .workTimes
  //               .add(WorkTime(startTime: startTime, endTime: endTime));
  //
  //           /// starting a new workTime
  //           startPart = part;
  //           endPart = part;
  //         }
  //       }
  //       if (hourIndex == dayHourParts.length - 1) {
  //         String startTime = DateTimeService.convertMinuteToTimeString(
  //             startPart * DoctorPlan.hourMinutePart);
  //         String endTime = DateTimeService.convertMinuteToTimeString(
  //             (endPart * DoctorPlan.hourMinutePart +
  //                     DoctorPlan.hourMinutePart) %
  //                 (24 * 60));
  //
  //         /// adding workTime to weeklyWorkTimes
  //         weeklyWorkTimes[dayIndex]
  //             .workTimes
  //             .add(WorkTime(startTime: startTime, endTime: endTime));
  //       }
  //     }
  //   }
  //   return weeklyWorkTimes;
  // }

  List<List<int>> getTakenVisitDailyTimeTable(String dateString) {
    /// TODO amir: heavy process
    /// initial empty table
    List<List<int>> takenTimes = [];
    for (int i = 0; i < DoctorPlan.dayHours; i++) {
      List<int> dayRow = [];
      for (int j = 0; j < DoctorPlan.hourParts; j++) {
        dayRow.add(0);
      }
      takenTimes.add(dayRow);
    }

    /// fill table
    if (this.recentVisits != null) {
      this.recentVisits[dateString]?.forEach((ReservedVisit reservedVisit) {
        int start = DateTimeService.getTimeMinute(reservedVisit.startTime);
        int startPart = start ~/ DoctorPlan.hourMinutePart;
        for (int index = startPart;
            index <= startPart + reservedVisit.durationPlan;
            index++) {
          int i = index ~/ DoctorPlan.hourParts;
          int j = index % DoctorPlan.hourParts;
          takenTimes[i][j] = 1;
        }
      });
    }

    return takenTimes;
  }

  DoctorPlan(
      {this.id,
      this.visitTypes,
      this.createdDate,
      this.modifiedDate,
      this.enabled});

  DoctorPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    visitTypes = [];
    if (json.containsKey("visit_types")) {
      (json['visit_types'] as List).forEach((element) {
        visitTypes.add(VisitType.fromJson(element));
      });
    }
    recentVisits = {};
    if (json.containsKey("recent_visits")) {
      (json['recent_visits'] as List).forEach((element) {
        ReservedVisit takenVisitTime = ReservedVisit.fromJson(element);
        recentVisits[takenVisitTime.jalaliDate] =
            (recentVisits[takenVisitTime.jalaliDate] ?? []) + [takenVisitTime];
      });
    }
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
    enabled = json['enabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['visit_types'] = this.visitTypes.map((e) => e.toJson()).toList();

    data['created_date'] = this.createdDate;
    data['modified_date'] = this.modifiedDate;
    data['enabled'] = this.enabled;
    return data;
  }
}

class VisitType {
  int visitType;
  List<DailyWorkTimes> daysWorkTimes;
  int baseVideoPrice;
  int baseVoicePrice;
  int baseTextPrice;
  int basePhysicalVisitPrice;
  List<int> visitMethod;
  List<int> visitDurationPlan;

  String get visitTypeName {
    VisitTypes.values[visitType]?.title;
  }

  VisitType(
      {this.visitType,
      this.visitMethod,
      this.visitDurationPlan,
      this.daysWorkTimes,
      this.baseVideoPrice,
      this.baseVoicePrice,
      this.baseTextPrice,
      this.basePhysicalVisitPrice}) {
    /// set initial values for weekly days
    initializeWeeklyWorkTimesIfNecessary();
  }

  int getMinWorkTimeHour(int dayIndex) {
    int res = 24;
    daysWorkTimes[dayIndex].workTimes.forEach((element) {
      if (element.startTimeHour < res) {
        res = element.startTimeHour;
      }
    });
    return res;
  }

  void addWorkTime(DateTime date, String startTime, String endTime) {
    /// TODO manage conflicts
    String newDate = DateTimeService.getDateStringFormDateTime(date);
    WorkTime workTime = WorkTime(endTime: endTime, startTime: startTime);

    for (DailyWorkTimes dailyWorkTimes in this.daysWorkTimes) {
      String date =
          DateTimeService.getDateStringFormDateTime(dailyWorkTimes.date);
      if (date == newDate) {
        dailyWorkTimes.workTimes.add(workTime);
        return;
      }
    }

    /// new DailyWorkTimes
    DailyWorkTimes dailyWorkTimes = DailyWorkTimes(date, [workTime]);
    this.daysWorkTimes.add(dailyWorkTimes);
  }

  void removeWorkTime(DateTime date, String startTime, String endTime) {
    String oldDate = DateTimeService.getDateStringFormDateTime(date);
    int indexToBeRemoved = -1;

    loop:
    for (DailyWorkTimes dailyWorkTimes in this.daysWorkTimes) {
      String date =
          DateTimeService.getDateStringFormDateTime(dailyWorkTimes.date);
      if (date == oldDate) {
        for (int workTimeIndex = 0;
            workTimeIndex < dailyWorkTimes.workTimes.length;
            workTimeIndex++) {
          WorkTime workTime = dailyWorkTimes.workTimes[workTimeIndex];
          if (workTime.startTime == startTime && workTime.endTime == endTime) {
            indexToBeRemoved = workTimeIndex;
            break;
          }
        }
        if (indexToBeRemoved != -1) {
          dailyWorkTimes.workTimes.removeAt(indexToBeRemoved);
          break loop;
        }
      }
    }
  }

  int getMaxWorkTimeHour(int dayIndex) {
    int res = 0;
    daysWorkTimes[dayIndex].workTimes.forEach((element) {
      if (element.endTimeHour + 1 > res) {
        res = element.endTimeHour + 1;
      }
    });
    return res;
  }

  static List<List<int>> getEmptyTablePlan() {
    List<List<int>> workTimeTable = [];
    for (int i = 0; i < DoctorPlan.dayHours; i++) {
      List<int> dayRow = [];
      for (int j = 0; j < DoctorPlan.hourParts; j++) {
        dayRow.add(0);
      }
      workTimeTable.add(dayRow);
    }
    return workTimeTable;
  }

  List<int> get availableDays {
    List<int> availableDays = [];

    /// TODO
    // DaysWorkTimes.forEach((element) {
    //   if (element.workTimes != null && element.workTimes.length > 0) {
    //     availableDays.add(element.date);
    //   }
    // });
    return availableDays;
  }

  void initializeWeeklyWorkTimesIfNecessary() {
    if (this.daysWorkTimes == null) this.daysWorkTimes = [];

    /// TODO
    // Map<int, DailyWorkTimes> mapWeekWorkTimes = {};
    // DaysWorkTimes.forEach((workTimesList) {
    //   mapWeekWorkTimes[workTimesList.date] = workTimesList;
    // });
    // DaysWorkTimes = [];
    // for (int i = 0; i < DoctorPlan.daysCount; i++) {
    //   if (mapWeekWorkTimes.containsKey(i)) {
    //     DaysWorkTimes.add(mapWeekWorkTimes[i]);
    //   } else {
    //     DaysWorkTimes.add(DailyWorkTimes(i, []));
    //   }
    // }
  }

  VisitType.fromJson(Map<String, dynamic> json) {
    visitType = intPossible(json['visit_type']);
    visitMethod = json['visit_method'].cast<int>();
    visitDurationPlan = json['visit_duration_plan'].cast<int>();
    // availableDays = json['available_days'].cast<int>(); /// this field has been removed
    if (json['work_days'] != null) {
      daysWorkTimes = [];

      /// TODO
      // Map<int, DailyWorkTimes> mapWeekWorkTimes = {};
      // json['work_days'].forEach((workTimesList) {
      //   List<WorkTime> dayWorkTimes = [];
      //   workTimesList['work_times'].forEach((w) {
      //     dayWorkTimes.add(new WorkTime.fromJson(w));
      //   });
      //   DailyWorkTimes dailyWorkTimes =
      //       DailyWorkTimes(workTimesList['day'], dayWorkTimes);
      //   mapWeekWorkTimes[workTimesList['day']] = dailyWorkTimes;
      // });
      // for (int i = 0; i < DoctorPlan.daysCount; i++) {
      //   if (mapWeekWorkTimes.containsKey(i)) {
      //     DaysWorkTimes.add(mapWeekWorkTimes[i]);
      //   } else {
      //     DaysWorkTimes.add(DailyWorkTimes(i, []));
      //   }
      // }
    } else {
      initializeWeeklyWorkTimesIfNecessary();
    }
    baseVideoPrice = json['base_video_price'] ?? 0;
    baseTextPrice = json['base_text_price'] ?? 0;
    baseVoicePrice = json['base_voice_price'] ?? 0;
    basePhysicalVisitPrice = json['base_physical_visit_price'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['visit_type'] = this.visitType;
    data['visit_method'] = this.visitMethod;
    data['visit_duration_plan'] = this.visitDurationPlan;
    data['work_days'] = <String, dynamic>{};
    for (int i = 0; i < daysWorkTimes.length; i++) {
      data['work_days'][daysWorkTimes[i].dateString] =
          daysWorkTimes[i].workTimes.map((e) => e.toJson());
    }
    data['base_video_price'] = this.baseVideoPrice;
    data['base_voice_price'] = this.baseVoicePrice;
    data['base_text_price'] = this.baseTextPrice;
    data['base_physical_visit_price'] = this.basePhysicalVisitPrice;

    return data;
  }
}

class DailyWorkTimes {
  DateTime date;
  List<WorkTime> workTimes;

  String get dateString {
    return DateTimeService.getDateStringFormDateTime(date);
  }

  DailyWorkTimes(this.date, this.workTimes);

  DailyWorkTimes.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    workTimes = (json['work_times'] as List).map((e) => WorkTime.fromJson(e));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['work_times'] = [];
    workTimes.forEach((element) {
      data['work_times'].add(element.toJson());
    });
    return data;
  }
}

class ReservedVisit {
  String startTime;
  int durationPlan;

  // int status;
  String jalaliDate;

  ReservedVisit.fromJson(Map<String, dynamic> json) {
    String visitDateTime = json['request_visit_time'];
    DateTime dateTime = DateTimeService.getDateTimeFromStandardString(
        visitDateTime.split("+")[0]);
    Jalali jalali = Jalali.fromDateTime(dateTime);

    jalaliDate = getJalaliDateStringFromJalali(jalali);
    startTime = getTimeStringFromDateTime(dateTime, withSeconds: false);
    durationPlan = json['visit_duration_plan'];
    // status
  }
}

class WorkTime {
  String startTime;
  String endTime;

  int get minuteDuration {
    return DateTimeService.getTimeMinute(endTime) -
        DateTimeService.getTimeMinute(startTime);
  }

  int get startTimeHour {
    return int.parse(startTime.split(":")[0]);
  }

  int get endTimeHour {
    int end = int.parse(endTime.split(":")[0]);
    if (end < startTimeHour && end == 0) {
      end = 23;
    }
    return end;
  }

  WorkTime({this.startTime, this.endTime});

  WorkTime.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    return data;
  }
}
//
// class DoctorWorkDataSource{
//   List<DataSourceWorkTime> appointments;
//   DoctorWorkDataSource(List<DataSourceWorkTime> source) {
//     appointments = source;
//   }
//
//   /// calendar stuff
//   DateTime getStartTime(int index) {
//     return (appointments[index] as DataSourceWorkTime).startDateTime;
//   }
//
//   DateTime getEndTime(int index) {
//     return (appointments[index] as DataSourceWorkTime).endDateTime;
//   }
//
//   bool isAllDay(int index) {
//     return false;
//   }
//
//   String getSubject(int index) {
//     return appointments[index].eventName;
//   }
//
//   String getStartTimeZone(int index) {
//     return '';
//   }
//
//   String getEndTimeZone(int index) {
//     return '';
//   }
//
//   Color getColor(int index) {
//     return appointments[index].background;
//   }
//
//   /// end calendar stuff
// }

class DataSourceDailyWorkTimes {
  DateTime date;
  List<DataSourceWorkTime> dataSourceWorkTimes;

  DataSourceDailyWorkTimes(this.date, this.dataSourceWorkTimes);
}

class DataSourceWorkTime implements Event {
  DataSourceWorkTime(
      {@required this.eventName,
      @required this.dateString,
      @required this.workTime,
      @required this.background,
      @required this.visitType});

  int visitType;
  String eventName;
  String dateString;
  WorkTime workTime;
  Color background;

  DateTime get startDateTime {
    return DateTimeService.getDateTimeFromDateStringAndTimeStringSlash(
        dateString, workTime.startTime);
  }

  DateTime get endDateTime {
    return DateTimeService.getDateTimeFromDateStringAndTimeStringSlash(
        dateString, workTime.endTime);
  }

  @override
  int get duration {
    return workTime.minuteDuration;
  }

  @override
  int get startMinuteOfDay {
    return DateTimeService.getTimeMinute(workTime.startTime);
  }

  @override
  String get title => eventName;

  @override
  Color get color => background;

  @override
  bool isEqual(DataSourceWorkTime event) {
    bool c1 = this.visitType == event.visitType;
    bool c2 = this.eventName == event.eventName;
    bool c3 = this.dateString == event.dateString;
    bool c4 = this.background == event.background;
    bool c5 = this.workTime.startTime == event.workTime.startTime &&
        this.workTime.endTime == event.workTime.endTime;
    if (c1 && c2 && c3 && c4 && c5) {
      return true;
    }
    return false;
  }
}
