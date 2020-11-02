import 'package:docup/utils/Utils.dart';

class DoctorPlan {
  int id;
  List<int> visitType;
  List<int> visitMethod;
  List<int> visitDurationPlan;
  List<int> availableDays;
  List<WorkTimes> workTimes;
  String createdDate;
  String modifiedDate;
  bool enabled;
  int baseVideoPrice;
  int baseVoicePrice;
  int baseTextPrice;
  int basePhysicalVisitPrice;

  DoctorPlan(
      {this.id,
      this.visitType,
      this.visitMethod,
      this.visitDurationPlan,
      this.availableDays,
      this.workTimes,
      this.createdDate,
      this.modifiedDate,
      this.enabled,
      this.baseVideoPrice,
      this.baseVoicePrice,
      this.baseTextPrice,
      this.basePhysicalVisitPrice});

  DoctorPlan.fromJson(Map<String, dynamic> json) {
    utf8IfPossible("srg");
    id = json['id'];
    visitType = json['visit_type'].cast<int>();
    visitMethod = json['visit_method'].cast<int>();
    visitDurationPlan = json['visit_duration_plan'].cast<int>();
    availableDays = json['available_days'].cast<int>();
    if (json['work_times'] != null) {
      workTimes = new List<WorkTimes>();
      json['work_times'].forEach((v) {
        workTimes.add(new WorkTimes.fromJson(v));
      });
    }
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
    enabled = json['enabled'];
    baseVideoPrice = json['base_video_price']??0;
    baseTextPrice = json['base_text_price']??0;
    baseVoicePrice = json['base_voice_price']??0;
    basePhysicalVisitPrice = json['base_physical_visit_price']??0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['visit_type'] = this.visitType;
    data['visit_method'] = this.visitMethod;
    data['visit_duration_plan'] = this.visitDurationPlan;
    data['available_days'] = this.availableDays;
    if (this.workTimes != null) {
      data['work_times'] = this.workTimes.map((v) => v.toJson()).toList();
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

class WorkTimes {
  String startTime;
  String endTime;

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
