import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/customPainter/DrawerPainter.dart';

class PanelMenu extends StatelessWidget {
  final VoidCallback onPop;

  PanelMenu(this.onPop);

  Widget _header() => Header(
          child: Row(
        children: <Widget>[
          GestureDetector(
              onTap: () {_popMenu();},
              child: Container(
                padding: EdgeInsets.only(top: 15, left: 10, right: 10),
                child: Image(
                  image: AssetImage('assets/panelList.png'),
                  height: 40,
                  width: 40,
                ),
              )),
          Container(
            padding: EdgeInsets.only(top: 15, left: 10),
            child: GestureDetector(
              onTap: () {_popMenu();},
              child: Icon(
                Icons.search,
                size: 30,
              ),
            ),
          )
        ],
      ));

  Widget _menu(height) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[_menuLabel(), _menuList(height)],
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

  Widget _menuList(height) => Container(
      constraints: BoxConstraints(maxHeight: height - 250),
      child: ListView(
        children: <Widget>[
          _PanelMenuMainItem(
            subItems: [
              PanelSubItem('دکتر زهرا شادلو', 'doctor_1'),
            ],
            label: Strings.panelIDoctorLabel,
            icon: Icons.person,
            color: IColors.themeColor,
          ),
          _PanelMenuMainItem(
              subItems: [
                PanelSubItem(Strings.panelDocumentSubLabel, 'documents'),
                PanelSubItem(Strings.panelResultsSubLabel, 'results'),
                PanelSubItem(Strings.panelMedicinesSubLabel, 'medicines'),
                PanelSubItem(Strings.panelPicturesSubLabel, 'pictures'),
              ],
              label: Strings.panelHealthFileLabel,
              icon: Icons.insert_drive_file),
          _PanelMenuMainItem(
              subItems: [
                PanelSubItem(Strings.panelReminderSubLabel, 'reminders'),
                PanelSubItem(Strings.panelVisitsSubLabel, 'visits'),
              ],
              label: Strings.panelHealthScheduleLabel,
              icon: Icons.calendar_today)
        ],
      )
//        Column(
//          crossAxisAlignment: CrossAxisAlignment.end,
//          children: <Widget>[
//            _PanelMenuMainItem(
//              subItems: [
//                PanelSubItem('دکتر زهرا شادلو', 'doctor_1'),
//              ],
//              label: Strings.panelIDoctorLabel,
//              icon: Icons.person,
//              color: IColors.red,
//            ),
//            _PanelMenuMainItem(
//                subItems: [
//                  PanelSubItem(Strings.panelDocumentSubLabel, 'documents'),
//                  PanelSubItem(Strings.panelResultsSubLabel, 'results'),
//                  PanelSubItem(Strings.panelMedicinesSubLabel, 'medicines'),
//                  PanelSubItem(Strings.panelPicturesSubLabel, 'pictures'),
//                ],
//                label: Strings.panelHealthFileLabel,
//                icon: Icons.insert_drive_file),
//            _PanelMenuMainItem(
//                subItems: [
//                  PanelSubItem(Strings.panelReminderSubLabel, 'reminders'),
//                  PanelSubItem(Strings.panelVisitsSubLabel, 'visits'),
//                ],
//                label: Strings.panelHealthScheduleLabel,
//                icon: Icons.calendar_today)
//          ],
//        ),
      );

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
                child: _menu(MediaQuery.of(context).size.height)),
          ),
          GestureDetector(
              onTap: () {
                _popMenu();
              },
              child: Container(
                  constraints: BoxConstraints(maxHeight: 100),
                  alignment: Alignment.topCenter,
                  child: _header())),
        ],
      ),
    );
  }

  void _popMenu() {
    onPop();
  }
}

class PanelSubItem {
  final String text;
  final String ID;

  PanelSubItem(this.text, this.ID);
}

class _PanelMenuMainItem extends StatelessWidget {
  final List<PanelSubItem> subItems;
  final String label;
  final IconData icon;
  Color color;
  bool isActive = false;

  _PanelMenuMainItem(
      {Key key,
      this.subItems,
      this.label,
      this.icon,
        this.isActive = false,
      this.color = IColors.activePanelMenu})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isActive)
      color = IColors.deactivePanelMenu;
    List<Widget> items = [];
    for (var item in subItems) {
      items.add(Container(
          padding: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                item.text,
                style: TextStyle(fontSize: 12, color: color),
                textAlign: TextAlign.right,
              ),
              Container(
                margin: EdgeInsets.only(left: 20),
                width: 5,
                height: 5,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              )
            ],
          )));
    }
    return WillPopScope(
        child: Container(
          margin: EdgeInsets.only(bottom: 15),
          child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
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
          Navigator.of(context).pop();
          return false;
        });
  }
}
