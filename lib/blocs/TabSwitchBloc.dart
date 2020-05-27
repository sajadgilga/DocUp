import 'package:bloc/bloc.dart';
import 'package:DocUp/ui/panel/Panel.dart';

class TabSwitchBloc extends Bloc<PanelTabState, PanelTabState> {
  @override
  PanelTabState get initialState => PanelTabState.SecondTab;

  @override
  Stream<PanelTabState> mapEventToState(PanelTabState event) async* {
    yield event;
  }
}

