import 'package:docup/models/Panel.dart';
import 'package:docup/ui/start/RoleType.dart';

import 'DoctorEntity.dart';
import 'PatientEntity.dart';

abstract class UserEntity {
  User user;
  int id;
  int vid; //TODO: have to be removed later
  List<Panel> panels;
  Map<int, Panel> panelMap = {};

  UserEntity({this.user, this.id, this.panels, this.vid});
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
    if (partnerEntity == null)
      return null;
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

  String get avatar {
    if (isPatient) {
      return (mEntity as PatientEntity).user.avatar;
    } else if (isDoctor)
      return (mEntity as DoctorEntity).user.avatar;
  }

  String get pClinicName {
    if (isPatient)
//      return (partnerEntity as DoctorEntity).clinic.clinicName;
      return "";
    if (isDoctor) return "";
  }

  String get pExpert {
    if (isPatient)
      return (partnerEntity as DoctorEntity).expert;
    if (isDoctor) return "";
  }

  Panel get panel {
    return mEntity.panelMap[iPanelId];
  }

  int sectionId (String name){
    try {
       return mEntity.panelMap[iPanelId]
          .sections[name].id;
    }catch(_) {
      return -1;
    }
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
    if (json.containsKey('username')) username = json['username'];
    if (json.containsKey('avatar')) avatar = json['avatar'];
    if (json.containsKey('first_name'))
      firstName = json['first_name'];
    else
      firstName = '';
    if (json.containsKey('last_name'))
      lastName = json['last_name'];
    else
      lastName = '';
    name = '${firstName != null? firstName: ''} ${lastName != null? lastName: ''}';
    if (json.containsKey('email')) email = json['email'];
    if (json.containsKey('national_id')) nationalId = json['national_id'];
    if (json.containsKey('phone_number')) phoneNumber = json['phone_number'];
    if (json.containsKey('credit')) credit = json['credit'];
    if (json.containsKey('type')) type = json['type'];
    if (json.containsKey('password')) password = json['password'];
    if (json.containsKey('online')) online = json['online'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['avatar'] = this.avatar;
    data['first_name'] = this.firstName;
    if (this.lastName != lastName) {
      data['last_name'] = this.lastName;
    }
    if (this.email != null) {
      data['email'] = this.email;
    }
    data['national_id'] = this.nationalId;
    data['phone_number'] = this.phoneNumber;
    data['credit'] = this.credit;
    data['type'] = this.type;
    data['password'] = this.password;
    return data;
  }
}

