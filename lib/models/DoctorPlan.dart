import 'package:docup/utils/Utils.dart';

class DoctorPlan {
  static final daysCount = 7;
  static final dayHours = 24;

  /// equal to 15 minute
  static final hourParts = 4;
  static final hourMinutePart = 15;

  /// object fields
  int id;
  List<int> visitType;
  List<int> visitMethod;
  List<int> visitDurationPlan;

  // List<int> availableDays;
  List<DailyWorkTimes> weeklyWorkTimes;
  String createdDate;
  String modifiedDate;
  bool enabled;
  int baseVideoPrice;
  int baseVoicePrice;
  int baseTextPrice;
  int basePhysicalVisitPrice;

  List<int> get availableDays {
    List<int> availableDays = [];
    weeklyWorkTimes.forEach((element) {
      if (element.workTimes != null && element.workTimes.length > 0) {
        availableDays.add(element.day);
      }
    });
    return availableDays;
  }

  static int getPartNumberWithIndex(int r, int c) {
    return r * DoctorPlan.hourParts + c;
  }

  static List<DailyWorkTimes> getWeeklyWorkTimesWithTableData(

      /// TODO amir: heavy process
      /// this static method gets 7 days 24*4 table data and as a result will update weeklyWorkTimes
      ///  the start time and the end times spans as much as possible, remember to handle conflicts for work times
      List<List<List<int>>> daysPlanTableData) {
    List<List<int>> daysAvailableParts = [];

    /// updating daysAvailableParts
    for (int dayIndex = 0; dayIndex < DoctorPlan.daysCount; dayIndex++) {
      daysAvailableParts.add([]);

      /// day table
      List<List<int>> dayTableData = daysPlanTableData[dayIndex];
      for (int hour = 0; hour < DoctorPlan.dayHours; hour++) {
        for (int hPart = 0; hPart < DoctorPlan.hourParts; hPart++) {
          int part = getPartNumberWithIndex(hour, hPart);
          int value = dayTableData[hour][hPart];
          if (value == 1) {
            daysAvailableParts[dayIndex].add(part);
          }
        }
      }
    }

    /// getting work time value start time and end time from daily part of daysAvailableParts
    List<DailyWorkTimes> weeklyWorkTimes = [];
    for (int dayIndex = 0; dayIndex < DoctorPlan.daysCount; dayIndex++) {
      weeklyWorkTimes.add(DailyWorkTimes(dayIndex, []));

      /// day table
      List<int> dayHourParts = daysAvailableParts[dayIndex];
      dayHourParts.sort();
      int startPart;
      int endPart;
      for (int hourIndex = 0; hourIndex < dayHourParts.length; hourIndex++) {
        int part = dayHourParts[hourIndex];
        if (startPart == null && endPart == null) {
          startPart = part;
          endPart = part;
        } else if (startPart != null && endPart != null) {
          if (hourIndex == dayHourParts.length - 1) {
            endPart++;
          }
          if (endPart == part - 1) {
            endPart++;
          } else {
            /// end of a work time
            String startTime = convertMinuteToTimeString(
                startPart * DoctorPlan.hourMinutePart);
            String endTime = convertMinuteToTimeString(
                endPart * DoctorPlan.hourMinutePart +
                    DoctorPlan.hourMinutePart);

            /// adding workTime to weeklyWorkTimes
            weeklyWorkTimes[dayIndex]
                .workTimes
                .add(WorkTimes(startTime: startTime, endTime: endTime));

            /// starting a new workTime
            startPart = part;
            endPart = part;
          }
        }
      }
    }
    return weeklyWorkTimes;
  }

  int getMinWorkTimeHour(int dayIndex) {
    int res = 24;
    weeklyWorkTimes[dayIndex].workTimes.forEach((element) {
      if (element.startTimeHour < res) {
        res = element.startTimeHour;
      }
    });
    return res;
  }

  int getMaxWorkTimeHour(int dayIndex) {
    int res = 0;
    weeklyWorkTimes[dayIndex].workTimes.forEach((element) {
      if (element.endTimeHour + 1 > res) {
        res = element.endTimeHour + 1;
      }
    });
    return res;
  }

  List<List<int>> getDailyWorkTimeTable(int dayIndex) {
    /// TODO amir: heavy process
    /// initial empty table
    List<List<int>> workTimeTable = [];
    for (int i = 0; i < DoctorPlan.dayHours; i++) {
      List<int> dayRow = [];
      for (int j = 0; j < DoctorPlan.hourParts; j++) {
        dayRow.add(0);
      }
      workTimeTable.add(dayRow);
    }

    /// fill table
    this.weeklyWorkTimes[dayIndex].workTimes.forEach((WorkTimes workTime) {
      int start = getTimeMinute(workTime.startTime);
      int startPart = start ~/ DoctorPlan.hourMinutePart;
      int end = getTimeMinute(workTime.endTime);
      int endPart = end ~/ DoctorPlan.hourMinutePart;
      for (int index = startPart; index <= endPart - 1; index++) {
        int i = index ~/ DoctorPlan.hourParts;
        int j = index % DoctorPlan.hourParts;
        workTimeTable[i][j] = 1;
      }
    });
    return workTimeTable;
  }

