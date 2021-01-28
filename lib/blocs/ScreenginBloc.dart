import 'dart:async';

import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/ScreeningRepository.dart';
import 'package:bloc/bloc.dart';

class ScreeningBloc extends Bloc<ScreeningEvent, ScreeningState> {
  ScreeningRepository _repository = ScreeningRepository();

  /// buy and load clinic screening plan
  StreamController _screeningController =
      StreamController<Response<Screening>>();

  StreamSink<Response<Screening>> get apiSink => _screeningController.sink;

  Stream<Response<Screening>> get apiStream => _screeningController.stream;

  void reNewStreams() {
    try {
      _screeningController.close();
    } finally {
      _screeningController = StreamController<Response<Screening>>();
    }
  }

  getClinicScreeningPlan(int clinicId) async {
    apiSink.add(Response.loading());
    try {
      Screening screening = await _repository.getClinicScreeningPlan(clinicId);
      apiSink.add(Response.completed(screening));
    } catch (e) {
      apiSink.add(Response.error(e));
      print(e);
    }
  }

  /// patient screening plan
  @override
  get initialState => ScreeningLoading();

  Stream<ScreeningState> _getPatientScreeningPlan(
      GetPatientScreening event) async* {
    /// TODO
  }

  @override
  Stream<ScreeningState> mapEventToState(event) async* {
    if (event is GetPatientScreening) {
      yield* _getPatientScreeningPlan(event);
    }
  }
}

// events
abstract class ScreeningEvent {}

class GetPatientScreening extends ScreeningEvent {}

// states
abstract class ScreeningState {
  PatientScreening result;

  ScreeningState({this.result});
}

class ScreeningError extends ScreeningState {
  ScreeningError({result}) : super(result: result);
}

class ScreeningLoaded extends ScreeningState {
  ScreeningLoaded({result}) : super(result: result);
}

class ScreeningLoading extends ScreeningState {
  ScreeningLoading({result}) : super(result: result);
}
