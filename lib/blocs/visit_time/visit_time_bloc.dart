import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:meta/meta.dart';
import 'package:docup/repository/VisitRepository.dart';

part 'visit_time_event.dart';

part 'visit_time_state.dart';

class VisitTimeBloc extends Bloc<VisitTimeEvent, VisitTimeState> {
  VisitRepository _repository = VisitRepository();

  @override
  VisitTimeState get initialState => EmptyVisitTimeState();

  Stream<VisitTimeState> _get(VisitTimeGet event) async* {
    try {
      VisitEntity response = await _repository.getCurrentVisit(event.partnerId);
      yield VisitTimeLoadedState(visit: response);
    } catch (e) {
      yield VisitTimeErrorState();
    }
  }

  @override
  Stream<VisitTimeState> mapEventToState(VisitTimeEvent event) async* {
    if (event is VisitTimeGet) {
      yield* _get(event);
    }
  }
}
