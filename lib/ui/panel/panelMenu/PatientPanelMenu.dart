// import 'dart:convert';
//
// import 'package:Neuronio/blocs/EntityBloc.dart';
// import 'package:Neuronio/blocs/PanelBloc.dart';
// import 'package:Neuronio/blocs/PanelSectionBloc.dart';
// import 'package:Neuronio/blocs/TabSwitchBloc.dart';
// import 'package:Neuronio/constants/assets.dart';
// import 'package:Neuronio/constants/colors.dart';
// import 'package:Neuronio/constants/strings.dart';
// import 'package:Neuronio/models/DoctorEntity.dart';
// import 'package:Neuronio/models/PatientEntity.dart';
// import 'package:Neuronio/models/UserEntity.dart';
// import 'package:Neuronio/ui/panel/Panel.dart';
// import 'package:Neuronio/ui/panel/panelMenu/PanelMenuItem.dart';
// import 'package:Neuronio/ui/widgets/DocupHeader.dart';
// import 'package:Neuronio/ui/widgets/Header.dart';
// import 'package:flutter/material.dart';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class PatientPanelMenu extends StatelessWidget {
//   ValueChanged<String> onPush;
//
//   bool isPatient;
//
//   PatientPanelMenu(this.onPush, {Key key, this.isPatient = true})
//       : super(key: key);
//
//   Widget _menu(height, context) => Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: <Widget>[
//           menuLabel(isPatient
//               ? Strings.patientPanelMenuLabel
//               : Strings.doctorPanelMenuLabel),
//           _menuList(height, context)
//         ],
//       );
//
//   Color getColor(PatientPanelSection section,
//       {PanelTabState panelTabState, int id, context}) {
//     if (BlocProvider.of<PanelSectionBloc>(context).state.patientSection ==
//         section) {
//       var entity = BlocProvider.of<EntityBloc>(context).state.entity;
//       if (panelTabState == null && id == null) return IColors.themeColor;
//       if (panelTabState != null &&
//           BlocProvider.of<TabSwitchBloc>(context).state == panelTabState)
//         return IColors.themeColor;
//       else if (id == entity.pId) return IColors.themeColor;
//     }
//     return IColors.activePanelMenu;
//   }
//
//   Widget _healthCalendar(isActive, mDoctor, context) => PanelMenuMainItem(
//       onPush,
//       subItems: [
//         PanelSubItem(
//             Strings.panelCalendarSubLabel,
//             'calendar',
//             getColor(PatientPanelSection.HEALTH_CALENDAR,
//                 panelTabState: tabs['calendar'], context: context),
//             panelTabState: tabs['calendar']),
//         PanelSubItem(
//             Strings.panelEventsSubLabel,
//             'events',
//             getColor(PatientPanelSection.HEALTH_CALENDAR,
//                 panelTabState: tabs['events'], context: context),
//             panelTabState: tabs['events']),
//         PanelSubItem(
//             Strings.panelReminderSubLabel,
//             'reminders',
//             getColor(PatientPanelSection.HEALTH_CALENDAR,
//                 panelTabState: tabs['reminders'], context: context),
//             panelTabState: tabs['reminders']),
//       ],
//       patientSection: PatientPanelSection.HEALTH_CALENDAR,
//       label: Strings.panelHealthScheduleLabel,
//       isActive: isActive,
//       color: getColor(PatientPanelSection.HEALTH_CALENDAR, context: context),
//       subLabel: (mDoctor == null ? null : mDoctor.user.name),
//       icon: Icons.calendar_today);
//
//   Widget _healthFile(isActive, mDoctor, context) => PanelMenuMainItem(onPush,
//       subItems: [
//         PanelSubItem(
//             Strings.panelDocumentSubLabel,
//             'documents',
//             getColor(PatientPanelSection.HEALTH_FILE,
//                 panelTabState: tabs['documents'], context: context),
//             panelTabState: tabs['documents']),
// //  panelTabState: PanelTabState.FirstTab, context: context),
// //            panelTabState: PanelTabState.FirstTab),
//         PanelSubItem(
//             Strings.panelMedicinesSubLabel,
//             'medicines',
//             getColor(PatientPanelSection.HEALTH_FILE,
//                 panelTabState: tabs['medicines'], context: context),
//             panelTabState: tabs['medicines']),
// //  panelTabState: PanelTabState.FirstTab, context: context),
// //            panelTabState: PanelTabState.FirstTab),
//         PanelSubItem(
//             Strings.panelResultsSubLabel,
//             'results',
//             getColor(PatientPanelSection.HEALTH_FILE,
//                 panelTabState: tabs['results'], context: context),
//             panelTabState: tabs['results']),
// //  panelTabState: PanelTabState.FirstTab, context: context),
// //            panelTabState: PanelTabState.FirstTab),
//       ],
//       label: Strings.panelHealthFileLabel,
//       isActive: isActive,
//       color: getColor(PatientPanelSection.HEALTH_FILE, context: context),
//       subLabel: (mDoctor == null ? null : mDoctor.user.name),
//       patientSection: PatientPanelSection.HEALTH_FILE,
//       icon: Icons.insert_drive_file);
//
//   Widget _myDoctors(isActive, partners, context) => PanelMenuMainItem(onPush,
//       subItems: partners,
// //              [PanelSubItem('دکتر زهرا شادلو', 'doctor_1'),],
//       label:
//           (isPatient ? Strings.panelIDoctorLabel : Strings.panelIPatientLabel),
//       icon: Icons.person,
//       color: getColor(PatientPanelSection.DOCTOR_INTERFACE, context: context),
//       isActive: isActive,
//       patientSection: PatientPanelSection.DOCTOR_INTERFACE);
//
//   List<Widget> _patientPanelMenu(isActive, mDoctor, partners, context) => [
//         _myDoctors(isActive, partners, context),
//         _healthFile(isActive, mDoctor, context),
//         _healthCalendar(isActive, mDoctor, context)
//       ];
//
//   List<PanelSubItem> _getPartners(context) {
//     List<PanelSubItem> partners = [];
//     var state = BlocProvider.of<PanelBloc>(context).state;
//     for (var panel in state.panels) {
//       try {
//         if (panel.doctorId == null || panel.patientId == null) continue;
//         if (panel.status > 1) {
//           if (isPatient)
//             partners.add(PanelSubItem(
//                 panel.doctor.user.name,
//                 panel.doctor.id.toString(),
//                 getColor(PatientPanelSection.DOCTOR_INTERFACE,
//                     id: panel.doctor.id, context: context),
//                 panelId: panel.id));
//           else
//             partners.add(PanelSubItem(
//                 panel.patient.user.name,
//                 panel.patient.id.toString(),
//                 getColor(PatientPanelSection.DOCTOR_INTERFACE,
//                     id: panel.patient.id, context: context),
//                 panelId: panel.id));
//         }
//       } catch (_) {
//         print("error in panel menu: probably some null thing in panel");
//       }
//     }
//     return partners;
//   }
//
//   void _goBack(context) {
//     if (isPatient) return;
//
//     BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
//         doctorSection: DoctorPanelSection.DOCTOR_INTERFACE,
//         section: PanelSection.DOCTOR));
//   }
//
//   Widget _menuList(height, context) {
//     Entity entity = BlocProvider.of<EntityBloc>(context).state.entity;
//     var mDoctor;
//     if (entity.partnerEntity != null) {
//       if (entity.isPatient)
//         mDoctor = (entity.partnerEntity as DoctorEntity);
//       else
//         mDoctor = (entity.partnerEntity as PatientEntity);
//     }
//     var isActive = mDoctor != null;
//     return BlocBuilder <PanelSectionBloc, PanelSectionSelected>(
//       builder: (context, state) {
//         return BlocBuilder <TabSwitchBloc, PanelTabState>(
//           builder: (context, tabstate) {
//             return Stack(children: <Widget>[
//               Container(
//                   constraints: BoxConstraints(maxHeight: height - 250),
//                   child: ListView(
//                     children: _patientPanelMenu(
//                         isActive, mDoctor, _getPartners(context), context),
//                   )),
//               Align(
//                   alignment: Alignment(-.8, 0),
//                   child: GestureDetector(
//                       onTap: () {
//                         _goBack(context);
//                       },
//                       child: Container(
//                         child: Icon(
//                           Icons.chevron_left,
//                           color:
//                               Color.fromRGBO(10, 10, 10, (isPatient ? 0 : 1)),
//                           size: 30,
//                         ),
//                       )))
//             ]);
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: _menu(MediaQuery.of(context).size.height, context),
//     );
//   }
// }
