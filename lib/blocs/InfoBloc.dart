import 'package:bloc/bloc.dart';
import 'package:docup/models/Panel.dart';
import 'package:docup/repository/InfoRepository.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  InfoRepository _repository = InfoRepository();

  @override
  get initialState => InfoLoading();

  Stream<InfoState> _get() async* {
    yield InfoLoading();
    try {
      final PanelSection Infos = await _repository.get();
      yield InfoLoaded(panelSection: Infos);
    } catch (e) {
      yield InfoError();
    }
  }

  @override
  Stream<InfoState> mapEventToState(event) async* {
    if (event is InfoGet) {
      yield* _get();
    }
  }
}

// events
abstract class InfoEvent {}

class InfoGet extends InfoEvent {}

// states
class InfoState {
  PanelSection panelSection;

  InfoState({this.panelSection});
}

class InfoError extends InfoState {}

class InfoLoaded extends InfoState {
  InfoLoaded({PanelSection panelSection}) : super(panelSection: panelSection);
}

class InfoLoading extends InfoState {
}
