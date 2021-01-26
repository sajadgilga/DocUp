import 'package:bloc/bloc.dart';
import 'package:Neuronio/models/PatientTracker.dart';
import 'package:Neuronio/repository/DoctorRepository.dart';

class PatientTrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  DoctorRepository _repository = DoctorRepository();

  @override
  TrackerState get initialState => TrackerState(PatientTracker());

  Stream<TrackerState> _get() async* {
    final tracker = await _repository.getPatientTracker();
    yield TrackerState(tracker);
  }

  @override
  Stream<TrackerState> mapEventToState(TrackerEvent event) async* {
    if (event is TrackerGet) {
      yield* _get();
    }
  }
}

// events

abstract class TrackerEvent {}

class TrackerGet extends TrackerEvent {}

class TrackerState {
  PatientTracker patientTracker;

  TrackerState(this.patientTracker);
}
