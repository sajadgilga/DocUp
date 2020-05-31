import 'dart:convert';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/panel/panelMenu/PanelMenuItem.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/customPainter/DrawerPainter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoctorPanelMenu extends StatelessWidget {
  ValueChanged<String> onPush;

  DoctorPanelMenu(this.onPush);

  Widget _menu(height, context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[_menuLabel(), _menuList(height, context)],
      );

  Widget _menuLabel() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            Strings.doctorPanelMenuLabel,
            style: TextStyle(fontWeight: FontWeight.w100, fontSize: 14),
          ),
          Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(right: 5),
              width: 20,
              height: 20,
              child: Divider(
                thickness: 2,
                color: Colors.black,
              )),
        ],
      );

  Color getColor(DoctorPanelSection section,
      {PanelTabState panelTabState, int id, context}) {
    if (BlocProvider.of<PanelSectionBloc>(context).state.doctorSection ==
        section) {
      var entity = BlocProvider.of<EntityBloc>(context).state.entity;
      if (panelTabState == null && id == null) return IColors.themeColor;
      if (panelTabState != null &&
          BlocProvider.of<TabSwitchBloc>(context).state == panelTabState)
        return IColors.themeColor;
      else if (id == entity.pId) return IColors.themeColor;
    }
    return IColors.activePanelMenu;
  }

  Widget _requests(isActive, mPatient, context) {
    BlocProvider.of<SearchBloc>(context).add(SearchCountGet());
    return PanelMenuMainItem(onPush,
        subItems: [],
        doctorSection: DoctorPanelSection.REQUESTS,
        label: Strings.doctorPanelRequestsLabel,
        isActive: isActive,
        color: getColor(DoctorPanelSection.REQUESTS, context: context),
        isEmpty: true,
        isPatient: false,
        asset: Assets.doctorAvatar);
  }

  Widget _history(isActive, mPatient, context) => PanelMenuMainItem(onPush,
      subItems: [],
      label: Strings.doctorPanelHistoryLabel,
      isActive: isActive,
      color: getColor(DoctorPanelSection.HISTORY, context: context),
      doctorSection: DoctorPanelSection.HISTORY,
      isEmpty: true,
      isPatient: false,
      icon: Icons.history);

  Widget _healthEvents(isActive, mPatient, context) => PanelMenuMainItem(onPush,
      subItems: [PanelSubItem('تقویم', 'schedule', IColors.activePanelMenu)],
      label: Strings.doctorPanelHealthEventsLabel,
      isActive: isActive,
      color: getColor(DoctorPanelSection.HEALTH_EVENTS, context: context),
      doctorSection: DoctorPanelSection.HEALTH_EVENTS,
      isPatient: false,
      asset: Assets.calendarCheck);

  Widget _myPatinets(isActive, partners, context) => PanelMenuMainItem(onPush,
      subItems: partners,
      label: Strings.panelIPatientLabel,
      icon: Icons.person,
      color: getColor(DoctorPanelSection.DOCTOR_INTERFACE, context: context),
      //TODO
      isActive: isActive,
      isMyPartners: true,
      isPatient: false,
      doctorSection: DoctorPanelSection.DOCTOR_INTERFACE);

  List<Widget> _patientPanelMenu(isActive, mPatient, partners, context) => [
        _myPatinets(isActive, partners, context),
        _requests(isActive, mPatient, context),
        _history(isActive, mPatient, context),
        _healthEvents(isActive, mPatient, context),
      ];

  List<PanelSubItem> _getPartners(context) {
    List<PanelSubItem> partners = [];
    var state = BlocProvider.of<PanelBloc>(context).state;
    for (var panel in state.panels) {
      if (panel.status > 1)
        partners.add(PanelSubItem(
            panel.patient.user.name,
            panel.patient.id.toString(),
            getColor(DoctorPanelSection.DOCTOR_INTERFACE,
                id: panel.patient.id, context: context),
            panelId: panel.id));
    }
    return partners;
  }

  Widget _menuList(height, context) {
    var mPatient = (BlocProvider.of<EntityBloc>(context)
        .state
        .entity
        .partnerEntity as PatientEntity);
    var isActive = mPatient != null;
    return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
      builder: (context, state) {
        return BlocBuilder<TabSwitchBloc, PanelTabState>(
          builder: (context, tabstate) {
            return Container(
                constraints: BoxConstraints(maxHeight: height - 250),
                child: ListView(
                  children: _patientPanelMenu(
                      isActive, mPatient, _getPartners(context), context),
                ));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _menu(MediaQuery.of(context).size.height, context),
    );
  }
}
