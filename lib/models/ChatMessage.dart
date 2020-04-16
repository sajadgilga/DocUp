import 'package:docup/models/DoctorEntity.dart';

import 'PatientEntity.dart';

enum MessageState { unsent, sent, delivered, failed }

class ChatMessage {
  final String text;
  MessageState state;
  DateTime sentDate;
  DoctorEntity doctor;
  PatientEntity patient;
  bool fromPatient = true;

  ChatMessage.fromDoctor(
      {this.text,
      this.sentDate,
      this.doctor,
      this.patient,
      this.fromPatient = false});

  ChatMessage.fromPatient(
      {this.text, this.sentDate, this.doctor, this.patient});
}
