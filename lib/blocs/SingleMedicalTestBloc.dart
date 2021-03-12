import 'dart:async';

import 'package:Neuronio/models/MedicalTest.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/MedicalTestRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

class SingleMedicalTestBloc extends Bloc<MedicalTestEvent, MedicalTestState> {
  MedicalTestRepository _repository = MedicalTestRepository();
  StreamController _utilController =
      StreamController<Response<MedicalTestResponseEntity>>();

  StreamSink<Response<MedicalTestResponseEntity>> get apiSink =>
      _utilController.sink;

  Stream<Response<MedicalTestResponseEntity>> get apiStream =>
      _utilController.stream;

  addTestToPartner(int testId, int patientId) async {
    apiSink.add(Response.loading());
    try {
      final MedicalTestResponseEntity result =
          await _repository.addTestToPatient(testId, patientId);
      apiSink.add(Response.completed(result));
    } catch (e) {
      apiSink.add(Response.error(e));
      print(e);
    }
  }

  @override
  get initialState => GetTestLoading();

  Stream<MedicalTestState> _getTest(int id) async* {
    yield GetTestLoading();
    try {
      final MedicalTest result = await _repository.getTest(id);
      yield GetTestLoaded(result: result);
    } catch (e) {
      yield GetTestError();
    }
  }

  Stream<MedicalTestState> _getPatientTestAndResponse(
      GetPatientTestAndResponse event) async* {
    yield GetTestLoading();
    try {
      final MedicalTest result = await _repository.getPatientTestAndResponse(
          event.type, event.testId, event.patientId,
          panelId: event.panelId,
          panelTestId: event.panelTestId,
          screeningId: event.screeningId);
      yield GetTestLoaded(result: result);
    } catch (e) {
      yield GetTestError();
    }
  }

  @override
  Stream<MedicalTestState> mapEventToState(event) async* {
    if (event is GetTest) {
      yield* _getTest(event.id);
    } else if (event is GetPatientTestAndResponse) {
      yield* _getPatientTestAndResponse(event);
    } else if (event is AddTestToPatient) {
      yield* addTestToPartner(event.testId, event.patientId);
    }
  }
}

// events
abstract class MedicalTestEvent {}

class GetTest extends MedicalTestEvent {
  final int id;

  GetTest({@required this.id});
}

class GetPatientTestAndResponse extends MedicalTestEvent {
  final MedicalPageDataType type;
  final int panelTestId;
  final int testId;
  final int patientId;
  final int panelId;
  final int screeningId;

  GetPatientTestAndResponse(this.type,
      {@required this.testId,
      @required this.patientId,
      this.panelId,
      this.panelTestId,
      this.screeningId});
}

class AddTestToPatient extends MedicalTestEvent {
  final int testId;
  final int patientId;

  AddTestToPatient({@required this.testId, @required this.patientId});
}

// states
class MedicalTestState {
  MedicalTest result;

  MedicalTestState({this.result});
}

class GetTestError extends MedicalTestState {}

class AddTestToPatientError extends MedicalTestState {}

class GetTestLoaded extends MedicalTestState {
  GetTestLoaded({result}) : super(result: result);
}

class AddTestToPatientLoaded extends MedicalTestState {
  AddTestToPatientLoaded({result}) : super(result: result);
}

class GetTestLoading extends MedicalTestState {}

class AddTestToPatientLoading extends MedicalTestState {}
