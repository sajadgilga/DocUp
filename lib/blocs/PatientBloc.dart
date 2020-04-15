import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:docup/models/Patient.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/PatientRepository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  PatientRepository _repository;
  StreamController _controller;

  StreamSink<Response<Patient>> get dataSink => _controller.sink;

  Stream<Response<Patient>> get dataStream => _controller.stream;

  PatientBloc() {
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

  Stream<PatientState> _get() async* {
    yield PatientLoading();
    try {
      Patient patient = await _repository.get();
      yield PatientLoaded(patient: patient);
    } catch (e) {
      yield PatientError();
    }
//    dataSink.add(Response.loading('loading'));
//    try {
//      Patient patient = await _repository.get();
//      dataSink.add(Response.completed(patient));
//    } catch (e) {
//      dataSink.add(Response.error(e.toString()));
//      print(e);
//    }
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
  Patient patient;

  PatientLoaded({@required this.patient});

  @override
  List<Object> get props => [patient];
}

class PatientEmpty extends PatientState {}
