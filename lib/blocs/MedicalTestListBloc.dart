import 'dart:async';

import 'package:Neuronio/models/MedicalTest.dart';
import 'package:Neuronio/repository/MedicalTestRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

class MedicalTestListBloc
    extends Bloc<MedicalTestListEvent, MedicalTestListState> {
  MedicalTestRepository _repository = MedicalTestRepository();

  @override
  get initialState => TestsListLoading();

  Stream<MedicalTestListState> _getAllTests(
      GetClinicMedicalTest getClinicMedicalTest) async* {
    yield TestsListLoading();
    try {
      final List<MedicalTestItem> result = await _repository.getAllTests();
      yield TestsListLoaded(result: result);
    } catch (e) {
      yield TestsListError();
    }
  }

  Stream<MedicalTestListState> _getEmptyMedicalList(
      EmptyMedicalTestList emptyMedicalTestList) async* {
    yield TestsListLoading();
    try {
      final List<MedicalTestItem> result = [];
      yield TestsListLoaded(result: result);
    } catch (e) {
      yield TestsListError();
    }
  }

  Stream<MedicalTestListState> _getAllPanelTests(
      GetPanelMedicalTest getPanelMedicalTest) async* {
    yield TestsListLoading(result: null);
    try {
      final List<PanelMedicalTestItem> result =
          await _repository.getPanelMedicalTests(getPanelMedicalTest.panelId);
      yield TestsListLoaded(result: result);
    } catch (e) {
      yield TestsListError();
    }
  }

  @override
  Stream<MedicalTestListState> mapEventToState(event) async* {
    if (event is GetClinicMedicalTest) {
      yield* _getAllTests(event);
    } else if (event is EmptyMedicalTestList) {
      yield* _getEmptyMedicalList(event);
    } else if (event is GetPanelMedicalTest) {
      yield* _getAllPanelTests(event);
    } else if (event is GetPatientFilledTests) {
      /// TODO amir: api incomplete
    }
  }
}

// events
abstract class MedicalTestListEvent {}

class GetClinicMedicalTest extends MedicalTestListEvent {
  /// TODO amir: hardcode id; it depends on future customer journey
  final int clinicId;

  GetClinicMedicalTest({this.clinicId = 4});
}

class GetPanelMedicalTest extends MedicalTestListEvent {
  /// TODO amir: hardcode id; it depends on future plans
  final int panelId;

  GetPanelMedicalTest({@required this.panelId = 4});
}

class EmptyMedicalTestList extends MedicalTestListEvent {
  EmptyMedicalTestList();
}

class GetPatientFilledTests {
  final int clinicId;
  final int patientId;

  GetPatientFilledTests({this.clinicId = 4, this.patientId});
}

// states
class MedicalTestListState {
  List<MedicalTestItem> result;

  MedicalTestListState({this.result});
}

class TestsListError extends MedicalTestListState {}

class TestsListLoaded extends MedicalTestListState {
  TestsListLoaded({result}) : super(result: result);
}

class TestsListLoading extends MedicalTestListState {
  TestsListLoading({result}) : super(result: result);
}
