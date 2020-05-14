import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
 import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/videoCallPage/VideoCallPage.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/panel/chatPage/ChatPage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:docup/ui/panel/panelMenu/PanelMenu.dart';
import 'illnessPage/IllnessPage.dart';

enum PanelTabState { FirstTab, SecondTab, ThirdTab }

class Panel extends StatefulWidget {
  DoctorEntity doctor;
  final Function(String, UserEntity) onPush;
  PatientEntity patient;
  List<Widget> pages;

  Panel({Key key, this.patient, this.doctor, this.pages, @required this.onPush})
      : super(key: key);

  @override
  _PanelState createState() {
    return _PanelState(patient: patient);
  }
}

class _PanelState extends State<Panel> {
  PatientEntity patient;

  _PanelState({this.patient}) : super();

  Map<PanelTabState, Widget> children() => {
        PanelTabState.FirstTab: widget.pages[0],
        PanelTabState.SecondTab: widget.pages[1],
        PanelTabState.ThirdTab: widget.pages[2],
      };

  void _showPanelMenu() {
    widget.onPush(NavigatorRoutes.panelMenu, null);
  }

  void _showSearchPage() {
    widget.onPush(NavigatorRoutes.searchView, null);
  }

  Widget _header() => Header(
          child: Row(
        children: <Widget>[
//          GestureDetector(
//              onTap: () {
//                Navigator.of(context).maybePop();
////                _showPanelMenu();
//              },
//              child: Container(
//                padding: EdgeInsets.only(top: 15, left: 10, right: 10),
//                child:
//                SvgPicture.asset(
//                  Assets.panelListIcon,
//                  width: 35,
//                  color: IColors.themeColor,
//                )
////                Image(
////                  image: AssetImage(Assets.panelListIcon),
////                  height: 40,
////                  width: 40,
////                ),
//              )),
          Container(
            padding: EdgeInsets.only(top: 15, left: 15),
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
    return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
      builder: (context, state) {
        if (state.patientSection == PatientPanelSection.DOCTOR_INTERFACE)
          return Tabs(
              firstTab: Strings.panelIllnessInfoLabel,
              secondTab: Strings.panelChatLabel,
              thirdTab: Strings.panelVideoCallLabel);
        else if (state.patientSection == PatientPanelSection.HEALTH_FILE)
          return Tabs(
            firstTab: Strings.panelDocumentsPicLabel,
            secondTab: Strings.panelPrescriptionsPicLabel,
            thirdTab: Strings.panelTestResultsPicLabel,
          );
        return Tabs(firstTab: '', secondTab: '', thirdTab: '');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Column(
        children: <Widget>[
          _header(),
          _tabs(),
          BlocBuilder<TabSwitchBloc, PanelTabState>(
            builder: (context, state) =>
                Expanded(flex: 2, child: children()[state]),
          )
        ],
      ),
    );
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
  void _switchTab(PanelTabState state, context) {
    BlocProvider.of<TabSwitchBloc>(context).add(state);
  }

  Color _buttonBackground(bool isActive) {
    return isActive ? IColors.themeColor : Colors.white;
  }

  Color _buttonTextColor(bool isActive) {
    return isActive ? Colors.white : Colors.grey;
  }

  Widget _button({PanelTabState tabState, state, text, context}) {
    return RaisedButton(
      onPressed: () {
        _switchTab(tabState, context);
      },
      color: _buttonBackground(state == tabState),
      child: Container(
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width * .2),
          padding: EdgeInsets.only(top: 10, bottom: 10),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _buttonTextColor(state == tabState), fontSize: 12),
          )),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays ([SystemUiOverlay.bottom]);
    return BlocBuilder<TabSwitchBloc, PanelTabState>(builder: (context, state) {
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
                  _button(
                      tabState: PanelTabState.ThirdTab,
                      state: state,
                      text: widget.thirdTab,
                      context: context),
                  _button(
                      tabState: PanelTabState.SecondTab,
                      state: state,
                      text: widget.secondTab,
                      context: context),
                  _button(
                      tabState: PanelTabState.FirstTab,
                      state: state,
                      text: widget.firstTab,
                      context: context),
                ],
              )),
        ],
      );
    });
  }
}
