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
  VisitType getVisitTypeDataWithType(int type, {bool initialIfNull = false}) {
    if (type == 0 && physicalVisitType != null) {
      return physicalVisitType;
    } else if (type == 1 && virtualVisitType != null) {
      return virtualVisitType;
    }
    if (initialIfNull) {
      VisitType visitType = VisitType(
          visitType: type,
          daysWorkTimes: [],
          visitDurationPlan: [],
          visitMethod: []);
      visitTypes.add(visitType);
      return visitType;
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

  String get jalaliStringNewestActiveVisitTime {
    DateTime now = DateTimeService.getCurrentDateTime();
    DateTime nearest;
    daysWorkTimes.forEach((d) {
      if (d.date.isAfter(now)) {
        if (nearest == null || d.date.isBefore(nearest)) {
          nearest = d.date;
        }
      }
    });
    if (nearest == null) {
      return null;
    }
    return DateTimeService.getJalaliStringFromJalali(
        DateTimeService.getJalaliformDateTime(nearest));
  }

  DailyWorkTimes getDailyWorkTimesByDateString(String dateString) {
    for (DailyWorkTimes dailyWorkTimes in daysWorkTimes) {
      String dayDateString =
          DateTimeService.getDateStringFormDateTime(dailyWorkTimes.date);
      if (dayDateString == dateString) {
        return dailyWorkTimes;
      }
    }
    return null;
  }

  int getMinWorkTimeHour(String dateString) {
    int res = 24;

    getDailyWorkTimesByDateString(dateString)?.workTimes?.forEach((element) {
      if (element.startTimeHour < res) {
        res = element.startTimeHour;
      }
    });
    return res;
  }

  int getMaxWorkTimeHour(String dateString) {
    int res = 0;

    getDailyWorkTimesByDateString(dateString)?.workTimes?.forEach((element) {
      if (element.endTimeHour + 1 > res) {
        res = element.endTimeHour + 1;
      }
    });

    return res;
  }

  WorkTime addWorkTimeOrReturnConflict(
      DateTime date, String startTime, String endTime) {
    /// TODO manage conflicts
    String newDate = DateTimeService.getDateStringFormDateTime(date);
    WorkTime newWorkTime = WorkTime(endTime: endTime, startTime: startTime);
    DailyWorkTimes dailyWorkTimes = getDailyWorkTimesByDateString(newDate);
    if (dailyWorkTimes != null) {
      /// check conflict
      int ws1 = DateTimeService.getTimeMinute(newWorkTime.startTime);
      int we1 = DateTimeService.getTimeMinute(newWorkTime.endTime);

      for(WorkTime workTime in dailyWorkTimes.workTimes){
        int ws2 = DateTimeService.getTimeMinute(workTime.startTime);
        int we2 = DateTimeService.getTimeMinute(workTime.endTime);
        if ((ws2 < we1 && we1 < we2) || (ws1 < we2 && we2 < we1)) {
          return workTime;
        }
      }
      dailyWorkTimes.workTimes.add(newWorkTime);
      return null;
    } else {
      /// new DailyWorkTimes
      dailyWorkTimes = DailyWorkTimes(date, [newWorkTime]);
      this.daysWorkTimes.add(dailyWorkTimes);
      return null;
    }
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

  List<List<int>> getDailyWorkTimeTable(String dateString) {
    /// TODO amir: heavy process
    /// initial empty table
    List<List<int>> workTimeTable = VisitType.getEmptyTablePlan();

    /// fill table
    getDailyWorkTimesByDateString(dateString)
        ?.workTimes
        ?.forEach((WorkTime workTime) {
      int start = DateTimeService.getTimeMinute(workTime.startTime);
      int startPart = (start / DoctorPlan.hourMinutePart).round();
      int end = DateTimeService.getTimeMinute(workTime.endTime);
      end = start > 0 && end == 0 ? 24 * 60 : end;
      int endPart = end ~/ DoctorPlan.hourMinutePart;
      for (int index = startPart; index <= endPart - 1; index++) {
        int i = index ~/ DoctorPlan.hourParts;
        int j = index % DoctorPlan.hourParts;
        workTimeTable[i][j] = 1;
      }
    });
    return workTimeTable;
  }

  List<int> get availableDays {
    List<int> availableDays = [];

    /// TODO

    return availableDays;
  }

  void initializeWeeklyWorkTimesIfNecessary() {
    if (this.daysWorkTimes == null) this.daysWorkTimes = [];
  }

  VisitType.fromJson(Map<String, dynamic> json) {
    visitType = intPossible(json['visit_type']);
    visitMethod = json['visit_method'].cast<int>();
    visitDurationPlan = json['visit_duration_plan'].cast<int>();
    daysWorkTimes = [];
    if (json['work_days'] != null) {
      json['work_days'].forEach((dateWorkTime) {
        List<WorkTime> dayWorkTimes = [];
        dateWorkTime['work_times'].forEach((w) {
          dayWorkTimes.add(new WorkTime.fromJson(w));
        });
        DateTime date =
            DateTimeService.getDateTimeFormDateString(dateWorkTime['date']);
        DailyWorkTimes dailyWorkTimes = DailyWorkTimes(date, dayWorkTimes);
        daysWorkTimes.add(dailyWorkTimes);
      });
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
    data['work_days'] = [];
    daysWorkTimes.forEach((element) {
      data['work_days'].add(element.toJson());
    });
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
    data['date'] = DateTimeService.getDateStringFormDateTime(date);
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

    jalaliDate = DateTimeService.getJalaliStringFromJalali(jalali);
    startTime =
        DateTimeService.getTimeStringFromDateTime(dateTime, withSeconds: false);
    durationPlan = json['visit_duration_plan'];
    // status
  }
}

class WorkTime {
  String startTime;
  String endTime;

  String toString() {
    return startTime + "-" + endTime;
  }

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
