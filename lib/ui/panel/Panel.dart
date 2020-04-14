import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/models/Patient.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/videoCallPage/VideoCallPage.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/panel/chatPage/ChatPage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'PanelMenu.dart';
import 'illnessPage/IllnessPage.dart';

enum PanelStates { FirstTab, SecondTab, ThirdTab }

class Panel extends StatefulWidget {
  final Doctor doctor;
  final ValueChanged<String> onPush;
  Patient patient;
  List<Widget> pages;

  Panel({Key key, this.patient, this.doctor, this.pages, @required this.onPush})
      : super(key: key);

  @override
  PanelState createState() {
    return PanelState(patient: patient);
  }
}

class PanelState extends State<Panel> {
  Patient patient;

  PanelState({this.patient}) : super();

  Map<PanelStates, Widget> children() => {
        PanelStates.FirstTab: widget.pages[0],
        PanelStates.SecondTab: widget.pages[1],
        PanelStates.ThirdTab: widget.pages[2],
      };

  void _showPanelMenu() {
    widget.onPush(NavigatorRoutes.panelMenu);
  }

  void _showSearchPage() {
    widget.onPush(NavigatorRoutes.searchView);
  }

  Widget _header() => Header(
          child: Row(
        children: <Widget>[
          GestureDetector(
              onTap: () {
                _showPanelMenu();
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
            padding: EdgeInsets.only(top: 15, left: 5),
            child: GestureDetector(
              onTap: () {
                _showSearchPage();
              },
              child: SvgPicture.asset(
                Assets.searchIcon,
                width: 30,
              ),
            ),
          )
        ],
      ));

  Widget _tabs() {
    return Tabs(
        firstTab: 'اطلاعات بیماری',
        secondTab: 'چت با پزشک',
        thirdTab: 'تماس تصویری');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TabSwitchBloc>(
        create: (context) => TabSwitchBloc(),
        child: Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Column(
            children: <Widget>[
              _header(),
              _tabs(),
              BlocBuilder<TabSwitchBloc, PanelStates>(
                builder: (context, state) =>
                    Expanded(flex: 2, child: children()[state]),
              )
            ],
          ),
        ));
  }
}

class Tabs extends StatefulWidget {
  String firstTab;
  String secondTab;
  String thirdTab;

  Tabs({Key key, this.firstTab, this.secondTab, this.thirdTab})
      : super(key: key);

  @override
  TabsState createState() {
    return TabsState();
  }
}

class TabsState extends State<Tabs> {
  PanelStates _state = PanelStates.SecondTab;

  void _switchTab(PanelStates state, context) {
    BlocProvider.of<TabSwitchBloc>(context).add(state);
    if (_state != state)
      setState(() {
        _state = state;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 15),
          alignment: Alignment.bottomCenter,
          child: Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ),
        Container(
            padding: EdgeInsets.only(right: 20, left: 20),
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    _switchTab(PanelStates.ThirdTab, context);
                  },
                  color: (_state == PanelStates.ThirdTab
                      ? IColors.themeColor
                      : Colors.white),
                  child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      alignment: Alignment.center,
                      child: Text(
                        widget.thirdTab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: (_state == PanelStates.ThirdTab
                                ? Colors.white
                                : Colors.grey),
                            fontSize: 12),
                      )),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 5,
                ),
                RaisedButton(
                  onPressed: () {
                    _switchTab(PanelStates.SecondTab, context);
                  },
                  color: (_state == PanelStates.SecondTab
                      ? IColors.themeColor
                      : Colors.white),
                  child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        widget.secondTab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: (_state == PanelStates.SecondTab
                                ? Colors.white
                                : Colors.grey),
                            fontSize: 12),
                      )),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 5,
                ),
                RaisedButton(
                  onPressed: () {
                    _switchTab(PanelStates.FirstTab, context);
                  },
                  color: (_state == PanelStates.FirstTab
                      ? IColors.themeColor
                      : Colors.white),
                  child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        widget.firstTab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: (_state == PanelStates.FirstTab
                                ? Colors.white
                                : Colors.grey),
                            fontSize: 12),
                      )),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 5,
                ),
              ],
            )),
      ],
    );
  }
}
