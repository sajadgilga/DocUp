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
  RoleType type;

  Entity({this.type, this.mEntity, this.partnerEntity});

  int get id {
    if (type == RoleType.DOCTOR)
      return (partnerEntity as DoctorEntity).id;
    else
      return (partnerEntity as PatientEntity).id;
  }

  int get pId {
    if (type == RoleType.PATIENT)
      return (partnerEntity as DoctorEntity).id;
    else
      return (partnerEntity as PatientEntity).id;
  }
}