  DoctorPlan(
      {this.id,
      this.visitType,
      this.visitMethod,
      this.visitDurationPlan,
      // this.availableDays,
      this.weeklyWorkTimes,
      this.createdDate,
      this.modifiedDate,
      this.enabled,
      this.baseVideoPrice,
      this.baseVoicePrice,
      this.baseTextPrice,
      this.basePhysicalVisitPrice}) {
    /// set initial values for weekly days
    initializeWeeklyWorkTimesIfNecessary();
  }

  DoctorPlan copy() {
    this.id = id;
    this.visitType = visitType;
    this.visitMethod = visitMethod;
    this.visitDurationPlan = visitDurationPlan;

    // List<int> availableDays;
    this.weeklyWorkTimes = weeklyWorkTimes;
    this.createdDate = createdDate;
    this.modifiedDate = modifiedDate;
    this.enabled = enabled;
    this.baseVideoPrice = baseVideoPrice;
    this.baseVoicePrice = baseVoicePrice;
    this.baseTextPrice = baseTextPrice;
    this.basePhysicalVisitPrice = basePhysicalVisitPrice;
  }

  void initializeWeeklyWorkTimesIfNecessary() {
    if (this.weeklyWorkTimes == null) this.weeklyWorkTimes = [];

    Map<int, DailyWorkTimes> mapWeekWorkTimes = {};
    weeklyWorkTimes.forEach((workTimesList) {
      mapWeekWorkTimes[workTimesList.day] = workTimesList;
    });
    weeklyWorkTimes = [];
    for (int i = 0; i < DoctorPlan.daysCount; i++) {
      if (mapWeekWorkTimes.containsKey(i)) {
        weeklyWorkTimes.add(mapWeekWorkTimes[i]);
      } else {
        weeklyWorkTimes.add(DailyWorkTimes(i, []));
      }
    }
  }

  DoctorPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    visitType = json['visit_type'].cast<int>();
    visitMethod = json['visit_method'].cast<int>();
    visitDurationPlan = json['visit_duration_plan'].cast<int>();
    // availableDays = json['available_days'].cast<int>(); /// this field has been removed
    if (json['work_days'] != null) {
      weeklyWorkTimes = [];
      Map<int, DailyWorkTimes> mapWeekWorkTimes = {};
      json['work_days'].forEach((workTimesList) {
        List<WorkTimes> dayWorkTimes = [];
        workTimesList['work_times'].forEach((w) {
          dayWorkTimes.add(new WorkTimes.fromJson(w));
        });
        DailyWorkTimes dailyWorkTimes =
            DailyWorkTimes(workTimesList['day'], dayWorkTimes);
        mapWeekWorkTimes[workTimesList['day']] = dailyWorkTimes;
      });
      for (int i = 0; i < DoctorPlan.daysCount; i++) {
        if (mapWeekWorkTimes.containsKey(i)) {
          weeklyWorkTimes.add(mapWeekWorkTimes[i]);
        } else {
          weeklyWorkTimes.add(DailyWorkTimes(i, []));
        }
      }
    } else {
      initializeWeeklyWorkTimesIfNecessary();
    }
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
    enabled = json['enabled'];
    baseVideoPrice = json['base_video_price'] ?? 0;
    baseTextPrice = json['base_text_price'] ?? 0;
    baseVoicePrice = json['base_voice_price'] ?? 0;
    basePhysicalVisitPrice = json['base_physical_visit_price'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['visit_type'] = this.visitType;
    data['visit_method'] = this.visitMethod;
    data['visit_duration_plan'] = this.visitDurationPlan;
    // data['available_days'] = this.availableDays; /// this field has been removed
    initializeWeeklyWorkTimesIfNecessary();
    data['work_days'] = [];
    for (int i = 0; i < DoctorPlan.daysCount; i++) {
      data['work_days'].add(weeklyWorkTimes[i].toJson());
    }

    data['created_date'] = this.createdDate;
    data['modified_date'] = this.modifiedDate;
    data['enabled'] = this.enabled;
    data['base_video_price'] = this.baseVideoPrice;
    data['base_voice_price'] = this.baseVoicePrice;
    data['base_text_price'] = this.baseTextPrice;
    data['base_physical_visit_price'] = this.basePhysicalVisitPrice;
    return data;
  }
}

class DailyWorkTimes {
  int day;
  List<WorkTimes> workTimes;

  DailyWorkTimes(this.day, this.workTimes);

  DailyWorkTimes.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    workTimes = (json['work_times'] as List).map((e) => WorkTimes.fromJson(e));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['work_times'] = [];
    workTimes.forEach((element) {
      data['work_times'].add(element.toJson());
    });
    return data;
  }
}

class WorkTimes {
  String startTime;
  String endTime;

  int get startTimeHour {
    return int.parse(startTime.split(":")[0]);
  }

  int get endTimeHour {
    return int.parse(endTime.split(":")[0]);
  }

  WorkTimes({this.startTime, this.endTime});

  WorkTimes.fromJson(Map<String, dynamic> json) {
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
