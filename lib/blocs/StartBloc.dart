import 'dart:async';

import 'package:docup/models/LoginResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/StartRepository.dart';

class StartBloc {
  StartRepository _startRepository;
  StreamController _startDataController;

  StreamSink<Response<LoginResponseEntity>> get startDataSink =>
      _startDataController.sink;

  Stream<Response<LoginResponseEntity>> get startDataStream =>
      _startDataController.stream;

  StartBloc() {
    _startDataController = StreamController<Response<LoginResponseEntity>>();
    _startRepository = StartRepository();
  }

  login(String username) async {
    startDataSink.add(Response.loading('loading'));
    try {
      LoginResponseEntity loginResponseEntity = await _startRepository.login(username);
      startDataSink.add(Response.completed(loginResponseEntity));
    } catch (e) {
      startDataSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _startDataController?.close();
  }
}