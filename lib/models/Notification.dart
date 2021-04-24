class Notification {
  int id;
  String title;
  String description;
  String time;
  User owner;
  List<Guest> invitedPatients;
  List<Guest> invitedDoctors;

  Notification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    time = json['time'];
    owner = User.fromJson(json['owner']);
    invitedDoctors = [];
    json['invited_doctors']
        .forEach((doctor) => invitedDoctors.add(Guest.fromJson(doctor)));
    invitedPatients = [];
    json['invited_patients']
        .forEach((patient) => invitedPatients.add(Guest.fromJson(patient)));
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
