import 'dart:async';

import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/PatientRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  PatientRepository _repository;
  StreamController _controller;

  StreamSink<Response<PatientEntity>> get dataSink => _controller.sink;

  Stream<Response<PatientEntity>> get dataStream => _controller.stream;

  PatientBloc() {
    _controller = StreamController<Response<PatientEntity>>();
    _repository = PatientRepository();
  }

  updateProfile(
      {String firstName,
      String lastName,
      String nationalCode,
      double height,
      double weight,
      String birthCity,
      String currentCity,
      int genderNumber}) async {
    dataSink.add(Response.loading());
    try {
      PatientEntity patient = await _repository.update(PatientEntity(
          user: User(
              firstName: firstName,
              lastName: lastName,
              nationalId: nationalCode),
          height: height,
          weight: weight,
          birthLocation: birthCity,
          city: currentCity,
          genderNumber: genderNumber));
      dataSink.add(Response.completed(patient));
    } catch (e) {
      dataSink.add(Response.error(e));
      print(e);
    }
  }

  Stream<PatientState> _get() async* {
    yield PatientLoading();
    try {
      PatientEntity patient = await _repository.get();
      yield PatientLoaded(patient: patient);
    } catch (e) {
      yield PatientError();
    }
  }

  dispose() => _controller?.close();

  @override
  get initialState => null;

  @override
  Stream<PatientState> mapEventToState(event) async* {
    if (event is PatientGet) {
      yield* _get();
    } else if (event is PatientUpdate) {}
  }
}

//events
abstract class PatientEvent {}

class PatientUpdate extends PatientEvent {}

class PatientGet extends PatientEvent {}

//states
abstract class PatientState extends Equatable {
  PatientState();

  @override
  List<Object> get props => [];
}

class PatientUnLoaded extends PatientState {}

class PatientLoading extends PatientState {}

class PatientError extends PatientState {}

class PatientLoaded extends PatientState {
  PatientEntity patient;

  PatientLoaded({@required this.patient});

  @override
  List<Object> get props => [patient];
}

class PatientEmpty extends PatientState {}
