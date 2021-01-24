import 'dart:convert';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/utils/CrossPlatformSvg.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PanelSubItem {
  String text;
  final String ID;
  final Color color;
  PanelTabState panelTabState;
  int panelId;

  PanelSubItem(this.text, this.ID, this.color,
      {this.panelTabState, this.panelId});
}

class PanelMenuMainItem extends StatelessWidget {
  ValueChanged<String> onPush;
  final List<PanelSubItem> subItems;
  String label;
  final PatientPanelSection patientSection;
  final DoctorPanelSection doctorSection;
  bool isPatient;
  bool isMyPartners;
  IconData icon;
  String asset;
  String subLabel;
  Color color;
  bool isActive = false;
  bool isEmpty = false;

  PanelMenuMainItem(this.onPush,
      {Key key,
      this.patientSection,
      this.doctorSection,
      this.isPatient = true,
      this.isMyPartners = false,
      this.subItems,
      this.label,
      this.subLabel,
      this.icon,
      this.asset,
      this.isActive = false,
      this.isEmpty = false,
      this.color = IColors.activePanelMenu})
      : super(key: key);

  void _selectMenuItem({context, menuItem}) {
    if (menuItem == DoctorPanelSection.REQUESTS) {
      onPush(NavigatorRoutes.visitRequestList);
    }
  }

  void _selectItem({item, context}) {
    if ((!isPatient && doctorSection != DoctorPanelSection.DOCTOR_INTERFACE)) {
      showNextVersionDialog(context);
      return;
    }
    if (item.panelTabState != null)
      BlocProvider.of<TabSwitchBloc>(context).add(item.panelTabState);
    else {
      var entity = BlocProvider.of<EntityBloc>(context).state.entity;
//      if (entity.isActivePanel(item.panelId))
      BlocProvider.of<EntityBloc>(context)
          .add(PartnerEntitySet(id: int.parse(item.ID), panelId: item.panelId));
    }
    if (!isPatient) {
      if (isMyPartners) {
        BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
            patientSection: patientSection,
            doctorSection: doctorSection,
            section: PanelSection.PATIENT));
      } else {
        BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
            patientSection: patientSection,
            doctorSection: doctorSection,
            section: PanelSection.DOCTOR));
//        Navigator.of(context).pop();
        onPush(NavigatorRoutes.panel);
      }
    } else {
      BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
          patientSection: patientSection, doctorSection: doctorSection));
//      Navigator.of(context).pop();
      onPush(NavigatorRoutes.panel);
    }
  }

  Widget _subItem(context, {text, PanelSubItem item}) {
    String utfText;
    try {
      if (item != null)
        utfText = utf8.decode(item.text.toString().codeUnits);
      else
        utfText = text;
    } catch (_) {
      if (item != null)
        utfText = item.text;
      else
        utfText = text;
    }
    return GestureDetector(
        onTap: () {
          _selectItem(item: item, context: context);
        },
        child: Container(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AutoText(
                  utfText,
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

  Widget _icon() {
    if (icon != null)
      return Icon(
        icon,
        size: 30,
        color: color,
      );
    else if (asset != null)
      return CrossPlatformSvg.asset(
        asset,
        color: color,
        width: 30,
      );
  }

  Widget _label(context) => GestureDetector(
      onTap: () {
        _selectMenuItem(context: context, menuItem: doctorSection);
      },
      child: Container(
        margin: EdgeInsets.only(left: 10),
        child: AutoText(
          label,
          textAlign: TextAlign.right,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ));

  Widget _subLabel() => Container(
        margin: EdgeInsets.only(right: 10),
        child: AutoText(
          subLabel,
          textAlign: TextAlign.right,
          style: TextStyle(
              color: IColors.themeColor,
              fontSize: 12,
              fontWeight: FontWeight.w900),
        ),
      );

  Widget _requestsCountCircle() {
    return BlocBuilder<SearchBloc, SearchState>(builder: (context, state) {
      if (state is SearchLoaded ||
          state is SearchLoading ||
          state is SearchError)
        return Container(
            margin: EdgeInsets.only(right: 10, bottom: 15),
            child: Wrap(children: <Widget>[
              Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: AutoText(replaceFarsiNumber(state.count.toString()),
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  decoration: BoxDecoration(
                      color: IColors.themeColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                            color: IColors.themeColor,
                            offset: Offset(1, 3),
                            blurRadius: 10)
                      ])),
            ]));
      return Container();
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (!isActive) color = IColors.deactivePanelMenu;
      List<Widget> items = [];
      for (var item in subItems) {
        items.add(_subItem(context, item: item));
      }
      if (!isEmpty && items.length == 0)
        items.add(_subItem(context,
            text: (isPatient
                ? Strings.panelIDoctorEmptyLabel
                : Strings.panelIPatientEmptyLabel)));
      return WillPopScope(
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  (subLabel != null
                      ? _subLabel()
                      : SizedBox(
                          width: 5,
                        )),
                  (doctorSection == DoctorPanelSection.REQUESTS
                      ? _requestsCountCircle()
                      : Container()),
                  _label(context),
                  SizedBox(
                    width: 25,
                  ),
                  _icon()
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
    } catch (_) {
      return Container();
    }
  }
}
