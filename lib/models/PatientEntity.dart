import 'Panel.dart';
import 'UserEntity.dart';

class PatientEntity extends UserEntity {
  int id;
  User user;
  PanelSection documents;
  List<Panel> panels;

  PatientEntity({this.id, this.user, this.documents, this.panels});

  PatientEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json.containsKey('documents'))
      documents = json['documents'] != null
          ? PanelSection.fromJson(json['documents'])
          : null;
    if (!json.containsKey('panels')) return;
    panels = [];
    if (json['panels'].length != 0)
      json['panels'].forEach((panel) {
        panels.add(Panel.fromJson(panel));
      });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    return data;
  }
}

class User {
  String username;
  String avatar;
  String firstName;
  String lastName;
  String name;
  String email;
  String nationalId;
  String phoneNumber;
  String credit;
  int type;
  String password;
  int online;

  User(
      {this.username,
      this.avatar,
      this.firstName,
      this.lastName,
      this.email,
      this.nationalId,
      this.phoneNumber,
      this.credit,
      this.type,
      this.password});

  User.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    avatar = json['avatar'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = '$firstName $lastName';
    email = json['email'];
    if (json.containsKey('national_id')) nationalId = json['national_id'];
    if (json.containsKey('phone_number')) phoneNumber = json['phone_number'];
    if (json.containsKey('credit')) credit = json['credit'];
    type = json['type'];
    if (json.containsKey('password')) password = json['password'];
    if (json.containsKey('online')) online = json['online'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['avatar'] = this.avatar;
    data['first_name'] = this.firstName;
    if (this.lastName != lastName) {
      data['last_name'] = this.lastName;
    }
    if (this.email != null) {
      data['email'] = this.email;
    }
    data['national_id'] = this.nationalId;
    data['phone_number'] = this.phoneNumber;
    data['credit'] = this.credit;
    data['type'] = this.type;
    data['password'] = this.password;
    return data;
  }
}
