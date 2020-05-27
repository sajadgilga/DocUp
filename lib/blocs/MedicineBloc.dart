import 'package:bloc/bloc.dart';
import 'package:DocUp/models/Medicine.dart';
import 'package:DocUp/repository/PatientRepository.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  PatientRepository _repository = PatientRepository();

  @override
  // TODO: implement initialState
  MedicineState get initialState => MedicineEmpty();

  Stream<MedicineState> _get() async* {
    yield MedicineLoading();
    try {
      final List<Medicine> medicines = await _repository.getDrugs();
      yield MedicineLoaded(medicines: medicines);
    } catch(_) {
      yield MedicineError();
    }
  }

  @override
  Stream<MedicineState> mapEventToState(MedicineEvent event) async* {
    if (event is MedicineGet)
      yield* _get();
  }
}

// events
abstract class MedicineEvent {}

class MedicineGet extends MedicineEvent {}

// states
abstract class MedicineState {}

class MedicineEmpty extends MedicineState {}

class MedicineLoaded extends MedicineState {
  final List<Medicine> medicines;

  MedicineLoaded({this.medicines});
}

class MedicineError extends MedicineState {}

class MedicineLoading extends MedicineState {}
