import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/utils/Utils.dart';

import 'MedicalTest.dart';

class PatientScreening {
  int id;
  bool paymentStatus;
  Map<int, MedicalTestItem> testsResponseStatus;
  bool icaStatus;
  bool visitStatus;
  DoctorEntity doctor;
  DoctorEntity clinicDoctor;
  ClinicEntity clinic;

  List<MedicalTestItem> get medicalTestItems {
    return testsResponseStatus.values.toList();
  }

  int get remainingTestsToBeDone {
    int doneCounts = 0;
    (testsResponseStatus ?? {}).forEach((key, value) {
      if (value.done) {
        doneCounts += 1;
      }
    });
    return (testsResponseStatus?.length ?? 0) - doneCounts;
  }

  PatientScreening.fromJson(Map<String, dynamic> json) {
    id = intPossible(json['screening_step_id'] ?? -1);
    paymentStatus = json['payment_status'] ?? false;
    testsResponseStatus = {};
    if (json.containsKey("tests_response_status")) {
      (json['tests_response_status'] as Map<String, dynamic>)
          .forEach((key, value) {
        int testId = intPossible(key);
        bool done = value['status'] ?? false;
        MedicalTestItem test = MedicalTestItem.fromJson(value['info']);
        test.done = done;
        testsResponseStatus[testId] = test;
      });
    }
    icaStatus = json['ica_status'] ?? false;
    visitStatus = json['visit_status'] ?? false;
    if (json['doctor_info'] != null) {
      doctor = DoctorEntity.fromJson(json['doctor_info']);
    }
    if (json['clinic_doctor_info'] != null) {
      clinicDoctor = DoctorEntity.fromJson(json['clinic_doctor_info']);
    }
    if (json['clinic_info'] != null) {
      clinic = ClinicEntity.fromJson(json['clinic_info']);
    }
  }
}

class PatientScreeningResponse {
  bool success;
  int inactive;
  int active;
  PatientScreening statusSteps;

  PatientScreeningResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    inactive = intPossible(json['inactive']);
    active = intPossible(json['active']);
    if (json.containsKey('status_steps')) {
      statusSteps = PatientScreening.fromJson(json['status_steps']);
    }
  }
}

class Screening {
  int id;
  int clinicId;
  int price;
  List<MedicalTestItem> medicalTests;

  Screening.fromJson(Map<String, dynamic> json) {
    id = intPossible(json['id']);
    clinicId = intPossible(json['clinic']);
    price = intPossible(json['price']);
    medicalTests = [];
    if (json.containsKey("medical_tests")) {
      (json['medical_tests'] as List).forEach((element) {
        medicalTests.add(MedicalTestItem.fromJson(element));
      });
    }
  }
}

class ScreeningDiscountDetailResponse {
  bool success;
  double percent;

  ScreeningDiscountDetailResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    percent = doublePossible(json['percent'] ?? 1);
  }
}

class ActivateScreeningPlanResponse {
  bool success;
  String msg;
  int code;

  ActivateScreeningPlanResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    msg = utf8IfPossible(json['msg'] ?? "");
    code = intPossible(json['code']);
  }
}

/// model
class ICATestScores {
  int icaIndex;
  int accuracy;
  int accuracyMaintenance;
  int speed;
  int speedMaintenance;
  int attention;

  List<String> get featuresTitle {
    return [
      "   امتیاز ICA",
      "دقت",
      "تداوم " + "\n" + "دقت",
      "سرعت",
      "تداوم سرعت",
      "توجه"
    ];
  }

  static List<int> healthyPatientFeaturesValue() {
    return [84, 98, 98, 98, 98, 98];
  }

  List<int> get featuresValues {
    return [
      icaIndex,
      accuracy,
      accuracyMaintenance,
      speed,
      speedMaintenance,
      attention
    ];
  }

  ICATestScores(
      {this.icaIndex,
      this.accuracy,
      this.accuracyMaintenance,
      this.speed,
      this.speedMaintenance,
      this.attention});

  ICATestScores.fromJson(Map<String, dynamic> json) {
    icaIndex = intPossible(json['ica_index']);
    accuracy = intPossible(json['accuracy']);
    accuracyMaintenance = intPossible(json['accuracy_maintenance']);
    speed = intPossible(json['speed']);
    speedMaintenance = intPossible(json['speed_maintenance']);
    attention = intPossible(json['attention']);
  }

  toJson() {
    Map<String, dynamic> data = {};
    data['ica_index'] = icaIndex;
    data['accuracy'] = accuracy;
    data['accuracy_maintenance'] = accuracyMaintenance;
    data['speed'] = speed;
    data['speed_maintenance'] = speedMaintenance;
    data['attention'] = attention;
    return data;
  }
}
