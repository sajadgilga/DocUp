import 'dart:ui';

import 'package:docup/constants/colors.dart';

class NewestNotificationResponse {
  int newestEventsCounts;
  List<NewestEvents> newestEvents;
  int newestVisitsCounts;
  List<NewestVisit> newestVisits;

  void addOrUpdateNewVisitPushNotification(NewestVisit visit) {
    int prevVisitNotificationIndex = -1;
    for (int i = 0; i < newestVisits.length; i++) {
      if (newestVisits[i].id == visit.id) {
        prevVisitNotificationIndex = i;
        break;
      }
    }
    if (prevVisitNotificationIndex == -1) {
      newestVisits.insert(0, visit);
      newestVisitsCounts += 1;
    } else {
      newestVisits.removeAt(prevVisitNotificationIndex);
      newestVisits.insert(0, visit);
    }
  }

  NewestNotificationResponse(
      {this.newestEventsCounts = 0,
      this.newestEvents,
      this.newestVisitsCounts = 0,
      this.newestVisits}) {
    if (this.newestEvents == null) {
      this.newestEvents = [];
    }
    if (this.newestVisits == null) {
      this.newestVisits = [];
    }
  }

  NewestNotificationResponse.fromJson(Map<String, dynamic> json) {
    newestEventsCounts = json['newest_events_counts'] ?? 0;
    if (json['newest_events'] != null) {
      newestEvents = new List<NewestEvents>();
      json['newest_events'].forEach((v) {
        newestEvents.add(new NewestEvents.fromJson(v));
      });
    }
    newestVisitsCounts = json['newest_visits_counts'] ?? 0;
    if (json['newest_visits'] != null) {
      newestVisits = new List<NewestVisit>();
      json['newest_visits'].forEach((v) {
        newestVisits.add(new NewestVisit.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['newest_events_counts'] = this.newestEventsCounts;
    if (this.newestEvents != null) {
      data['newest_events'] = this.newestEvents.map((v) => v.toJson()).toList();
    }
    data['newest_visits_counts'] = this.newestVisitsCounts;
    if (this.newestVisits != null) {
      data['newest_visits'] = this.newestVisits.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NewestEvents {
  int id;
  Owner owner;
  List<InvitedDoctors> invitedDoctors;
  String title;
  String description;
  String time;
  String endTime;

  NewestEvents(
      {this.id,
      this.owner,
      this.invitedDoctors,
      this.title,
      this.description,
      this.time,
      this.endTime});

  NewestEvents.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
//    if (json['invited_patients'] != null) {
//      invitedPatients = new List<Null>();
//      json['invited_patients'].forEach((v) {
//        invitedPatients.add(new Null.fromJson(v));
//      });
//    }
    if (json['invited_doctors'] != null) {
      invitedDoctors = new List<InvitedDoctors>();
      json['invited_doctors'].forEach((v) {
        invitedDoctors.add(new InvitedDoctors.fromJson(v));
      });
    }
    title = json['title'];
    description = json['description'];
    time = json['time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.owner != null) {
      data['owner'] = this.owner.toJson();
    }
//    if (this.invitedPatients != null) {
//      data['invited_patients'] =
//          this.invitedPatients.map((v) => v.toJson()).toList();
//    }
    if (this.invitedDoctors != null) {
      data['invited_doctors'] =
          this.invitedDoctors.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['description'] = this.description;
    data['time'] = this.time;
    data['end_time'] = this.endTime;
    return data;
  }
}

class Owner {
  String firstName;
  String lastName;

  Owner({this.firstName, this.lastName});

  Owner.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    return data;
  }
}

class InvitedDoctors {
  int id;
  Owner user;
  int rate;

  InvitedDoctors({this.id, this.user, this.rate});

  InvitedDoctors.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new Owner.fromJson(json['user']) : null;
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['rate'] = this.rate;
    return data;
  }
}

class NewestVisit {
  int id;
  String createdDate;
  String modifiedDate;
  bool enabled;
  Null doctorMessage;
  String title;
  int visitType;
  int visitMethod;
  int visitDurationPlan;
  String patientMessage;
  String requestVisitTime;
  int status;
  int doctor;
  int patient;
  int panel;

  NewestVisit(
      {this.id,
      this.createdDate,
      this.modifiedDate,
      this.enabled,
      this.doctorMessage,
      this.title,
      this.visitType,
      this.visitMethod,
      this.visitDurationPlan,
      this.patientMessage,
      this.requestVisitTime,
      this.status,
      this.doctor,
      this.patient,
      this.panel});

  NewestVisit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
    enabled = json['enabled'];
    doctorMessage = json['doctor_message'];
    title = json['title'];
    visitType = json['visit_type'];
    visitMethod = json['visit_method'];
    visitDurationPlan = json['visit_duration_plan'];
    patientMessage = json['patient_message'];
    requestVisitTime = json['request_visit_time'];
    status = json['status'];
    doctor = json['doctor'];
    patient = json['patient'];
    panel = json['panel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_date'] = this.createdDate;
    data['modified_date'] = this.modifiedDate;
    data['enabled'] = this.enabled;
    data['doctor_message'] = this.doctorMessage;
    data['title'] = this.title;
    data['visit_type'] = this.visitType;
    data['visit_method'] = this.visitMethod;
    data['visit_duration_plan'] = this.visitDurationPlan;
    data['patient_message'] = this.patientMessage;
    data['request_visit_time'] = this.requestVisitTime;
    data['status'] = this.status;
    data['doctor'] = this.doctor;
    data['patient'] = this.patient;
    data['panel'] = this.panel;
    return data;
  }

  String getNotificationTitle() {
    String title = "عنوان";
    if (status == 0) {
      title = "در انتظار تایید ویزیت";
    } else if (status == 1) {
      title = "تایید درخواست ویزیت";
    } else if (status == 2) {
      title = "رد درخواست ویزیت";
    }
    if (this.title != null) {
      title = this.title + ": " + title;
    }
    return title;
  }

  String getNotificationDescription() {
    return (visitType == 0 ? "ویزیت حضوری" : "ویزیت مجازی");
  }

  String getNotificationTime() {
    return requestVisitTime;
  }

  Color getNotificationColor() {
    return status == 0
        ? IColors.darkGrey
        : (status == 1 ? IColors.themeColor : IColors.red);
  }
}
