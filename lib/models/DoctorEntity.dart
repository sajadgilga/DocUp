import 'package:Neuronio/models/DoctorPlan.dart';
import 'package:Neuronio/models/Panel.dart';
import 'package:Neuronio/utils/Utils.dart';

import 'UserEntity.dart';

class DoctorEntity extends UserEntity {
  String councilCode;
  String expert;
  ClinicEntity clinic;
  String clinicNumber;
  String clinicAddress;
  int fee;
  List<String> accountNumbers;

  DoctorPlan plan;

  DoctorEntity(
      {this.councilCode,
      this.expert,
      this.clinic,
      this.accountNumbers,
      this.fee,
      user,
      id,
      panels})
      : super(user: user, id: id, panels: panels);

  DoctorEntity.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      if (json.containsKey('user'))
        user = json['user'] != null ? new User.fromJson(json['user']) : null;
      if (json.containsKey('council_code')) councilCode = json['council_code'];
      if (json.containsKey('account_number')) {
        accountNumbers =
            json['account_number'] == null ? null : [json['account_number']];
      }
      if (json.containsKey('expert')) expert = utf8IfPossible(json['expert']);
      if (json.containsKey('clinic'))
        clinic =
            json['clinic'] != null ? new ClinicEntity.fromJson(json['clinic']) : null;
      fee = json['fee'];
      if (json.containsKey('clinic_address'))
        clinicAddress = json['clinic_address'];
      if (json.containsKey('clinic_number'))
        clinicNumber = json['clinic_number'];
      panels = [];

      if (json.containsKey('panels')) {
        if (json['panels'].length != 0) {
          json['panels'].forEach((panel) {
            if (panel != null) {
              panels.add(Panel.fromJson(panel));
              panelMap[panels.last.id] = panels.last;
            }
          });
        }
      }

      if (json['plan'] != null) {
        plan = DoctorPlan.fromJson(json['plan']);
      } else {
        plan = DoctorPlan();
      }
    } catch (_) {
      // TODO
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.id != null) {
      data['id'] = this.id;
    }
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    if (this.councilCode != null) {
      data['council_code'] = this.councilCode;
    }
    if (this.expert != null) {
      data['expert'] = this.expert;
    }

    if (this.accountNumbers != null) {
      data['account_number'] =
          this.accountNumbers.length == 0 ? null : this.accountNumbers.first;
    }
    if (this.clinic != null) {
      data['clinic'] = this.clinic.toJson();
    }
    if (this.fee != null) {
      data['fee'] = this.fee;
    }
    return data;
  }
}

class ClinicTrafficTextPlan {
  int id;
  String title;
  int wordNumber;
  int fileVolume;
  int medicalTestCount;
  int price;

  ClinicTrafficTextPlan(
      {this.id,
      this.title,
      this.wordNumber,
      this.fileVolume,
      this.medicalTestCount,
      this.price});

  ClinicTrafficTextPlan.fromJson(Map<String, dynamic> json) {
    id = intPossible(json['id']) ?? -1;
    title = utf8IfPossible(json['title']) ?? "";
    wordNumber = intPossible(json['word_counts']);
    fileVolume = intPossible(json['file_volume']);
    medicalTestCount = intPossible(json['medical_test_count']);
    price = intPossible(json['price']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    /// TODO
    return data;
  }
}

class ClinicEntity {
  int id;
  User user;
  int subType;
  String clinicName;
  String clinicAddress;
  String description;
  double longitude;
  double latitude;
  List<ClinicTrafficTextPlan> pClinic;

  ClinicEntity(
      {this.id,
      this.user,
      this.subType,
      this.clinicName,
      this.clinicAddress,
      this.description,
      this.longitude,
      this.latitude});

  ClinicEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    subType = json['sub_type'];
    clinicName = utf8IfPossible(json['clinic_name']);
    clinicAddress = utf8IfPossible(json['clinic_address']);
    description = utf8IfPossible(json['description']);
    longitude = json['longitude'];
    latitude = json['latitude'];
    pClinic = [];
    if (json.containsKey("pclinic")) {
      (json['pclinic'] as List).forEach((element) {
        pClinic.add(ClinicTrafficTextPlan.fromJson(element));
      });
    }
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

class NeuronioClinic extends ClinicEntity {
  static const ClinicId = 4;

  NeuronioClinic() {
    this.id = ClinicId;
  }
}
