class Notification {
  int id;
  String title;
  String description;
  String time;
  User owner;
  List<Guest> invited_patients;
  List<Guest> invited_doctors;

  Notification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    time = json['time'];
    owner = User.fromJson(json['owner']);
    invited_doctors = [];
        json['invited_doctors'].forEach((doctor) => invited_doctors.add(Guest.fromJson(doctor)));
    invited_patients = [];
        json['invited_patients'].forEach((patient) => invited_patients.add(Guest.fromJson(patient)));
  }
}

class User {
  String firstName;
  String lastName;

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
  }
}

class Guest {
  int id;
  User user;

  Guest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = User.fromJson(json['user']);
  }
}
