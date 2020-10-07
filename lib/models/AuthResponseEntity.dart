class SignUpResponseEntity {
  final bool success;

  SignUpResponseEntity({this.success});

  factory SignUpResponseEntity.fromJson(Map<String, dynamic> json) {
    return SignUpResponseEntity(
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    return data;
  }
}

class VerifyResponseEntity {
  final String token;
  final String fullName;

  VerifyResponseEntity({this.token, this.fullName});

  factory VerifyResponseEntity.fromJson(Map<String, dynamic> json) {
    return VerifyResponseEntity(
        token: json['token'], fullName: json['fullname']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    return data;
  }
}

class LoginResponseEntity {
  final bool success;
  final bool created;

  LoginResponseEntity({this.success, this.created});

  factory LoginResponseEntity.fromJson(Map<String, dynamic> json) {
    return LoginResponseEntity(
      success: json['success'],
      created: json['created'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['created'] = this.created;
    return data;
  }
}
