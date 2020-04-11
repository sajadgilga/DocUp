import 'dart:convert';

class DoctorEntity {
  int id;
  User user;
  String councilCode;
  String expert;
  Clinic clinic;
  int fee;

  DoctorEntity(
      {this.id,
        this.user,
        this.councilCode,
        this.expert,
        this.clinic,
        this.fee});

  DoctorEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    councilCode = json['council_code'];
    expert = json['expert'];
    clinic =
    json['clinic'] != null ? new Clinic.fromJson(json['clinic']) : null;
    fee = json['fee'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['council_code'] = this.councilCode;
    data['expert'] = this.expert;
    if (this.clinic != null) {
      data['clinic'] = this.clinic.toJson();
    }
    data['fee'] = this.fee;
    return data;
  }
}

class User {
  String avatar;
  String firstName;
  String lastName;
  String email;
  int credit;
  int type;
  int online;

  User(
      {this.avatar,
        this.firstName,
        this.lastName,
        this.email,
        this.credit,
        this.type,
        this.online});

  User.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    credit = json['credit'];
    type = json['type'];
    online = json['online'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['credit'] = this.credit;
    data['type'] = this.type;
    data['online'] = this.online;
    return data;
  }
}

class Clinic {
  int id;
  User user;
  int subType;
  String clinicName;
  String clinicAddress;
  String description;
  double longitude;
  double latitude;

  Clinic(
      {this.id,
        this.user,
        this.subType,
        this.clinicName,
        this.clinicAddress,
        this.description,
        this.longitude,
        this.latitude});

  Clinic.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    subType = json['sub_type'];
    clinicName = json['clinic_name'];
    clinicAddress = json['clinic_address'];
    description = json['description'];
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['sub_type'] = this.subType;
    data['clinic_name'] = this.clinicName;
    data['clinic_address'] = this.clinicAddress;
    data['description'] = this.description;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    return data;
  }
}