class Medicine {
  int id;
  String drugName;
  String consumingTime;
  UserEntity patient;
  UserEntity doctor;

  Medicine.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    drugName = json['drug_name'];
    consumingTime = json['consuming_time'];
    patient = UserEntity.fromJson(json['patient']);
    doctor = UserEntity.fromJson(json['doctor']);
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

class UserEntity {
  int id;
  User user;

  UserEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = User.fromJson(json['user']);
  }
}
