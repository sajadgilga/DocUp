class Medicine {
  int id;
  String drugName;
  String usage;
  String consumingTime;
  String consumingDay;
  int patient;
  int doctor;
  int panel;

  Medicine(
      {this.drugName,
      this.patient,
      this.usage,
      this.consumingDay='',
      this.consumingTime=''});

  Medicine.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('id')) id = json['id'];
    if (json.containsKey('drug_name')) drugName = json['drug_name'];
    if (json.containsKey('consuming_time'))
      consumingTime = json['consuming_time'];
    if (json.containsKey('consuming_day')) consumingDay = json['consuming_day'];
    if (json.containsKey('patient')) patient = json['patient'];
    if (json.containsKey('doctor')) doctor = json['doctor'];
    if (json.containsKey('panel')) panel = json['panel'];
    if (json.containsKey('usage')) usage = json['usage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['drug_name'] = drugName;
    data['consuming_day'] = consumingDay;
    data['consuming_time'] = consumingTime;
    data['usage'] = usage;
    data['patient'] = patient;
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
