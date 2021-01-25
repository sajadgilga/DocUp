import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:Neuronio/blocs/timer/TimerEvent.dart';
import 'package:meta/meta.dart';

import 'TimerState.dart';
import 'Tricker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  int duration;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker, this.duration = 60})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => Ready(duration);

  @override
  void onTransition(Transition<TimerEvent, TimerState> transition) {
    super.onTransition(transition);
    print(transition);
  }

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is Start) {
      yield* _mapStartToState(event);
    } else if (event is ExtendTime) {
      yield* _mapExtendToState(event);
    } else if (event is Pause) {
      yield* _mapPauseToState(event);
    } else if (event is Resume) {
      yield* _mapResumeToState(event);
    } else if (event is Reset) {
      yield* _mapResetToState(event);
    } else if (event is Tick) {
      yield* _mapTickToState(event);
    }
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
  }

  Stream<TimerState> _mapStartToState(Start start) async* {
    yield Running(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: start.duration).listen(
      (duration) {
        add(Tick(duration: duration));
      },
    );
  }

  Stream<TimerState> _mapExtendToState(ExtendTime extendTime) async* {
    int remainingSeconds = state.duration;
    _tickerSubscription?.cancel();
    _tickerSubscription =
        _ticker.tick(ticks: remainingSeconds + extendTime.duration).listen(
      (duration) {
        add(Tick(duration: duration));
      },
    );
  }

  Stream<TimerState> _mapPauseToState(Pause pause) async* {
//    final state = currentState;
    if (state is Running) {
      _tickerSubscription?.pause();
      yield Paused(state.duration);
    }
  }

  Stream<TimerState> _mapResumeToState(Resume pause) async* {
//    final state = currentState;
    if (state is Paused) {
      _tickerSubscription?.resume();
      yield Running(state.duration);
    }
  }

  Stream<TimerState> _mapResetToState(Reset reset) async* {
    _tickerSubscription?.cancel();
    yield Ready(duration);
  }

  Stream<TimerState> _mapTickToState(Tick tick) async* {
    yield tick.duration > 0 ? Running(tick.duration) : Finished();
  }
}
