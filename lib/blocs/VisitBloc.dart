import 'package:Neuronio/models/ListResult.dart';
import 'package:Neuronio/repository/DoctorRepository.dart';
import 'package:bloc/bloc.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  DoctorRepository _repository = DoctorRepository();

  @override
  get initialState => VisitLoading();

  Stream<VisitState> _get() async* {
    yield VisitLoading();
    try {
      final ListResult result = await _repository.getAllVisits();
      yield VisitLoaded(result: result);
    } catch (e) {
      yield VisitError();
    }
  }

  @override
  Stream<VisitState> mapEventToState(event) async* {
    if (event is VisitsGet) {
      yield* _get();
    }
  }
}

// events
abstract class VisitEvent {}

class VisitsGet extends VisitEvent {}

// states
class VisitState {
  ListResult result;

  VisitState({this.result});
}

class VisitError extends VisitState {}

class VisitLoaded extends VisitState {
  VisitLoaded({result}) : super(result: result);
}

class VisitLoading extends VisitState {}
