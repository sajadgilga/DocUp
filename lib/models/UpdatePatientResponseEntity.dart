class Patient {
  int id;
  User user;

  Patient({this.id, this.user});

  Patient.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
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
    if(this.lastName != lastName) {
      data['last_name'] = this.lastName;
    }
    if(this.email != null) {
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
