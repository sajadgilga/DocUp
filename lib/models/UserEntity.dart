import 'package:Neuronio/models/Panel.dart';
import 'package:Neuronio/ui/start/RoleType.dart';
import 'package:Neuronio/utils/Utils.dart';

import 'DoctorEntity.dart';
import 'PatientEntity.dart';

abstract class UserEntity {
  User user;
  int id;
  int vid; //TODO: have to be removed later
  List<Panel> panels;
  Map<int, Panel> panelMap = {};

  Panel getPanelByPatientId(int patientId) {
    for (var panel in panels) {
      if (panel.patientId == patientId) {
        return panel;
      }
    }
    return null;
  }

  Panel getPanelByDoctorId(int doctorId) {
    for (var panel in panels) {
      if (panel.doctorId == doctorId) {
        return panel;
      }
    }
    return null;
  }

  UserEntity({this.user, this.id, this.panels, this.vid});

  String get fullName {
    return (user?.firstName ?? "") + " " + (user?.lastName ?? "");
  }
}

class Entity {
  UserEntity mEntity;
  UserEntity partnerEntity;
  int iPanelId;
  RoleType type;

  Entity({this.type, this.mEntity, this.partnerEntity});

  Entity copy() {
    Entity entity = Entity();
    entity.mEntity = this.mEntity;
    entity.partnerEntity = this.partnerEntity;
    entity.iPanelId = this.iPanelId;
    entity.type = this.type;
    return entity;
  }

  int get id {
    if (isDoctor)
      return (partnerEntity as DoctorEntity).id;
    else
      return (partnerEntity as PatientEntity).id;
  }

  int get pId {
    if (partnerEntity == null) return null;
    if (isPatient)
      return (partnerEntity as DoctorEntity).id;
    else
      return (partnerEntity as PatientEntity).id;
  }

  DoctorEntity get doctor {
    if (isPatient) return partnerEntity;
    if (isDoctor) return mEntity;
    return null;
  }

  PatientEntity get patient {
    if (isPatient) return mEntity;
    if (isDoctor) return partnerEntity;
    return null;
  }

  bool get isPatient {
    return (type == RoleType.PATIENT);
  }

  bool get isDoctor {
    return (type == RoleType.DOCTOR);
  }

  String get avatar {
    if (isPatient) {
      return (mEntity as PatientEntity).user.avatar;
    } else if (isDoctor) return (mEntity as DoctorEntity).user.avatar;
    return null;
  }

  String get pClinicName {
    if (isPatient)
      return (partnerEntity as DoctorEntity)?.clinic?.clinicName ?? "";
    if (isDoctor) return "";
    return null;
  }

  String get pExpert {
    if (isPatient) return (partnerEntity as DoctorEntity).expert;
    if (isDoctor) return "";
    return null;
  }

  Panel get panel {
    return (mEntity?.panelMap[iPanelId] ?? panelByPartnerId);
  }

  Panel get panelByPartnerId {
    if (mEntity != null) {
      for (int i = 0; i < mEntity?.panels?.length; i++) {
        Panel element = mEntity.panels[i];
        if (isDoctor) {
          if (element.patientId == partnerEntity.id) {
            return element;
          }
        } else {
          if (element.doctorId == partnerEntity.id) {
            return element;
          }
        }
      }
    }

    return null;
  }

  Panel getPanelByPatientId(int patientId) {
    if (mEntity != null) {
      for (int i = 0; i < mEntity.panels.length; i++) {
        Panel element = mEntity.panels[i];
        if (element.patientId == patientId) {
          return element;
        }
      }
    }

    return null;
  }

  Panel getPanelByPanelId(int panelId) {
    if (mEntity != null) {
      for (int i = 0; i < mEntity.panels.length; i++) {
        Panel element = mEntity.panels[i];
        if (element.id == panelId) {
          return element;
        }
      }
    }
    return null;
  }

  int sectionId(String name) {
    try {
      return mEntity.panelMap[iPanelId].sections[name].id;
    } catch (_) {
      return -1;
    }
  }

  int sectionIdByNameAndPatientEntityId(String name, int patientId) {
    try {
      return getPanelByPatientId(patientId).sections[name].id;
    } catch (e) {}
    return -1;
  }

  bool isActivePanel(panelId) {
    return mEntity.panelMap[panelId].status > 1;
  }
}

class User {
  String username;
  String avatar;
  String firstName;
  String lastName;
  String name;
  String email;
  String nationalId;
  String phoneNumber;
  String credit;
  int type;
  String password;
  int online;

  String get fullName {
    return (firstName ?? "") + " " + (lastName ?? "");
  }

  User(
      {this.username,
      this.avatar,
      this.firstName,
      this.lastName,
      this.email,
      this.nationalId,
      this.phoneNumber,
      this.credit,
      this.type,
      this.password});

  User.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('username'))
      username = utf8IfPossible(json['username']);
    if (json.containsKey('avatar')) avatar = utf8IfPossible(json['avatar']);
    if (json.containsKey('first_name'))
      firstName = utf8IfPossible(json['first_name']);
    else
      firstName = '';
    if (json.containsKey('last_name'))
      lastName = utf8IfPossible(json['last_name']);
    else
      lastName = '';
    name =
        '${firstName != null ? firstName : ''} ${lastName != null ? lastName : ''}';
    if (json.containsKey('email')) email = utf8IfPossible(json['email'] ?? "");
    if (json.containsKey('national_id')) nationalId = json['national_id'] ?? "";
    if (json.containsKey('phone_number'))
      phoneNumber = json['phone_number'] ?? "";
    if (json.containsKey('credit')) credit = json['credit'];
    if (json.containsKey('type')) type = json['type'];
    if (json.containsKey('password')) password = json['password'] ?? "";
    if (json.containsKey('online')) online = json['online'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (username != null) data['username'] = this.username;
    if (avatar != null) data['avatar'] = this.avatar;
    if (firstName != null) data['first_name'] = this.firstName;
    if (lastName != null) data['last_name'] = this.lastName;
    if (email != null) data['email'] = this.email;
    if (nationalId != null) data['national_id'] = this.nationalId;
    if (phoneNumber != null) data['phone_number'] = this.phoneNumber;
    if (credit != null) data['credit'] = this.credit;
    if (type != null) data['type'] = this.type;
    if (password != null) data['password'] = this.password;
    return data;
  }
}
