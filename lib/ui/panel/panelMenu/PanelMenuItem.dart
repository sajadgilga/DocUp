import 'dart:convert';

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
import 'package:docup/ui/panel/panelMenu/PatientPanelMenu.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/customPainter/DrawerPainter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PanelSubItem {
  String text;
  final String ID;
  final Color color;
  PanelTabState panelTabState;
  int panelId;

  PanelSubItem(this.text, this.ID, this.color, {this.panelTabState, this.panelId});
}

class PanelMenuMainItem extends StatelessWidget {
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

  PanelMenuMainItem(
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

  void _selectItem({item, context}) {
    if (isPatient && patientSection == PatientPanelSection.HEALTH_CALENDAR) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "منتظر ما باشید",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: Text("این امکان در نسخه‌های بعدی اضافه خواهد شد",
                  textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),
            );
          });
      return;
    }
    if (item.panelTabState != null)
      BlocProvider.of<TabSwitchBloc>(context).add(item.panelTabState);
    else
      BlocProvider.of<EntityBloc>(context)
          .add(PartnerEntitySet(id: int.parse(item.ID), panelId: item.panelId));
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
        Navigator.of(context).pop();
      }
    } else {
      BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
          patientSection: patientSection, doctorSection: doctorSection));
      Navigator.of(context).pop();
    }
  }

  Widget _subItem(context, {text, PanelSubItem item}) {
    String utfText;
    try {
      utfText = utf8.decode(item.text.toString().codeUnits);
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
                Text(
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
      return SvgPicture.asset(
        asset,
        color: color,
        width: 30,
      );
  }

  Widget _label() => Container(
        margin: EdgeInsets.only(left: 10),
        child: Text(
          label,
          textAlign: TextAlign.right,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.w900),
        ),
      );

  Widget _subLabel() => Container(
        margin: EdgeInsets.only(right: 10),
        child: Text(
          subLabel,
          textAlign: TextAlign.right,
          style: TextStyle(
              color: IColors.themeColor,
              fontSize: 12,
              fontWeight: FontWeight.w900),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (!isActive) color = IColors.deactivePanelMenu;
    List<Widget> items = [];
    for (var item in subItems) {
      items.add(_subItem(context, item: item));
    }
    if (!isEmpty && items.length == 0)
      items.add(_subItem(context, text: Strings.panelIDoctorEmptyLabel));
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
                _label(),
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
  }
}
