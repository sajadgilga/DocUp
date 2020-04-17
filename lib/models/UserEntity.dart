import 'package:docup/models/Panel.dart';
import 'package:docup/ui/start/RoleType.dart';

import 'DoctorEntity.dart';
import 'PatientEntity.dart';

abstract class UserEntity {
  User user;
  int id;
  List<Panel> panels;

  UserEntity({this.user, this.id, this.panels});
}

class Entity {
  UserEntity mEntity;
  UserEntity partnerEntity;
  int iPanelId;
  RoleType type;

  Entity({this.type, this.mEntity, this.partnerEntity});

  int get id {
    if (isDoctor)
      return (partnerEntity as DoctorEntity).id;
    else
      return (partnerEntity as PatientEntity).id;
  }

  int get pId {
    if (isPatient)
      return (partnerEntity as DoctorEntity).id;
    else
      return (partnerEntity as PatientEntity).id;
  }

  DoctorEntity get doctor {
    if (isPatient) return partnerEntity;
    if (isDoctor) return mEntity;
  }

  PatientEntity get patient {
    if (isPatient) return mEntity;
    if (isDoctor) return partnerEntity;
  }

  bool get isPatient {
    return (type == RoleType.PATIENT);
  }

  bool get isDoctor {
    return (type == RoleType.DOCTOR);
  }

  String get pClinicName {
    if (isPatient)
      return (partnerEntity as DoctorEntity).clinic.clinicName;
    if (isDoctor) return "";
  }

  String get pExpert {
    if (isPatient)
      return (partnerEntity as DoctorEntity).expert;
    if (isDoctor) return "";
  }
}
