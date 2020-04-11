import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/networking/ApiProvider.dart';

class AuthRepository {
  ApiProvider _provider = ApiProvider();

  Future<SignUpResponseEntity> signUp(String username) async {
    final response = await _provider.post("api/auth/sign-up/",
        body: {"user_type": 0, "username": username});
    return SignUpResponseEntity.fromJson(response);
  }

  Future<VerifyResponseEntity> verify(String username, String password) async {
    final response = await _provider.post("api/auth/verify/",
        body: {"username": username, "password": password});
    return VerifyResponseEntity.fromJson(response);
  }

  Future<VerifyResponseEntity> signIn(String username, String password) async {
    final response = await _provider.post("api/auth/sign-in/",
        body: {"username": username, "password": password});
    return VerifyResponseEntity.fromJson(response);
  }
}
