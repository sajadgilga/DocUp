import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/dateTimeService.dart';

import 'DoctorPlan.dart';
import 'Panel.dart';
import 'UserEntity.dart';
import 'VisitResponseEntity.dart';

class PatientEntity extends UserEntity {
  PanelSection documents;
  int status;
  double height;
  double weight;
  String birthLocation;
  String city;
  int genderNumber;
  String birthDate;
  List<VisitItem> visits;

  PatientEntity(
      {this.documents,
      this.height,
      this.weight,
      this.birthLocation,
      this.city,
      this.genderNumber,
      this.birthDate,
      user,
      id,
      panels,
      vid})
      : super(user: user, id: id, panels: panels, vid: vid);

  PatientEntity.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      if (json.containsKey('user')) {
        if (json['user'].containsKey('user'))
          user = json['user']['user'] != null
              ? User.fromJson(json['user']['user'])
              : null;
        else
          user = json['user'] != null ? User.fromJson(json['user']) : null;
      }
      if (json.containsKey('status')) status = json['status'];
      if (json.containsKey('documents'))
        documents = json['documents'] != null
            ? PanelSection.fromJson(json['documents'])
            : null;
      if (json.containsKey('panels')) {
        panels = [];
        if (json['panels'].length != 0) {
          json['panels'].forEach((panel) {
            if (panel == null) return;
            panels.add(Panel.fromJson(panel));
            panelMap[panels.last.id] = panels.last;
          });
        }
      }

      if (json.containsKey('height') && json['height'] != null) {
        height = double.parse(json['height'].toString());
      }
      if (json.containsKey('weight') && json['weight'] != null) {
        weight = double.parse(json['weight'].toString());
      }
      if (json.containsKey('city')) {
        city = utf8IfPossible(json['city']);
      }
      if (json.containsKey('birth_location')) {
        birthLocation = utf8IfPossible(json['birth_location']);
      }
      if (json.containsKey('gender')) {
        genderNumber = intPossible(json['gender']);
      }
      if (json.containsKey('visits')) {
        visits = [];
        (json['visits'] as List<dynamic>).forEach((element) {
          visits.add(VisitItem.fromJson(element));
        });
      }
      birthDate = json['date_of_birth'];
    } catch (e) {
      /// TODO
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (id != null) data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    if (height != null) {
      data['height'] = height;
    }
    if (weight != null) {
      data['weight'] = weight;
    }
    if (city != null) {
      data['city'] = city;
    }
    if (birthLocation != null) {
      data['birth_location'] = birthLocation;
    }
    if (genderNumber != null) {
      data['gender'] = genderNumber;
    }
    if (birthDate != null) {
      data['date_of_birth'] = birthDate;
    }

    return data;
  }

  int get vid {
    return super.vid ?? nearestPendingPatientVisit?.id;
  }

  VisitItem get nearestPendingPatientVisit {
    try {
      DateTime now = DateTimeService.getCurrentDateTime();
      for (int i = 0; i < visits?.length; i++) {
        VisitItem visitItem = visits[i];
        DateTime date = DateTimeService.getDateTimeFromStandardString(
            visitItem.requestVisitTime.split("+")[0]);
        if (date.compareTo(now) > 0 && visitItem.status == 0) {
          return visitItem;
        }
      }
    } catch (e) {}

    return null;
  }

  VisitItem get currentAcceptedVisit {
    try {
      DateTime now = DateTimeService.getCurrentDateTime();
      for (int i = 0; i < visits?.length; i++) {
        VisitItem visitItem = visits[i];
        DateTime date = DateTimeService.getDateTimeFromStandardString(
            visitItem.requestVisitTime.split("+")[0]);

        /// TODO amir: add duration plan in visits for better accuracy
        date = date.add(Duration(minutes: DoctorPlan.hourMinutePart * 3));
        if (date.compareTo(now) > 0 && visitItem.status == 1) {
          return visitItem;
        }
      }
    } catch (e) {}

    return null;
  }
}
