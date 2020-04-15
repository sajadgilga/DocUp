import 'package:bloc/bloc.dart';
import 'package:docup/models/Panel.dart';
import 'package:docup/repository/PanelRepository.dart';
import 'package:equatable/equatable.dart';

class PanelBloc extends Bloc<PanelEvent, PanelState> {
  PanelRepository _repository = PanelRepository();

  @override
  get initialState => null;

  Stream<PanelState> _get() async* {
    yield PanelLoading();
    try {
      final List<Panel> panels = await _repository.getAllPanelsOfMine();
      yield PanelsLoaded(panels: panels);
    } catch (e) {
      yield PanelError();
    }
  }

  @override
  Stream<PanelState> mapEventToState(event) async* {
    if (event is GetMyPanels) {
      yield* _get();
    } else if (event is RefreshMyPanels) {
    } else if (event is GetMyPartnerPanels) {
    }
  }
}

// events
abstract class PanelEvent {}

class GetMyPanels extends PanelEvent {}

class RefreshMyPanels extends PanelEvent {}

class GetMyPartnerPanels extends PanelEvent {}

// states
abstract class PanelState extends Equatable {
  PanelState();

  @override
  List<Object> get props => [];
}

class PanelUnloaded extends PanelState {}

class PanelLoading extends PanelState {}

class PanelEmpty extends PanelState {}

class PanelsLoaded extends PanelState {
  List<Panel> panels;

  PanelsLoaded({@override this.panels});

  @override
  List<Object> get props => [panels];
}

class PanelError extends PanelState {}
