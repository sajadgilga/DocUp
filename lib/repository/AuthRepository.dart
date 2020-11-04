import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/networking/ApiProvider.dart';

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

  Future<LoginResponseEntity> login(String username, int userType) async {
    final response = await _provider.post("api/auth/log-in/",
        body: {"username": username, "user_type": userType}, withToken: false);
    return LoginResponseEntity.fromJson(response);
  }

  Future<UploadAvatarResponseEntity> uploadUserProfile(
      String base64ImageString, userId) async {
    final response = await _provider.patch(
        "api/auth/upload-profile-image/$userId",
        body: {"avatar": base64ImageString});
    return UploadAvatarResponseEntity.fromJson(response);
  }
}
