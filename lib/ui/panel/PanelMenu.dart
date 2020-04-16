import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/customPainter/DrawerPainter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PanelMenu extends StatefulWidget {
  final VoidCallback onPop;

  PanelMenu(this.onPop);

  @override
  _PanelMenuState createState() {
    return _PanelMenuState();
  }
}

class _PanelMenuState extends State<PanelMenu> {
  Widget _header(context) => Header(
          child: Row(
        children: <Widget>[
          GestureDetector(
              onTap: () {
                var state = BlocProvider.of<PanelBloc>(context).state;
                if (state is PanelsLoaded) if (state.panels.length > 0)
                  _popMenu();
              },
              child: Container(
                padding: EdgeInsets.only(top: 15, left: 10, right: 10),
                child: Image(
                  image: AssetImage(Assets.panelListIcon),
                  height: 40,
                  width: 40,
                ),
              )),
          Container(
            padding: EdgeInsets.only(top: 15, left: 10),
            child: GestureDetector(
              onTap: () {
                var state = BlocProvider.of<PanelBloc>(context).state;
                if (state is PanelsLoaded) if (state.panels.length > 0)
                  _popMenu();
              },
              child: Icon(
                Icons.search,
                size: 30,
              ),
            ),
          )
        ],
      ));

  Widget _menu(height, context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[_menuLabel(), _menuList(height, context)],
      );

  Widget _menuLabel() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            Strings.panelMenuLabel,
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

  Color getColor(PanelSection section, {PanelTabState panelTabState, int id}) {
    if (BlocProvider.of<PanelSectionBloc>(context).state.section == section) {
      var entity = BlocProvider.of<EntityBloc>(context).state.entity;
      if (panelTabState == null && id == null) return IColors.themeColor;
      if (panelTabState != null &&
          BlocProvider.of<TabSwitchBloc>(context).state == panelTabState)
        return IColors.themeColor;
      else if (id == entity.pId) return IColors.themeColor;
    }
    return IColors.activePanelMenu;
  }

  Widget _healthCalendar(isActive, mDoctor) => _PanelMenuMainItem(
          subItems: [
            PanelSubItem(
                Strings.panelReminderSubLabel,
                'reminders',
                getColor(PanelSection.HEALTH_CALENDAR,
                    panelTabState: PanelTabState.FirstTab),
                panelTabState: PanelTabState.FirstTab),
            PanelSubItem(
                Strings.panelCalendarSubLabel,
                'calendar',
                getColor(PanelSection.HEALTH_CALENDAR,
                    panelTabState: PanelTabState.SecondTab),
                panelTabState: PanelTabState.SecondTab),
            PanelSubItem(
                Strings.panelEventsSubLabel,
                'events',
                getColor(PanelSection.HEALTH_CALENDAR,
                    panelTabState: PanelTabState.ThirdTab),
                panelTabState: PanelTabState.ThirdTab),
          ],
          section: PanelSection.HEALTH_CALENDAR,
          label: Strings.panelHealthScheduleLabel,
          isActive: isActive,
          color: getColor(PanelSection.HEALTH_CALENDAR),
          subLabel: (mDoctor == null ? null : mDoctor.user.name),
          icon: Icons.calendar_today);

  Widget _healthFile(isActive, mDoctor) => _PanelMenuMainItem(
          subItems: [
            PanelSubItem(
                Strings.panelDocumentSubLabel,
                'documents',
                getColor(PanelSection.HEALTH_FILE,
                    panelTabState: PanelTabState.FirstTab),
                panelTabState: PanelTabState.FirstTab),
            PanelSubItem(
                Strings.panelResultsSubLabel,
                'results',
                getColor(PanelSection.HEALTH_FILE,
                    panelTabState: PanelTabState.SecondTab),
                panelTabState: PanelTabState.SecondTab),
            PanelSubItem(
                Strings.panelMedicinesSubLabel,
                'medicines',
                getColor(PanelSection.HEALTH_FILE,
                    panelTabState: PanelTabState.ThirdTab),
                panelTabState: PanelTabState.ThirdTab),
          ],
          label: Strings.panelHealthFileLabel,
          isActive: isActive,
          color: getColor(PanelSection.HEALTH_FILE),
          subLabel: (mDoctor == null ? null : mDoctor.user.name),
          section: PanelSection.HEALTH_FILE,
          icon: Icons.insert_drive_file);

  Widget _myDoctors(isActive, partners) => _PanelMenuMainItem(
      subItems: partners,
//              [PanelSubItem('دکتر زهرا شادلو', 'doctor_1'),],
      label: Strings.panelIDoctorLabel,
      icon: Icons.person,
      color: getColor(PanelSection.DOCTOR_INTERFACE),
      isActive: isActive,
      section: PanelSection.DOCTOR_INTERFACE);

