import 'package:docup/utils/Utils.dart';

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
  final String firstName;
  final String lastName;
  final String nationalCode;
  final String expertise;

  VerifyResponseEntity(
      {this.token,
      this.firstName,
      this.lastName,
      this.nationalCode,
      this.expertise});

  factory VerifyResponseEntity.fromJson(Map<String, dynamic> json) {
    /// TODO amir: first name and full name
    return VerifyResponseEntity(
        token: json['token'],
        firstName: utf8IfPossible(json['firstname']) ??
            utf8IfPossible(json['fullname']) ??
            "",
        lastName: utf8IfPossible(json['lastname']) ?? "",
        nationalCode: utf8IfPossible(json['nationalcode']) ?? "",
        expertise: utf8IfPossible(json['expertise']) ?? "");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['nationalCode'] = this.nationalCode;
    data['expertise'] = this.expertise;
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

class UploadAvatarResponseEntity {
  String avatar;

  UploadAvatarResponseEntity(this.avatar);

  UploadAvatarResponseEntity.fromJson(Map<String, dynamic> json) {
    this.avatar = json['avatar'];
  }
}
