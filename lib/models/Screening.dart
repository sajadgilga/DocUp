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
    if (json.containsKey('doctor_info')) {
      doctor = DoctorEntity.fromJson(json['doctor_info']);
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

class BuyScreeningPlanResponse {
  bool success;
  double percent;

  BuyScreeningPlanResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    percent = doublePossible(json['percent'] ?? 1);
  }
}
