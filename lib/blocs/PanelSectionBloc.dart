import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PanelSectionBloc extends Bloc<PanelSectionEvent, PanelSectionSelected> {
  @override
  get initialState =>
      PanelSectionSelected(section: PanelSection.DOCTOR_INTERFACE);

  Stream<PanelSectionSelected> _select(id) async* {
    yield PanelSectionSelected(section: id);
  }

  @override
  Stream<PanelSectionSelected> mapEventToState(event) async* {
    if (event is PanelSectionSelect) {
      yield* _select(event.section);
    }
  }
}

// events
abstract class PanelSectionEvent {}

class PanelSectionSelect extends PanelSectionEvent {
  PanelSection section;

  PanelSectionSelect({@required this.section});
}

enum PanelSection { DOCTOR_INTERFACE, HEALTH_FILE, HEALTH_CALENDAR }

// states
class PanelSectionSelected extends Equatable {
  PanelSection section;

  PanelSectionSelected({this.section});

  @override
  List<Object> get props => [section];
}
