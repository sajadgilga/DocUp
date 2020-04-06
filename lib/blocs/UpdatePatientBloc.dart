import 'dart:async';

import 'package:docup/models/UpdatePatientResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/PatientRepository.dart';

class UpdatePatientBloc {
  PatientRepository _repository;
  StreamController _controller;

  StreamSink<Response<Patient>> get dataSink => _controller.sink;

  Stream<Response<Patient>> get dataStream => _controller.stream;

  UpdatePatientBloc() {
    _controller = StreamController<Response<Patient>>();
    _repository = PatientRepository();
  }

  update(String fullName, String password) async {
    dataSink.add(Response.loading('loading'));
    try {
      Patient patient = await _repository
          .update(Patient(user: User(firstName: fullName, password: password)));
      dataSink.add(Response.completed(patient));
    } catch (e) {
      dataSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() => _controller?.close();
}
