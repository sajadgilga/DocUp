import 'package:Neuronio/utils/dateTimeService.dart';

class Medicine {
  int id;
  String drugName;
  String usage;
  String consumingTime;
  String consumingDay;
  int numbers;
  int usagePeriod = 1;
  int patient;
  int doctor;
  int panel;

  Medicine(
      {this.drugName,
      this.patient,
      this.usage,
      this.numbers = 1,
      this.usagePeriod,
      this.consumingDay = '',
      this.consumingTime = ''});

  Medicine.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('id')) id = json['id'];
    if (json.containsKey('drug_name')) drugName = json['drug_name'];
    if (json.containsKey('consuming_time'))
      consumingTime = json['consuming_time'];
    if (json.containsKey('consuming_day')) consumingDay = json['consuming_day'];
    if (json.containsKey('numbers')) numbers = json['numbers'];
    if (json.containsKey('usage_period')) usagePeriod = json['usage_period'];
    if (json.containsKey('patient')) patient = json['patient'];
    if (json.containsKey('doctor')) doctor = json['doctor'];
    if (json.containsKey('panel')) panel = json['panel'];
    if (json.containsKey('usage')) usage = json['usage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['drug_name'] = drugName;
    var now = DateTimeService.getCurrentDateTime();
    if (consumingDay.isEmpty)
      data['consuming_day'] = '${now.year}-${now.month}-${now.day}';
    else
      data['consuming_day'] = consumingDay;
    if (consumingDay.isEmpty)
      data['consuming_time'] = '${now.hour}:${now.minute}:00';
    else
      data['consuming_time'] = consumingTime;
    data['usage'] = usage;
    data['numbers'] = numbers;
    data['usage_period'] = usagePeriod;
    data['patient'] = patient;
    return data;
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
