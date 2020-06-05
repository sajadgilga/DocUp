class DoctorPlan {
  int id;
  List<int> visitType;
  List<int> visitMethod;
  List<int> visitDurationPlan;
  List<int> availableDays;
  int baseVideoPrice;
  int baseTextPrice;
  String startTime;
  String endTime;

  DoctorPlan(
      {this.id, this.visitType,
        this.visitMethod,
        this.visitDurationPlan,
        this.availableDays,
        this.baseVideoPrice,
        this.baseTextPrice,
        this.startTime,
        this.endTime});

  DoctorPlan.fromJson(Map<String, dynamic> json) {
    if(json.containsKey('id')) {
      id = json['id'];
    }
    visitType = json['visit_type'].cast<int>();
    visitMethod = json['visit_method'].cast<int>();
    visitDurationPlan = json['visit_duration_plan'].cast<int>();
    availableDays = json['available_days'].cast<int>();
    baseVideoPrice = json['base_video_price'];
    baseTextPrice = json['base_text_price'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['visit_type'] = this.visitType;
    data['visit_method'] = this.visitMethod;
    data['visit_duration_plan'] = this.visitDurationPlan;
    data['available_days'] = this.availableDays;
    data['base_video_price'] = this.baseVideoPrice;
    data['base_text_price'] = this.baseTextPrice;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    return data;
  }
}