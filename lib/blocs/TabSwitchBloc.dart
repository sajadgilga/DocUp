import 'package:bloc/bloc.dart';
import 'package:docup/ui/panel/Panel.dart';

class TabSwitchBloc extends Bloc<PanelStates, PanelStates> {
  @override
  PanelStates get initialState => PanelStates.SecondTab;

  @override
  Stream<PanelStates> mapEventToState(PanelStates event) async* {
    yield event;
  }
}

