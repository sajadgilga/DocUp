import 'package:bloc/bloc.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/models/PayResponseEntity.dart';
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
      yield GetTestLoaded();
    }
  }

  @override
  Stream<MedicalTestState> mapEventToState(event) async* {
    if (event is GetTest) {
      yield* _getTest(event.id);
    }
  }
}

// events
abstract class MedicalTestEvent {}

class GetTest extends MedicalTestEvent {
  final int id;

  GetTest({@required this.id});
}

// states
class MedicalTestState {
  MedicalTest result;

  MedicalTestState({this.result});
}

class GetTestError extends MedicalTestState {}

class GetTestLoaded extends MedicalTestState {
  GetTestLoaded({result}) : super(result: result);
}

class GetTestLoading extends MedicalTestState {}
