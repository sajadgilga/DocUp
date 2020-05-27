import 'package:DocUp/models/DoctorEntity.dart';

import 'PatientEntity.dart';

enum MessageState { unsent, sent, delivered, failed }

class ChatMessage {
  int id;
  DateTime createdDate;
  String modifiedDate;
  bool enabled;
  String message;
  int direction;
  int type;
  String file; // TODO
  bool isRead;
  int panelId;

  String text;
  MessageState state;
  DateTime sentDate;
  bool fromMe = true;

  ChatMessage(
      {this.message,
      this.direction,
      this.type,
      this.file,
      this.fromMe,
      this.createdDate});

  ChatMessage.fromDoctor(
      {this.text,
      this.sentDate,
//      this.doctor,
//      this.patient,
      this.fromMe = false});

  ChatMessage.fromMe({this.text, this.sentDate});

  ChatMessage.fromJson(Map<String, dynamic> json, bool isPatient) {
    id = json['id'];
    createdDate = DateTime.parse(json['created_date']);
    createdDate = createdDate.add(Duration(hours: 4, minutes: 30));
    if (json.containsKey('modified_date')) modifiedDate = json['modified_date'];
    if (json.containsKey('enabled')) enabled = json['enabled'];
    direction = json['direction'];
    fromMe =
        (isPatient && (direction == 0)) || (!isPatient && (direction == 1));
    message = json['message'];
    type = json['type'];
    file = json['file'];
    isRead = json['is_read'];
    panelId = json['panel'];
  }

  ChatMessage.fromSocket(Map<String, dynamic> json, bool isPatient) {
    id = json['id'];
    if (json.containsKey('created_date'))
      createdDate = DateTime.parse(json['created_date']);
    else
      createdDate = DateTime.now();
    createdDate = createdDate.add(Duration(hours: 4, minutes: 30));
    if (json.containsKey('modified_date')) modifiedDate = json['modified_date'];
    if (json.containsKey('enabled')) enabled = json['enabled'];
    direction = json['direction'];
    fromMe =
        (isPatient && (direction == 0)) || (!isPatient && (direction == 1));
    message = json['message'];
    type = json['type'];
    if (json.containsKey('file')) file = json['file'];
    isRead = json['is_read'];
    panelId = json['panel_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['message'] = message;
    data['direction'] = direction;
    data['type'] = type;
    data['file'] = file;
    return data;
  }
}
