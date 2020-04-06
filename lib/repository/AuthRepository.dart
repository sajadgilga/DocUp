import 'package:docup/models/LoginResponseEntity.dart';
import 'package:docup/models/VerifyResponseEntity.dart';
import 'package:docup/networking/ApiProvider.dart';

class AuthRepository {
  ApiProvider _provider = ApiProvider();

  Future<LoginResponseEntity> login(String username) async {
    final response = await _provider.post("api/auth/login/",
        body: {"user_type": "0", "username": username});
    return LoginResponseEntity.fromJson(response);
  }

  Future<VerifyResponseEntity> verify(String username, String password) async {
    final response = await _provider.post("api/auth/verify/",
        body: {"username": username, "password": password});
    return VerifyResponseEntity.fromJson(response);
  }
}
