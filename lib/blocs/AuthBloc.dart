import 'dart:async';

import 'package:DocUp/models/AuthResponseEntity.dart';
import 'package:DocUp/networking/Response.dart';
import 'package:DocUp/repository/AuthRepository.dart';
import 'package:DocUp/ui/start/RoleType.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc {
  AuthRepository _repository;
  StreamController _signUpController;
  StreamController _verifyController;
  StreamController _signInController;

  StreamSink<Response<SignUpResponseEntity>> get signUpSink =>
      _signUpController.sink;

  StreamSink<Response<VerifyResponseEntity>> get verifySink =>
      _verifyController.sink;

  StreamSink<Response<VerifyResponseEntity>> get signInSink =>
      _signInController.sink;

  Stream<Response<SignUpResponseEntity>> get signUpStream =>
      _signUpController.stream;

  Stream<Response<VerifyResponseEntity>> get verifyStream =>
      _verifyController.stream;

  Stream<Response<VerifyResponseEntity>> get signInStream =>
      _signInController.stream;

  AuthBloc() {
    _signUpController = StreamController<Response<SignUpResponseEntity>>();
    _verifyController = StreamController<Response<VerifyResponseEntity>>();
    _signInController = StreamController<Response<VerifyResponseEntity>>();
    _repository = AuthRepository();
  }

  signUp(String username, RoleType roleType) async {
    signUpSink.add(Response.loading('loading'));
    try {
      SignUpResponseEntity response =
          await _repository.signUp(username, roleType.index);
      signUpSink.add(Response.completed(response));
    } catch (e) {
      signUpSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  verify(String username, String password, bool isPatient) async {
    verifySink.add(Response.loading('loading'));
    try {
      VerifyResponseEntity response =
          await _repository.verify(username, password);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', response.token);
      prefs.setBool('isPatient', isPatient);
      verifySink.add(Response.completed(response));
    } catch (e) {
      verifySink.add(Response.error(e.toString()));
      print(e);
    }
  }

  signIn(String username, String password, bool isPatient) async {
    signInSink.add(Response.loading('loading'));
    try {
      VerifyResponseEntity response =
          await _repository.signIn(username, password);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', response.token);
      prefs.setBool('isPatient', isPatient);
      signInSink.add(Response.completed(response));
    } catch (e) {
      signInSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _signUpController?.close();
    _verifyController?.close();
    _signInController?.close();
  }
}
