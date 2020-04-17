import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PanelSectionBloc extends Bloc<PanelSectionEvent, PanelSectionSelected> {
  @override
  get initialState => PanelSectionSelected(
      patientSection: PatientPanelSection.DOCTOR_INTERFACE,
      doctorSection: DoctorPanelSection.DOCTOR_INTERFACE);

  Stream<PanelSectionSelected> _select(pId, dId, section) async* {
    yield PanelSectionSelected(
        patientSection: (pId == null ? state.patientSection : pId),
        doctorSection: (dId == null ? state.doctorSection : dId),
        section: (section == null ? state.section : section));
  }

  @override
  Stream<PanelSectionSelected> mapEventToState(event) async* {
    if (event is PanelSectionSelect) {
      yield* _select(event.patientSection, event.doctorSection, event.section);
    }
  }
}

// events
abstract class PanelSectionEvent {}

class PanelSectionSelect extends PanelSectionEvent {
  PatientPanelSection patientSection;
  DoctorPanelSection doctorSection;
  PanelSection section;

  PanelSectionSelect({this.patientSection, this.doctorSection, this.section});
}

enum PanelSection { DOCTOR, PATIENT }

enum PatientPanelSection {
  // client app
  DOCTOR_INTERFACE,
  HEALTH_FILE,
  HEALTH_CALENDAR,
  // doctor app
//  CURING_PATIENT_INTERFACE,
}

enum DoctorPanelSection { DOCTOR_INTERFACE, REQUESTS, HISTORY, HEALTH_EVENTS }

// states
class PanelSectionSelected extends Equatable {
  PatientPanelSection patientSection;
  DoctorPanelSection doctorSection;
  PanelSection section;

  PanelSectionSelected({this.patientSection, this.doctorSection, this.section});

  @override
  List<Object> get props => [patientSection, doctorSection, section];
}
