import 'package:Neuronio/utils/Utils.dart';

import 'MedicalTest.dart';
class PatientScreening{

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
