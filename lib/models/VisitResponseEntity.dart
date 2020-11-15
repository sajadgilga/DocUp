import 'package:docup/models/DoctorEntity.dart';

import 'PatientEntity.dart';

class VisitItem {
  int id;
  int status;
  String requestVisitTime;

  VisitItem(this.id, this.status, this.requestVisitTime);

  VisitItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    requestVisitTime = json['request_visit_time'];
  }
}

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
  DoctorEntity doctorEntity;
  PatientEntity patientEntity;
  int panel;
  int visitType;
  int visitMethod;
  int visitDurationPlan;
  String visitTime;

  VisitEntity(
      {this.id,
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
    if (json.containsKey('id')) id = json['id'];
    if (json.containsKey('created_date')) createdDate = json['created_date'];
    if (json.containsKey('modified_date')) modifiedDate = json['modified_date'];
    if (json.containsKey('enabled')) enabled = json['enabled'];
    if (json.containsKey('doctor_message'))
      doctorMessage = json['doctor_message'];
    if (json.containsKey('title')) title = json['title'];
    if (json.containsKey('patient_message'))
      patientMessage = json['patient_message'];
    if (json.containsKey('status')) status = json['status'];

//    patient = json['patient'];

    if (json.containsKey('doctor')) {
      try {
        doctorEntity = DoctorEntity.fromJson(json['doctor']);
        doctor = doctorEntity.id;
      } catch (_) {
        doctor = json['doctor'];
      }
    }
    if (json.containsKey('patient')) {
      try {
        patientEntity = PatientEntity.fromJson(json['patient']);
        patient = patientEntity.id;
      } catch (_) {
        patient = json['patient'];
      }
    }

    if (json.containsKey('panel')) panel = json['panel'];
    if (json.containsKey('visit_type')) visitType = json['visit_type'];
    if (json.containsKey('visit_method')) visitMethod = json['visit_method'];
    if (json.containsKey('visit_duration_plan'))
      visitDurationPlan = json['visit_duration_plan'];
    if (json.containsKey('request_visit_time'))
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
