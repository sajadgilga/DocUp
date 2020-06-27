import 'dart:async';

import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/networking/CustomException.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/AuthRepository.dart';
import 'package:docup/ui/start/RoleType.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc {
  AuthRepository _repository;
  StreamController _loginController;
  StreamController _verifyController;

  StreamSink<Response<LoginResponseEntity>> get loginSink =>
      _loginController.sink;

  StreamSink<Response<VerifyResponseEntity>> get verifySink =>
      _verifyController.sink;

  Stream<Response<LoginResponseEntity>> get loginStream =>
      _loginController.stream;

  Stream<Response<VerifyResponseEntity>> get verifyStream =>
      _verifyController.stream;

  AuthBloc() {
    _loginController = StreamController<Response<LoginResponseEntity>>();
    _verifyController = StreamController<Response<VerifyResponseEntity>>();
    _repository = AuthRepository();
  }

  login(RoleType roleType) async {
    loginSink.add(Response.loading());
    try {
      String username = await getUserName();
      LoginResponseEntity response =
          await _repository.login(username, roleType.index);
      loginSink.add(Response.completed(response));
    } catch (e) {
      loginSink.add(Response.error(e));
      print(e);
    }
  }

  loginWithUserName(String username, RoleType roleType) async {
    saveUserName(username);
    login(roleType);
  }

  verify(String password, bool isPatient) async {
    verifySink.add(Response.loading());
    try {
      String username = await getUserName();
      VerifyResponseEntity response =
          await _repository.verify(username, password);
      saveUserName(username);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', response.token);
      prefs.setBool('isPatient', isPatient);
      verifySink.add(Response.completed(response));
    } catch (e) {
      verifySink.add(Response.error(e));
      print(e);
    }
  }

  saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', userName);
  }

  getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  dispose() {
    _loginController?.close();
    _verifyController?.close();
  }
}
