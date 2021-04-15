import 'package:Neuronio/models/Medicine.dart';
import 'package:Neuronio/repository/PatientRepository.dart';
import 'package:bloc/bloc.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  PatientRepository _repository = PatientRepository();

  @override
  // TODO: implement initialState
  MedicineState get initialState => MedicineEmpty();

  Stream<MedicineState> _get(MedicineGet event) async* {
    yield MedicineLoading(medicines: state.medicines);
    try {
      final List<Medicine> medicines = await _repository.getDrugs(
          doctorId: event.doctorId,
          isWithDate: event.isWithDate,
          date: event.date);
      yield MedicineLoaded(medicines: medicines);
    } catch (_) {
      yield MedicineError(medicines: state.medicines);
    }
  }

  @override
  Stream<MedicineState> mapEventToState(MedicineEvent event) async* {
    if (event is MedicineGet) yield* _get(event);
  }
}

class CreateMedicineBloc
    extends Bloc<MedicineCreationEvent, MedicineCreationStates> {
  PatientRepository _repository = PatientRepository();

  @override
  MedicineCreationStates get initialState => MedicineCreationStates.IDLE;

  Stream<MedicineCreationStates> _create(MedicineCreate event) async* {
    yield MedicineCreationStates.SENDING;
    try {
      final response = await _repository.addDrug(event.medicine);
      yield MedicineCreationStates.SENT;
    } catch (_) {
      yield MedicineCreationStates.ERROR;
    }
  }

  @override
  Stream<MedicineCreationStates> mapEventToState(
      MedicineCreationEvent event) async* {
    if (event is MedicineCreate) yield* _create(event);
  }
}

enum MedicineCreationStates { IDLE, SENDING, SENT, ERROR }

abstract class MedicineCreationEvent {}

class MedicineCreate extends MedicineCreationEvent {
  Medicine medicine;

  MedicineCreate({this.medicine});
}

// events
abstract class MedicineEvent {}

class MedicineGet extends MedicineEvent {
  final String doctorId;
  final bool isWithDate;
  final DateTime date;

  MedicineGet({this.doctorId, this.date, this.isWithDate = false});
}

// states
abstract class MedicineState {
  final List<Medicine> medicines;

  MedicineState({this.medicines = const []});
}

class MedicineEmpty extends MedicineState {}

class MedicineLoaded extends MedicineState {
  MedicineLoaded({List<Medicine> medicines = const []})
      : super(medicines: medicines);
}

class MedicineError extends MedicineState {
  MedicineError({List<Medicine> medicines = const []})
      : super(medicines: medicines);
}

class MedicineLoading extends MedicineState {
  final String errorMsg;

  MedicineLoading({this.errorMsg, List<Medicine> medicines = const []})
      : super(medicines: medicines);
}
