import 'package:Neuronio/models/SearchResult.dart';
import 'package:Neuronio/repository/SearchRepository.dart';
import 'package:bloc/bloc.dart';

class PanelBloc extends Bloc<PanelEvent, PanelState> {
  /// TODO change to panel repository not with search
  // PanelRepository _repository = PanelRepository();
  SearchRepository _repository = SearchRepository();

  @override
  get initialState => PanelUnloaded();

  // Stream<PanelState> _get() async* {
  //   yield PanelLoading(panels: state.panels);
  //   try {
  //     final List<Panel> panels = await _repository.getAllPanelsOfMine();
  //     yield PanelsLoaded(panels: panels);
  //   } catch (e) {
  //     yield PanelError(panels: state.panels);
  //   }
  // }
  Stream<PanelState> _searchDoctor(DoctorPanel event) async* {
    if (state?.panels?.isDoctor  == true) {
      yield PanelLoading(panels: state.panels);
    } else {
      yield PanelLoading();
    }
    try {
      SearchResult searchResult;
      if (event.isMyDoctors) {
        searchResult = await _repository.searchMyDoctor();
      } else {
        searchResult = await _repository.searchDoctor(
            event.paramSearch, event.clinicId, event.expertise);
      }

      yield PanelLoaded(panels: searchResult);
    } catch (e) {
      yield PanelError();
    }
  }
  Stream<PanelState> _searchPatient(PatientPanel event) async* {
    if (state?.panels?.isPatient  == true) {
      yield PanelLoading(panels: state.panels);
    } else {
      yield PanelLoading();
    }
    try {
      SearchResult searchResult;
      searchResult =
      await _repository.searchPatient(event.text, event.patientFilter);
      yield PanelLoaded(panels: searchResult);
    } catch (e) {
      yield PanelError();
    }
  }
  @override
  Stream<PanelState> mapEventToState(event) async* {
    if (event is DoctorPanel) {
      yield* _searchDoctor(event);
    }else if(event is PatientPanel){
      yield* _searchPatient(event);
    }
  }
}

// events
abstract class PanelEvent {}

class GetMyPanels extends PanelEvent {}

class PatientPanel extends PanelEvent {
  String text;
  String patientFilter;

  PatientPanel({this.text = "", this.patientFilter});
}

class DoctorPanel extends PanelEvent {
  bool isMyDoctors;
  String paramSearch;
  String expertise;
  int clinicId;

  /// TODO pagination should be completed after api document

  DoctorPanel(
      {this.paramSearch,
        this.clinicId,
        this.expertise,
        this.isMyDoctors = false});
}

// states
abstract class PanelState{
  SearchResult panels;

  PanelState({this.panels});
}

class PanelUnloaded extends PanelState {}

class PanelLoading extends PanelState {
  PanelLoading({panels}) : super(panels: panels);
}

class PanelEmpty extends PanelState {}

class PanelLoaded extends PanelState {
  PanelLoaded({panels}) : super(panels: panels);
}

class PanelError extends PanelState {
  PanelError({panels}) : super(panels: panels);
}
