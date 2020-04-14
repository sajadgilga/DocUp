import 'Panel.dart';

class Patient {
  int id;
  User user;
  PanelSection documents;
  List<Panel> panels;

  Patient({this.id, this.user, this.documents, this.panels});

  Patient.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json.containsKey('documents'))
      documents = json['documents'] != null
          ? PanelSection.fromJson(json['documents'])
          : null;
    if (!json.containsKey('panels')) return;
    if (json['panels'].length == 0)
      panels = [];
    else
      panels = json['panels'].map((Map panel) => Panel.fromJson(panel));
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
  String email;
  String nationalId;
  String phoneNumber;
  String credit;
  int type;
  String password;

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
    email = json['email'];
    nationalId = json['national_id'];
    phoneNumber = json['phone_number'];
    credit = json['credit'];
    type = json['type'];
    password = json['password'];
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
