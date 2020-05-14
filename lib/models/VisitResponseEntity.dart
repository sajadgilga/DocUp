class VisitEntity {
  int id;
  String createdDate;
  String modifiedDate;
  bool enabled;
  String doctorMessage;
  String title;
  String patientMessage;
  int status;
  int doctor;
  int patient;
  int panel;
  int visitType;
  int visitMethod;
  int visitDurationPlan;
  String visitTime;

  VisitEntity({this.id,
    this.createdDate,
    this.modifiedDate,
    this.enabled,
    this.doctorMessage,
    this.title,
    this.patientMessage,
    this.status,
    this.doctor,
    this.patient,
    this.panel,
    this.visitType,
    this.visitMethod,
    this.visitDurationPlan,
    this.visitTime});

  VisitEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
    enabled = json['enabled'];
    doctorMessage = json['doctor_message'];
    title = json['title'];
    patientMessage = json['patient_message'];
    status = json['status'];
    doctor = json['doctor'];
    patient = json['patient'];
    panel = json['panel'];
    visitType = json['visit_type'];
    visitMethod = json['visit_method'];
    visitDurationPlan = json['visit_duration_plan'];
    visitTime = json['request_visit_time'];
  }


  Map<String, dynamic> toJson({bool isAcceptance = false}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (isAcceptance) {
      data['doctor_message'] = this.doctorMessage;
      data['status'] = this.status;
      return data;
    }
    data['id'] = this.id;
    data['created_date'] = this.createdDate;
    data['modified_date'] = this.modifiedDate;
    data['enabled'] = this.enabled;
    data['doctor_message'] = this.doctorMessage;
    data['title'] = this.title;
    data['patient_message'] = this.patientMessage;
    data['status'] = this.status;
    data['doctor'] = this.doctor;
    data['patient'] = this.patient;
    data['panel'] = this.panel;
    data['visit_type'] = this.visitType;
    data['visit_method'] = this.visitMethod;
    data['visit_duration_plan'] = this.visitDurationPlan;
    data['request_visit_time'] = this.visitTime;
    return data;
  }
}