import 'package:bloc/bloc.dart';
import 'package:Neuronio/models/Panel.dart';
import 'package:Neuronio/repository/PanelRepository.dart';
import 'package:equatable/equatable.dart';

class PanelBloc extends Bloc<PanelEvent, PanelState> {
  PanelRepository _repository = PanelRepository();

  @override
  get initialState => PanelUnloaded();

  Stream<PanelState> _get() async* {
    yield PanelLoading(panels: state.panels);
    try {
      final List<Panel> panels = await _repository.getAllPanelsOfMine();
      yield PanelsLoaded(panels: panels);
    } catch (e) {
      yield PanelError(panels: state.panels);
    }
  }

  @override
  Stream<PanelState> mapEventToState(event) async* {
    if (event is GetMyPanels) {
      yield* _get();
    } else if (event is RefreshMyPanels) {
    } else if (event is GetMyPartnerPanels) {}
  }
}

// events
abstract class PanelEvent {}

class GetMyPanels extends PanelEvent {}

class RefreshMyPanels extends PanelEvent {}

class GetMyPartnerPanels extends PanelEvent {}

// states
abstract class PanelState extends Equatable {
  List<Panel> panels;

  PanelState({this.panels = const []});

  @override
  List<Object> get props => [panels];
}

class PanelUnloaded extends PanelState {}

class PanelLoading extends PanelState {
  PanelLoading({panels}) : super(panels: panels);
}

class PanelEmpty extends PanelState {}

class PanelsLoaded extends PanelState {
  PanelsLoaded({panels}) : super(panels: panels);
}

class PanelError extends PanelState {
  PanelError({panels}) : super(panels: panels);
}
