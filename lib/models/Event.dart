
import 'Notification.dart';

class Event {
  int id;
  String title;
  String description;
  String time;
  User owner;
  List<Guest> invited_patients;
  List<Guest> invited_doctors;

  Event.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('id')) id = json['id'];
    if (json.containsKey('title')) title = json['title'];
    if (json.containsKey('description')) description = json['description'];
    if (json.containsKey('time')) time = json['time'];
    if (json.containsKey('owner')) owner = User.fromJson(json['owner']);
    invited_doctors = [];
    if (json.containsKey('invited_doctors'))
      json['invited_doctors']
          .forEach((doctor) => invited_doctors.add(Guest.fromJson(doctor)));
    invited_patients = [];
    if (json.containsKey('invited_patients'))
      json['invited_patients']
          .forEach((patient) => invited_patients.add(Guest.fromJson(patient)));
  }
}
