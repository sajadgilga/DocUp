
import 'dart:async';

import 'package:DocUp/models/AuthResponseEntity.dart';
import 'package:DocUp/models/DoctorEntity.dart';
import 'package:DocUp/models/PatientEntity.dart';
import 'package:DocUp/networking/Response.dart';
import 'package:DocUp/repository/DoctorRepository.dart';

class DoctorBloc {
  DoctorRepository _repository;
  StreamController _doctorController;

  StreamSink<Response<DoctorEntity>> get doctorSink =>
      _doctorController.sink;


  Stream<Response<DoctorEntity>> get doctorStream =>
      _doctorController.stream;


  DoctorBloc() {
    _doctorController = StreamController<Response<DoctorEntity>>();
    _repository = DoctorRepository();
  }

  update(String name, String password) async {
    doctorSink.add(Response.loading('loading'));
    try {
      DoctorEntity _response = await _repository.update(DoctorEntity(user: User(firstName: name, password: password)));
      doctorSink.add(Response.completed(_response));
    } catch (e) {
      doctorSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _doctorController?.close();
  }
}
