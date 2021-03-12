import 'dart:async';

import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/PanelBloc.dart';
import 'package:Neuronio/blocs/ScreenginBloc.dart';
import 'package:Neuronio/models/UserEntity.dart';

import 'dateTimeService.dart';

class EntityAndPanelUpdater {
  static EntityBloc _entityBloc;
  static PanelBloc _panelBloc;
  static ScreeningBloc _screeningBloc;
  static Timer _timer;

  static void start(
      EntityBloc _entityBloc, PanelBloc _panelBloc, _screeningBloc) {
    if (_timer == null) {
      EntityAndPanelUpdater._screeningBloc = _screeningBloc;
      EntityAndPanelUpdater._entityBloc = _entityBloc;
      EntityAndPanelUpdater._panelBloc = _panelBloc;
      EntityAndPanelUpdater.createTimer();
    }
  }

  static void createTimer() {
    getEntity();
    updatePanel();
    updateScreening();
    _timer = Timer.periodic(Duration(seconds: 15), (Timer t) {
      print("Timer: ${DateTimeService.getCurrentDateTime()}");
      updateEntity();
      updatePanel();
      updateScreening();
    });
  }

  static void getEntity() {
    _entityBloc.add(EntityGet());
  }

  static void updateEntity() {
    _entityBloc.add(EntityUpdate());
  }

  static void updateScreening() {
    EntityAndPanelUpdater.processOnEntityLoad((entity) {
      if (_entityBloc.state.entity.isPatient) {
        _screeningBloc.add(GetPatientScreening());
      }
    });
  }

  static void updatePanel() {
    _panelBloc.add(GetMyPanels());
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
    if (_entityBloc.state?.entity?.mEntity != null) {
      function(_entityBloc.state.entity);
    } else {
      StreamSubscription streamSubscription;
      streamSubscription = _entityBloc.listen((data) {
        if (data.mEntityStatus == BlocState.Loaded &&
            _entityBloc.state?.entity?.mEntity != null) {
          function(_entityBloc.state.entity);
          streamSubscription.cancel();
        }
      });
    }
  }
}
