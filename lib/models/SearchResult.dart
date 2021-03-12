import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/models/VisitResponseEntity.dart';

enum EntityType { DoctorEntity, PatientEntity, VisitEntity, ClinicEntity }

class SearchResult {
  int count;
  dynamic next;
  dynamic previous;
  List<DoctorEntity> doctorResults;
  List<PatientEntity> patientResults;
  List<VisitEntity> visitResults;
  List<ClinicEntity> clinicResults;
  EntityType entityType;

  bool get isUserEntity {
    return entityType == EntityType.DoctorEntity ||
        entityType == EntityType.PatientEntity;
  }

  bool get isDoctor {
    return entityType == EntityType.DoctorEntity;
  }

  bool get isPatient {
    return entityType == EntityType.PatientEntity;
  }

  bool get isVisit {
    return entityType == EntityType.VisitEntity;
  }

  bool get isClinic {
    return entityType == EntityType.ClinicEntity;
  }

  SearchResult.fromJson(Map<String, dynamic> json, EntityType entityType) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    this.entityType = entityType;
    switch (entityType) {
      case EntityType.DoctorEntity:
        doctorResults = (json['results'] as List)
            .map((result) => DoctorEntity.fromJson(result))
            .toList();
        break;
      case EntityType.PatientEntity:
        patientResults = (json['results'] as List)
            .map((result) => PatientEntity.fromJson(result))
            .toList();
        break;
      case EntityType.VisitEntity:
        visitResults = (json['results'] as List)
            .map((result) => VisitEntity.fromJson(result))
            .toList();
        break;
      case EntityType.ClinicEntity:
        clinicResults = (json['results'] as List)
            .map((result) => ClinicEntity.fromJson(result))
            .toList();
        break;
    }
  }
}
