import 'dart:async';

import 'package:docup/models/VerifyResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/AuthRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyBloc {
  AuthRepository _repository;
  StreamController _controller;

  StreamSink<Response<VerifyResponseEntity>> get dataSink => _controller.sink;

  Stream<Response<VerifyResponseEntity>> get dataStream => _controller.stream;

  VerifyBloc() {
    _controller = StreamController<Response<VerifyResponseEntity>>();
    _repository = AuthRepository();
  }

  verify(String username, String password) async {
    dataSink.add(Response.loading('loading'));
    try {
      VerifyResponseEntity verifyResponseEntity =
          await _repository.verify(username, password);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', verifyResponseEntity.token);
      dataSink.add(Response.completed(verifyResponseEntity));
    } catch (e) {
      dataSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() => _controller?.close();
}
