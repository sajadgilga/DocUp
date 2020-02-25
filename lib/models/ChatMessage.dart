import 'Doctor.dart';
import 'Patient.dart';

enum MessageState {
  unsent,
  sent,
  delivered,
  failed
}


class ChatMessage {
  final String text;
  MessageState state;
  final DateTime sentDate;
  DateTime receivedDate;
  Doctor doctor;
  Patient patient;
  bool fromPatient = true;

  ChatMessage(this.text, this.state, this.sentDate, this.receivedDate);
  ChatMessage.withState(this.text, this.state, this.sentDate);
}