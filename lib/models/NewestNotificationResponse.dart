import 'package:Neuronio/models/VisitResponseEntity.dart';
import 'package:Neuronio/utils/Utils.dart';

import 'UserEntity.dart';

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

class NewestNotificationResponse {
  List<NewestNotif> newestNotifs;

  int get newestNotifsNotReadCounts {
    int count = 0;
    newestNotifs?.forEach((n) {
      if (!(n.isRead ?? false)) {
        count++;
      }
    });
    return count;
  }

  int get newestNotifsTotalCounts {
    return newestNotifs?.length ?? 0;
  }

  void updateNotifIsRead(int notifId) {
    for (int i = 0; i < newestNotifs.length; i++) {
      NewestNotif notif = newestNotifs[i];
      if (notif.notifId == notifId) {
        notif.isRead = true;
        break;
      }
    }
    reorderNotifications();
  }

  void reorderNotifications() {
    List<NewestNotif> seen = [];
    List<NewestNotif> notSeen = [];
    for (int i = 0; i < newestNotifs.length; i++) {
      NewestNotif notif = newestNotifs[i];
      if (notif.isRead) {
        seen.add(notif);
      } else {
        notSeen.add(notif);
      }
    }
    newestNotifs = notSeen + seen;
  }

  NewestNotificationResponse getCopy() {
    return NewestNotificationResponse(newestNotifs: newestNotifs);
  }

  NewestNotificationResponse({this.newestNotifs}) {
    if (this.newestNotifs == null) {
      this.newestNotifs = [];
    }
  }

