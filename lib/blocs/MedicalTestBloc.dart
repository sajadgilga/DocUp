import 'package:bloc/bloc.dart';
import 'package:docup/models/AddTestEntity.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/models/PayResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/MedicalTestRepository.dart';
import 'package:docup/repository/PaymentRepository.dart';
import 'package:flutter/cupertino.dart';

class MedicalTestBloc extends Bloc<MedicalTestEvent, MedicalTestState> {
  MedicalTestRepository _repository = MedicalTestRepository();

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

  Stream<MedicalTestState> _addTestToPatient(int testId, int patientId) async* {
    yield AddTestToPatientLoading();
    try {
      final AddTestEntity result =
          await _repository.addTestToPatient(testId, patientId);
      yield AddTestToPatientLoaded(result: result);
    } catch (e) {
      print("ws error $e");
      yield AddTestToPatientError();
    }
  }

  @override
  Stream<MedicalTestState> mapEventToState(event) async* {
    if (event is GetTest) {
      yield* _getTest(event.id);
    } else if (event is AddTestToPatient) {
      yield* _addTestToPatient(event.testId, event.patientId);
    }
  }
}

// events
abstract class MedicalTestEvent {}

class GetTest extends MedicalTestEvent {
  final int id;

  GetTest({@required this.id});
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
