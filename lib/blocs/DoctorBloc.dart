import 'dart:async';

import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/DoctorRepository.dart';

class DoctorBloc {
  DoctorRepository _repository;
  StreamController _doctorController;

  StreamSink<Response<DoctorEntity>> get doctorSink => _doctorController.sink;

  Stream<Response<DoctorEntity>> get doctorStream => _doctorController.stream;

  DoctorBloc() {
    _doctorController = StreamController<Response<DoctorEntity>>();
    _repository = DoctorRepository();
  }

  updateProfile(
      {String firstName,
      String lastName,
      String nationalCode,
      String expertise}) async {
    doctorSink.add(Response.loading());
    try {
      DoctorEntity _response = await _repository.update(DoctorEntity(
          user: User(
              firstName: firstName,
              lastName: lastName,
              nationalId: nationalCode),
          expert: expertise));
      doctorSink.add(Response.completed(_response));
    } catch (e) {
      doctorSink.add(Response.error(e));
      print(e);
    }
  }

  addOrUpdateAccountNumber(String accountNumber) async {
    doctorSink.add(Response.loading());
    try {
      DoctorEntity _response = await _repository
          .update(DoctorEntity(accountNumbers: [accountNumber]));
      doctorSink.add(Response.completed(_response));
    } catch (e) {
      doctorSink.add(Response.error(e));
      print(e);
    }
  }

  dispose() {
    _doctorController?.close();
  }
}