  NewestNotificationResponse.fromJson(Map<String, dynamic> json) {
    newestNotifs = [];
    if (json['results'] != null) {
      newestNotifs = new List<NewestNotif>();
      json['results'].forEach((v) {
        /// super
        int type = intPossible(v['type']);
        int notifId = v['id'];
        String title = v['title'];
        String description = v['body'];
        String notifDate = v['time'].split("T")[0];
        String notifTime = v['time'].split("T")[1].split("+")[0];
        bool isRead = v['is_read'];
        Map<String, dynamic> jsonData = {};
        if (v['data']['payload'] is Map<String, dynamic>) {
          jsonData = v['data']['payload'];
        }
        newestNotifs.add(NewestNotif.getChildFromJsonAndData(notifId, title,
            description, notifTime, notifDate, jsonData, type, isRead));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['newest_visits_counts'] = this.newestNotifsNotReadCounts;
    if (this.newestNotifs != null) {
      data['newest_visits'] = this.newestNotifs.map((v) => v.toJson()).toList();
    }
    return data;
  }

// static Future<NewestNotificationResponse> removeSeenNotifications(
//     NewestNotificationResponse notifs) async {
//   /// TODO for other kind of notifications later
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String> seenNotif =
//       prefs.getStringList("seenNotificationIds") ?? <String>[];
//   List<NewestVisitNotif> filteredNotifs = [];
//   notifs.newestNotifs.forEach((element) {
//     if (!seenNotif.contains(element.notifId)) {
//       filteredNotifs.add(element);
//     }
//   });
//   notifs.newestNotifs = filteredNotifs;
//   return notifs;
// }

// static void addNotifToSeen(NewestVisitNotif visit) async {}
}

abstract class NewestNotif {
  int notifId;
  String title;
  String description;
  String notifTime;
  String notifDate;
  int notifType;
  bool isRead;

  NewestNotif(
      {this.notifId,
      this.title,
      this.description,
      this.notifTime,
      this.notifDate,
      this.notifType,
      this.isRead});

  static NewestNotif getChildFromJsonAndData(
      int notifId,
      String title,
      String description,
      String time,
      String date,
      Map<String, dynamic> payload,
      int type,
      bool isRead) {
    if (type == 1) {
      /// voice or video call
      return NewestVideoVoiceCallNotif.fromJson(
          notifId, title, description, time, date, type, isRead, payload);
    } else if ([2, 3].contains(type)) {
      /// test send and response
      return NewestMedicalTestNotif.fromJson(
          notifId, title, description, time, date, type, isRead, payload);
    } else if ([5, 6].contains(type)) {
      /// visit
      return NewestVisitNotif.fromJson(
          notifId, title, description, time, date, type, isRead, payload);
    } else if (type == 7) {
      /// visit request reminder
      return NewestVisitNotif.fromJson(
          notifId, title, description, time, date, type, isRead, payload);
    } else if (type == 8) {
      /// visit reminder
      return NewestVisitNotif.fromJson(
          notifId, title, description, time, date, type, isRead, payload);
    } else if (type == 9) {
      return NewestPatientRegister.fromJson(
          notifId, title, description, time, date, type, isRead, payload);
    } else if (type == 10) {
      return NewestChatMessage.fromJson(
          notifId, title, description, time, date, type, isRead, payload);
    }
  }

  toJson();
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

class NewestEventsNotif extends NewestNotif {
  int eventId;
  Owner owner;
  List<InvitedDoctors> invitedDoctors;
  String time;
  String endTime;

  NewestEventsNotif(int notifId, String title, String description,
      String notifTime, String notifDate, int notifType,
      {this.eventId, this.owner, this.invitedDoctors, this.time, this.endTime})
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType);

  NewestEventsNotif.fromJson(
      int notifId,
      String title,
      String description,
      String notifTime,
      String notifDate,
      int notifType,
      Map<String, dynamic> json)
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType) {
    eventId = json['id'];
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
    notifTime = json['time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.eventId;
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
    data['time'] = this.notifTime;
    data['end_time'] = this.endTime;
    return data;
  }
}

class NewestVisitNotif extends NewestNotif {
  /// visit reminder/ visit accepted/ visit rejected/ visit pending
  int visitId;
  String createdDate;
  String modifiedDate;
  bool enabled;
  String doctorMessage;
  int visitType;
  int visitMethod;
  int visitDurationPlan;
  String patientMessage;
  String requestVisitTime;
  int status;

  int doctorId;
  int patientId;
  int panelId;

  VisitEntity getVisitEntity() {
    return VisitEntity(
        id: visitId,
        visitType: visitType,
        visitMethod: visitMethod,
        visitDurationPlan: visitDurationPlan,
        doctor: doctorId,
        patient: patientId,
        panel: panelId,
        status: status,
        visitTime: requestVisitTime);
  }

  NewestVisitNotif(int notifId, String title, String description,
      String notifTime, String notifDate, int notifType,
      {this.visitId,
      this.createdDate,
      this.modifiedDate,
      this.enabled,
      this.doctorMessage,
      this.visitType,
      this.visitMethod,
      this.visitDurationPlan,
      this.patientMessage,
      this.requestVisitTime,
      this.status,
      this.doctorId,
      this.patientId,
      this.panelId})
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType);

  NewestVisitNotif.fromJson(
      int notifId,
      String title,
      String description,
      String notifTime,
      String notifDate,
      int notifType,
      bool isRead,
      Map<String, dynamic> json)
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType,
            isRead: isRead) {
    visitId = json['id'];
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
    enabled = json['enabled'];
    doctorMessage = json['doctor_message'] ?? "";
    title = json['title'] ?? "";
    visitType = json['visit_type'];
    visitMethod = json['visit_method'];
    visitDurationPlan = json['visit_duration_plan'];
    patientMessage = json['patient_message'] ?? "";
    requestVisitTime = json['request_visit_time'];
    status = json['status'];
    doctorId = json['doctor'];
    patientId = json['patient'];
    panelId = json['panel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.visitId;
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
    data['doctor'] = this.doctorId;
    data['patient'] = this.patientId;
    data['panel'] = this.panelId;
    return data;
  }
}

class NewestMedicalTestNotif extends NewestNotif {
  int panelCognitiveTestId;
  int testId;
  String testTitle;
  String testDescription;
  int doctorId;
  int patientId;
  int panelId;

  NewestMedicalTestNotif(int notifId, String title, String description,
      String notifTime, String notifDate, int notifType,
      {this.testId,
      this.testTitle,
      this.testDescription,
      this.doctorId,
      this.patientId,
      this.panelId})
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType);

  NewestMedicalTestNotif.fromJson(
      int notifId,
      String title,
      String description,
      String notifTime,
      String notifDate,
      int notifType,
      bool isRead,
      Map<String, dynamic> json)
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType,
            isRead: isRead) {
    panelCognitiveTestId = intPossible(json['panel_cognitive_test_id']);
    testTitle = utf8IfPossible(json['title']) ?? "";
    doctorId = intPossible(json['doctor_id']);
    patientId = intPossible(json['patient_id']);
    testId = intPossible(json['test_id']);
    panelId = intPossible(json['panel_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = testTitle;
    data['panel_cognitive_test_id'] = panelCognitiveTestId;
    data['test_id'] = testId;
    data['doctor_id'] = doctorId;
    data['patient_id'] = patientId;
    data['panel_id'] = panelId;
    return data;
  }
}

class NewestVideoVoiceCallNotif extends NewestNotif {
  User user;
  String channelName;
  VisitEntity visit;

  NewestVideoVoiceCallNotif(int notifId, String title, String description,
      String notifTime, String notifDate, int notifType,
      {this.user, this.channelName, this.visit})
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType);

  NewestVideoVoiceCallNotif.fromJson(
      int notifId,
      String title,
      String description,
      String notifTime,
      String notifDate,
      int notifType,
      bool isRead,
      Map<String, dynamic> json)
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType,
            isRead: isRead) {
    if (json['partner_info'] != null) {
      user = User.fromJson(json['partner_info']);
    }
    channelName = json['channel_name'];
    if (json.containsKey('visit')) visit = VisitEntity.fromJson(json['visit']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['partner_info'] = user.toJson();
    data['channel_name'] = channelName;
    data['visit'] = visit.toJson();
    return data;
  }
}

class NewestPatientRegister extends NewestNotif {
  User patient;

  NewestPatientRegister(int notifId, String title, String description,
      String notifTime, String notifDate, int notifType, {this.patient})
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType);

  NewestPatientRegister.fromJson(
      int notifId,
      String title,
      String description,
      String notifTime,
      String notifDate,
      int notifType,
      bool isRead,
      Map<String, dynamic> json)
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType,
            isRead: isRead) {
    if (json['patient_info'] != null) {
      patient = User.fromJson(json['patient_info']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['patient_info'] = patient?.toJson();
    return data;
  }
}

class NewestChatMessage extends NewestNotif {
  String file;
  bool isMe;
  int type;
  String message;
  int panelId;
  int messageId;

  NewestChatMessage(int notifId, String title, String description,
      String notifTime, String notifDate, int notifType)
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType);

  NewestChatMessage.fromJson(
      int notifId,
      String title,
      String description,
      String notifTime,
      String notifDate,
      int notifType,
      bool isRead,
      Map<String, dynamic> json)
      : super(
            notifId: notifId,
            title: title,
            description: description,
            notifTime: notifTime,
            notifDate: notifDate,
            notifType: notifType,
            isRead: isRead) {
    file = json['file'];
    isMe = [true, false].contains(json['isMe']) ? json['isMe'] : false;
    type = intPossible(json['type']);
    message = json['message'];
    panelId = intPossible(json['panel_id']);
    messageId = intPossible(json['message_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}
