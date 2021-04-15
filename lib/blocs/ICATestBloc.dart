import 'dart:async';

import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/ICARepository.dart';
import 'package:bloc/bloc.dart';

class ICATestBloc extends Bloc<ICATestScoreEvent, ICAScoresState> {
  IcaTestRepository _repository = IcaTestRepository();

  /// buy and load clinic screening plan
  StreamController _screeningICAScoreController =
      StreamController<Response<ICATestScores>>();

  StreamSink<Response<ICATestScores>> get updateScoreSink =>
      _screeningICAScoreController.sink;

  Stream<Response<ICATestScores>> get updateScoreStream =>
      _screeningICAScoreController.stream;

  updateIcaTestScores(ICATestScores icaTestScores, int screeningStepId) async {
    updateScoreSink.add(Response.loading());
    try {
      ICATestScores response = await _repository.setScoreForScreeningICA(
          icaTestScores, screeningStepId);
      updateScoreSink.add(Response.completed(response));
    } catch (e) {
      updateScoreSink.add(Response.error(e));
      print(e);
    }
  }

  /// renew
  void reNewStreams() {
    try {
      _screeningICAScoreController.close();
    } finally {
      _screeningICAScoreController = StreamController<Response<Screening>>();
    }
  }

  /// patient screening plan
  @override
  get initialState => IcaTestScoreLoading();

  Stream<ICAScoresState> _getScreeningICATestScore(
      GetScreeningICATestScore event) async* {
    yield IcaTestScoreLoading(result: this.state.result);
    try {
      final ICATestScores icaTestScores =
          await _repository.getIcaTestScore(event.screeningStepId);
      yield ICATestScoreLoaded(result: icaTestScores);
    } catch (e) {
      if (e.getCode() == 404) {
        yield ICATestScoreLoaded(result: ICATestScores());
      } else {
        yield ICATestScoreError();
      }
    }
  }

  @override
  Stream<ICAScoresState> mapEventToState(event) async* {
    if (event is GetScreeningICATestScore) {
      yield* _getScreeningICATestScore(event);
    }
  }
}

// events
abstract class ICATestScoreEvent {}

class GetScreeningICATestScore extends ICATestScoreEvent {
  int screeningStepId;

  GetScreeningICATestScore({this.screeningStepId});
}

// states
abstract class ICAScoresState {
  ICATestScores result;

  ICAScoresState({this.result});
}

class ICATestScoreError extends ICAScoresState {
  ICATestScoreError({result}) : super(result: result);
}

class ICATestScoreLoaded extends ICAScoresState {
  ICATestScoreLoaded({result}) : super(result: result);
}

class IcaTestScoreLoading extends ICAScoresState {
  IcaTestScoreLoading({result}) : super(result: result);
}
