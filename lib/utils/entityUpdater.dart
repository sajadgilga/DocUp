import 'dart:async';

import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/PanelBloc.dart';

class EntityAndPanelUpdater {
  static EntityBloc _entityBloc;
  static PanelBloc _panelBloc;
  static Timer _timer;
  
  static void start(EntityBloc _entityBloc,PanelBloc _panelBloc){
    if(_timer == null){
      EntityAndPanelUpdater._entityBloc = _entityBloc;
      EntityAndPanelUpdater._panelBloc = _panelBloc;
      EntityAndPanelUpdater.createTimer();
    }
  }

  static void createTimer() {
    _timer = Timer.periodic(Duration(seconds: 15), (Timer t) {
      print("Timer: ${DateTime.now()}");
      _entityBloc.add(EntityUpdate());
      _panelBloc.add(GetMyPanels());
    });
  }
}
