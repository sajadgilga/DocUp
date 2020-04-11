import 'dart:async';

import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/AuthRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc {
  AuthRepository _repository;
  StreamController _signUpController;
  StreamController _verifyController;
  StreamController _signInController;

  StreamSink<Response<SignUpResponseEntity>> get signUpSink => _signUpController.sink;
  StreamSink<Response<VerifyResponseEntity>> get verifySink => _verifyController.sink;

  Stream<Response<SignUpResponseEntity>> get signUpStream => _signUpController.stream;
  Stream<Response<VerifyResponseEntity>> get verifyStream => _verifyController.stream;

  StreamSink<Response<VerifyResponseEntity>> get signInSink => _signInController.sink;
  Stream<Response<VerifyResponseEntity>> get signInStream => _signInController.stream;

  AuthBloc() {
    _signUpController = StreamController<Response<SignUpResponseEntity>>();
    _verifyController = StreamController<Response<VerifyResponseEntity>>();
    _signInController = StreamController<Response<VerifyResponseEntity>>();
    _repository = AuthRepository();
  }

  signUp(String username) async {
    signUpSink.add(Response.loading('loading'));
    try {
      SignUpResponseEntity response = await _repository.signUp(username);
      signUpSink.add(Response.completed(response));
    } catch (e) {
      signUpSink.add(Response.error(e.toString()));
      print(e);
    }
  }


  verify(String username, String password) async {
    verifySink.add(Response.loading('loading'));
    try {
      VerifyResponseEntity response = await _repository.verify(username, password);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', response.token);
      verifySink.add(Response.completed(response));
    } catch (e) {
      verifySink.add(Response.error(e.toString()));
      print(e);
    }
  }


  signIn(String username, String password) async {
    signInSink.add(Response.loading('loading'));
    try {
      VerifyResponseEntity response = await _repository.signIn(username, password);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', response.token);
      signInSink.add(Response.completed(response));
    } catch (e) {
      signInSink.add(Response.error(e.toString()));
      print(e);
    }
  }


  dispose(){
    _signUpController?.close();
    _verifyController?.close();
    _signInController?.close();
  }
}
