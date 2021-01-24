import 'dart:ui';

import 'package:docup/constants/colors.dart';
import 'package:docup/models/CalendarEvent.dart';
import 'package:docup/utils/Utils.dart';
import 'package:docup/utils/dateTimeService.dart';
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
    Map<DateTime, DataSourceDailyWorkTimes> res = {};
    DateTime date1 = DateTimeService.getCurrentDateTime();
    res[date1] = (DataSourceDailyWorkTimes(date1, [
      DataSourceWorkTime(
          eventName: "ویزیت حضوری",
          workTime: WorkTime(startTime: "10:30", endTime: "18:00"),
          background: IColors.blue,
          dateString: DateTimeService.getDateStringFormDateTime(date1)),
      DataSourceWorkTime(
          eventName: "ویزیت مجازی",
          background: IColors.green,
          workTime: WorkTime(startTime: "10:30", endTime: "12:00"),
          dateString: DateTimeService.getDateStringFormDateTime(date1)),
    ]));
    DateTime date2 = date1.add(Duration(days: 2));

    res[date2] = (DataSourceDailyWorkTimes(date2, [
      DataSourceWorkTime(
          eventName: "ویزیت حضوری",
          background: IColors.blue,
          workTime: WorkTime(startTime: "19:30", endTime: "22:00"),
          dateString: DateTimeService.getDateStringFormDateTime(date2)),
      DataSourceWorkTime(
          eventName: "ویزیت مجازی",
          workTime: WorkTime(startTime: "20:30", endTime: "23:00"),
          dateString: DateTimeService.getDateStringFormDateTime(date2)),
    ]));

    DateTime date3 = date1.add(Duration(days: 3));

    res[date3] = (DataSourceDailyWorkTimes(date3, [
      DataSourceWorkTime(
          eventName: "ویزیت حضوری",
          background: IColors.blue,
          workTime: WorkTime(startTime: "15:30", endTime: "22:00"),
          dateString: DateTimeService.getDateStringFormDateTime(date3)),
      DataSourceWorkTime(
          eventName: "ویزیت مجازی",
          workTime: WorkTime(startTime: "16:30", endTime: "19:00"),
          dateString: DateTimeService.getDateStringFormDateTime(date3)),
    ]));


    DateTime date4 = date1.add(Duration(days: 4));

    res[date4] = (DataSourceDailyWorkTimes(date4, [
      DataSourceWorkTime(
          eventName: "ویزیت حضوری",
          background: IColors.blue,
          workTime: WorkTime(startTime: "11:30", endTime: "12:00"),
          dateString: DateTimeService.getDateStringFormDateTime(date4)),
      DataSourceWorkTime(
          eventName: "ویزیت مجازی",
          workTime: WorkTime(startTime: "10:30", endTime: "12:00"),
          dateString: DateTimeService.getDateStringFormDateTime(date4)),
    ]));

    DateTime date5 = date1.add(Duration(days: 5));

    res[date5] = (DataSourceDailyWorkTimes(date5, [
      DataSourceWorkTime(
          eventName: "ویزیت حضوری",
          background: IColors.blue,
          workTime: WorkTime(startTime: "11:30", endTime: "12:00"),
          dateString: DateTimeService.getDateStringFormDateTime(date5)),
      DataSourceWorkTime(
          eventName: "ویزیت مجازی",
          workTime: WorkTime(startTime: "10:30", endTime: "12:00"),
          dateString: DateTimeService.getDateStringFormDateTime(date5)),
    ]));
    return res;
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
  List<DailyWorkTimes> DaysWorkTimes;
  int baseVideoPrice;
  int baseVoicePrice;
  int baseTextPrice;
  int basePhysicalVisitPrice;
  List<int> visitMethod;
  List<int> visitDurationPlan;

  static getVisitTypeName(int visitType) {
    if (visitType == 0) {
      return "حضوری";
    } else if (visitType == 1) {
      return "مجازی";
    }
  }

  String get visitTypeName {
    if (visitType == 0) {
      return "حضوری";
    } else if (visitType == 1) {
      return "مجازی";
    }
  }

  VisitType(
      {this.visitType,
      this.visitMethod,
      this.visitDurationPlan,
      this.DaysWorkTimes,
      this.baseVideoPrice,
      this.baseVoicePrice,
      this.baseTextPrice,
      this.basePhysicalVisitPrice}) {
    /// set initial values for weekly days
    initializeWeeklyWorkTimesIfNecessary();
  }

  int getMinWorkTimeHour(int dayIndex) {
    int res = 24;
    DaysWorkTimes[dayIndex].workTimes.forEach((element) {
      if (element.startTimeHour < res) {
        res = element.startTimeHour;
      }
    });
    return res;
  }

  int getMaxWorkTimeHour(int dayIndex) {
    int res = 0;
    DaysWorkTimes[dayIndex].workTimes.forEach((element) {
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

  // List<List<int>> getDailyWorkTimeTable(int dayIndex) {
  //   /// TODO amir: heavy process
  //   /// initial empty table
  //   List<List<int>> workTimeTable = VisitType.getEmptyTablePlan();
  //
  //   /// fill table
  //   this.DaysWorkTimes[dayIndex].workTimes.forEach((WorkTime workTime) {
  //     int start = DateTimeService.getTimeMinute(workTime.startTime);
  //     int startPart = start ~/ DoctorPlan.hourMinutePart;
  //     int end = DateTimeService.getTimeMinute(workTime.endTime);
  //     end = start > 0 && end == 0 ? 24 * 60 : end;
  //     int endPart = end ~/ DoctorPlan.hourMinutePart;
  //     for (int index = startPart; index <= endPart - 1; index++) {
  //       int i = index ~/ DoctorPlan.hourParts;
  //       int j = index % DoctorPlan.hourParts;
  //       workTimeTable[i][j] = 1;
  //     }
  //   });
  //   return workTimeTable;
  // }

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
    if (this.DaysWorkTimes == null) this.DaysWorkTimes = [];

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
      DaysWorkTimes = [];

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
    data['work_days'] = [];
    for (int i = 0; i < DoctorPlan.daysCount; i++) {
      data['work_days'].add(DaysWorkTimes[i].toJson());
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
      {this.eventName, this.dateString, this.workTime, this.background});

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
}
