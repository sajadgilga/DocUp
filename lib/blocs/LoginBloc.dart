import 'dart:async';

import 'package:docup/models/LoginResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/AuthRepository.dart';

class LoginBloc {
  AuthRepository _repository;
  StreamController _controller;

  StreamSink<Response<LoginResponseEntity>> get dataSink => _controller.sink;

  Stream<Response<LoginResponseEntity>> get dataStream => _controller.stream;

  LoginBloc() {
    _controller = StreamController<Response<LoginResponseEntity>>();
    _repository = AuthRepository();
  }

  login(String username) async {
    dataSink.add(Response.loading('loading'));
    try {
      LoginResponseEntity loginResponseEntity =
          await _repository.login(username);
      dataSink.add(Response.completed(loginResponseEntity));
    } catch (e) {
      dataSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() => _controller?.close();
}
