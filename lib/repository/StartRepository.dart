import 'package:docup/models/LoginResponseEntity.dart';
import 'package:docup/networking/ApiProvider.dart';

class StartRepository {
  ApiProvider _provider = ApiProvider();

  Future<LoginResponseEntity> login(String username) async {
    final response = await _provider.post("api/auth/login/",
        body: {"user_type": "0", "username": username});
    return LoginResponseEntity.fromJson(response);
  }
}
