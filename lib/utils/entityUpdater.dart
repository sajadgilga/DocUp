import 'dart:async';

import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/PanelBloc.dart';
import 'package:Neuronio/models/UserEntity.dart';

import 'dateTimeService.dart';

class EntityAndPanelUpdater {
  static EntityBloc _entityBloc;
  static PanelBloc _panelBloc;
  static Timer _timer;

  static void start(EntityBloc _entityBloc, PanelBloc _panelBloc) {
    if (_timer == null) {
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

  static void end() {
    if (_timer != null) {
      EntityAndPanelUpdater._entityBloc = null;
      EntityAndPanelUpdater._panelBloc = null;
      _timer.cancel();
      _timer = null;
    }
  }

  static void processOnEntityLoad(Function(Entity) function) {
    /// call a function after entity is loaded completely
    if (_entityBloc.state is EntityLoaded || _entityBloc.state.entity != null) {
      function(_entityBloc.state.entity);
    } else {
      StreamSubscription streamSubscription;
      streamSubscription = _entityBloc.listen((data) {
        if (data is EntityLoaded) {
          function(_entityBloc.state.entity);
          streamSubscription.cancel();
        }
      });
    }
  }
}
