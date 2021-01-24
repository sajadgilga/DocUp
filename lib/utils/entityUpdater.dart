import 'dart:async';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';

import 'dateTimeService.dart';

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
      print("Timer: ${DateTimeService.getCurrentDateTime()}");
      _entityBloc.add(EntityUpdate());
      _panelBloc.add(GetMyPanels());
    });
  }
  static void end(){
    if(_timer != null){
      EntityAndPanelUpdater._entityBloc = null;
      EntityAndPanelUpdater._panelBloc = null;
      _timer.cancel();
      _timer = null;
    }
  }
}