  List<Widget> _patientPanelMenu(isActive, mDoctor, partners) => [
        _myDoctors(isActive, partners),
        _healthFile(isActive, mDoctor),
        _healthCalendar(isActive, mDoctor)
      ];

  List<PanelSubItem> _getPartners() {
    List<PanelSubItem> partners = [];
    var state = BlocProvider.of<PanelBloc>(context).state;
    if (state is PanelsLoaded)
      for (var panel in state.panels) {
        partners.add(PanelSubItem(
            panel.doctor.user.name,
            panel.doctor.id.toString(),
            getColor(PanelSection.DOCTOR_INTERFACE, id: panel.doctor.id)));
      }
    return partners;
  }

  Widget _menuList(height, context) {
    var mDoctor = (BlocProvider.of<EntityBloc>(context)
        .state
        .entity
        .partnerEntity as DoctorEntity);
    var isActive = mDoctor != null;
    return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
      builder: (context, state) {
        return BlocBuilder<TabSwitchBloc, PanelTabState>(
          builder: (context, tabstate) {
            return Container(
                constraints: BoxConstraints(maxHeight: height - 250),
                child: ListView(
                  children:
                      _patientPanelMenu(isActive, mDoctor, _getPartners()),
                ));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Stack(
        children: <Widget>[
          CustomPaint(
            painter: DrawerPainter(arcStart: 20),
            child: Container(
                padding: EdgeInsets.only(top: 100, right: 60),
                child: _menu(MediaQuery.of(context).size.height, context)),
          ),
          GestureDetector(
              onTap: () {
                _popMenu();
              },
              child: Container(
                  constraints: BoxConstraints(maxHeight: 100),
                  alignment: Alignment.topCenter,
                  child: _header(context))),
        ],
      ),
    );
  }

  void _popMenu() {
    widget.onPop();
  }
}

class PanelSubItem {
  String text;
  final String ID;
  final Color color;
  PanelTabState panelTabState;

  PanelSubItem(this.text, this.ID, this.color, {this.panelTabState});
}

class _PanelMenuMainItem extends StatelessWidget {
  final List<PanelSubItem> subItems;
  String label;
  final PanelSection section;
  final IconData icon;
  String subLabel;
  Color color;
  bool isActive = false;

  _PanelMenuMainItem(
      {Key key,
      this.section,
      this.subItems,
      this.label,
      this.subLabel,
      this.icon,
      this.isActive = false,
      this.color = IColors.activePanelMenu})
      : super(key: key);

  void _selectItem({item, context}) {
    if (item.panelTabState != null)
      BlocProvider.of<TabSwitchBloc>(context).add(item.panelTabState);
    else
      BlocProvider.of<EntityBloc>(context)
          .add(PartnerEntitySet(id: int.parse(item.ID)));
    BlocProvider.of<PanelSectionBloc>(context)
        .add(PanelSectionSelect(section: section));
    Navigator.of(context).pop();
  }

  Widget _subItem(context, {text, PanelSubItem item}) {
    return GestureDetector(
        onTap: () {
          _selectItem(item: item, context: context);
        },
        child: Container(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  (item == null ? text : item.text),
                  style: TextStyle(
                      fontSize: 12, color: (item == null ? color : item.color)),
                  textAlign: TextAlign.right,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (item == null ? color : item.color)),
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    if (!isActive) color = IColors.deactivePanelMenu;
    List<Widget> items = [];
    for (var item in subItems) {
      items.add(_subItem(context, item: item));
    }
    if (items.length == 0)
      items.add(_subItem(context, text: Strings.panelIDoctorEmptyLabel));
    return WillPopScope(
        child: Container(
          margin: EdgeInsets.only(bottom: 15),
          child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                (subLabel != null
                    ? Text(
                        subLabel,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: IColors.themeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w900),
                      )
                    : SizedBox(
                        width: 5,
                      )),
                SizedBox(
                  width: 10,
                ),
                Text(
                  label,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: color, fontSize: 16, fontWeight: FontWeight.w900),
                ),
                SizedBox(
                  width: 25,
                ),
                Icon(
                  icon,
                  size: 30,
                  color: color,
                )
              ],
            ),
            Container(
                padding: EdgeInsets.only(right: 40),
                child: Column(
                  children: items,
                ))
          ]),
        ),
        onWillPop: () async {
          var state = BlocProvider.of<PanelBloc>(context).state;
          if (state is PanelsLoaded) if (state.panels.length == 0)
            Navigator.of(context).pop();
          return false;
        });
  }
}
