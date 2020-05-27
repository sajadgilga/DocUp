import 'package:DocUp/models/AuthResponseEntity.dart';
import 'package:DocUp/networking/ApiProvider.dart';

class AuthRepository {
  ApiProvider _provider = ApiProvider();

  Future<SignUpResponseEntity> signUp(String username, int userType) async {
    final response = await _provider.post("api/auth/sign-up/",
        body: {"user_type": userType, "username": username});
    if (response is List) return SignUpResponseEntity(success: response[0]);
    return SignUpResponseEntity.fromJson(response);
  }

  Future<VerifyResponseEntity> verify(String username, String password) async {
    final response = await _provider.post("api/auth/verify/",
        body: {"username": username, "password": password}, withToken: false);
    return VerifyResponseEntity.fromJson(response);
  }

  Future<VerifyResponseEntity> signIn(String username, String password) async {
    final response = await _provider.post("api/auth/sign-in/",
        body: {"username": username, "password": password}, withToken: false);
    return VerifyResponseEntity.fromJson(response);
  }
}
