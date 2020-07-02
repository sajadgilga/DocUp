import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';

class SearchResult {
  int count;
  dynamic next;
  dynamic previous;
  List<DoctorEntity> doctor_results;
  List<PatientEntity> patient_results;
  List<VisitEntity> visit_results;
  bool isDoctor;

  SearchResult.fromJson(Map<String, dynamic> json, isDoctor,
      {isVisit = false}) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    this.isDoctor = isDoctor;
    if (isVisit) {
      visit_results = (json['results'] as List)
          .map((result) => VisitEntity.fromJson(result))
          .toList();
    } else {
      if (isDoctor) {
        doctor_results = (json['results'] as List)
            .map((result) => DoctorEntity.fromJson(result))
            .toList();
      } else {
        patient_results = (json['results'] as List)
            .map((result) => PatientEntity.fromJson(result))
            .toList();
      }
    }
  }
}
