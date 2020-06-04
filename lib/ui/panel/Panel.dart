import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:docup/ui/panel/panelMenu/PanelMenu.dart';

class Panel extends StatefulWidget {
  DoctorEntity doctor;
  final Function(String, UserEntity) onPush;
  PatientEntity patient;
  List<List<Widget>> pages;

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

  @override
  initState() {
    BlocProvider.of<TabSwitchBloc>(context).listen((data) {
      setState(() {

      });
    });
    super.initState();
  }

  Widget children(PanelTabState state) {
    List<Widget> _widget;
    if (state is FirstTab) _widget = widget.pages[0];
    else if (state is SecondTab) _widget = widget.pages[1];
    else if (state is ThirdTab) _widget = widget.pages[2];
    else return Container();
    if (_widget == null || _widget.length == 0)
      return Center(
        child: Text('مشکل در بارگزاری صفحه'),
      );
    return _widget[(_widget.length > state.index ? state.index : 0)];
  }

  void _showSearchPage() {
    widget.onPush(NavigatorRoutes.searchView, null);
  }

  Widget _header() => Header(
          child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 15),
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
    var _entity = BlocProvider.of<EntityBloc>(context).state.entity;
    return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
      builder: (context, state) {
        if (state.patientSection == PatientPanelSection.DOCTOR_INTERFACE)
          return Tabs(
              firstTab: tabs['info'],
              secondTab: tabs['chat'],
              thirdTab: tabs['call']);
        else if (state.patientSection == PatientPanelSection.HEALTH_FILE)
          return Tabs(
            firstTab: tabs['documents'],
            secondTab: tabs['medicines'],
            thirdTab: tabs['results'],
          );
        return Tabs(
            firstTab: tabs['calendar'],
            secondTab: tabs['events'],
            thirdTab: tabs['reminders']);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            child: Column(children: <Widget>[
              _header(),
              SizedBox(
                height: 40,
              ),
              BlocBuilder<TabSwitchBloc, PanelTabState>(
                builder: (context, state) =>
                    Expanded(flex: 2, child: children(state)),
//                Expanded(flex: 2, child: children()[state]),
              ),
            ])),
        Container(
          margin: EdgeInsets.only(top: 80),
          child: Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 70),
          child: _tabs(),
        )
      ],
    );
  }
}

class Tab extends StatefulWidget {
  final String text;
  final Color color;
  final Color backgroundColor;
  final bool hasSublist;
  final List<String> elements;
  final PanelTabState tabState;
  final bool isOn;

  Tab(
      {Key key,
      this.text,
      this.color,
      this.backgroundColor,
      this.tabState,
      this.hasSublist = false,
      this.isOn = false,
      this.elements})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TabState();
  }
}

class TabState extends State<Tab> {
  int _index;
  bool _isDropped = false;

  @override
  void initState() {
    _index = 1;
    _isDropped = false;
    super.initState();
  }

  @override
  didUpdateWidget(old) {
    if (!widget.isOn) _isDropped = false;
  }

  bool _hasSubTab() {
    return widget.tabState.subtabs != null &&
        widget.tabState.subtabs.length != 0;
  }

  void _switchTab(PanelTabState state, context) {
    if (_hasSubTab()) {
      setState(() {
        _isDropped = !_isDropped;
      });
    }
    if (!widget.isOn) BlocProvider.of<TabSwitchBloc>(context).add(state);
  }

  void _switchSubTab(idx) {
    widget.tabState.index = idx;
    BlocProvider.of<TabSwitchBloc>(context).add(widget.tabState);
    setState(() {
      _isDropped = false;
    });
  }

  Widget _icon(subTab, idx) {
    return GestureDetector(
      onTap: () {
        _switchSubTab(idx);
      },
      child: Icon(
        subTab.widget,
        size: 40,
        color:
            (widget.tabState.index == idx ? IColors.themeColor : Colors.grey),
      ),
    );
  }

  Widget _dropDown() {
    if (!_hasSubTab() || !_isDropped) return Container();
    List<Widget> _widgets = [];
    for (int i = 0; i < widget.tabState.subtabs.length; i++) {
      var s = widget.tabState.subtabs[i];
      _widgets.add((s.widget == null ? Container() : _icon(s, i)));
      if (i < widget.tabState.subtabs.length - 1)
        _widgets.add(Container(
            child: Divider(
          height: 25,
          indent: 3,
          thickness: 2,
          color: Colors.grey,
        )));
    }
    return Container(
      padding: EdgeInsets.only(top: 25),
      constraints: BoxConstraints.expand(width: 120, height: 100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _widgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      _dropDown(),
      GestureDetector(
        onTap: () {
          _switchTab(widget.tabState, context);
        },
        child: Container(
            constraints: BoxConstraints.expand(width: 120, height: 35),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: widget.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                (widget.tabState.subtabs.length > 0
                    ? Icon(
                        (_isDropped
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down),
                        color: widget.color,
                      )
                    : Container()),
                Text(
                  widget.tabState.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: widget.color, fontSize: 10),
                )
              ],
            )),
      )
    ]);
  }
}

class Tabs extends StatefulWidget {
  PanelTabState firstTab;
  PanelTabState secondTab;
  PanelTabState thirdTab;

  Tabs({Key key, this.firstTab, this.secondTab, this.thirdTab})
      : super(key: key);

  @override
  TabsState createState() {
    return TabsState();
  }
}

class TabsState extends State<Tabs> {
  Color _buttonBackground(bool isActive) {
    return isActive ? IColors.themeColor : Colors.white;
  }

  Color _buttonTextColor(bool isActive) {
    return isActive ? Colors.white : Colors.grey;
  }

  void _switchTab(PanelTabState state, context) {
    BlocProvider.of<TabSwitchBloc>(context).add(state);
  }

  Widget _button({PanelTabState tabState, state, text, context}) {
    return RaisedButton(
      onPressed: () {
        _switchTab(tabState, context);
      },
      color: _buttonBackground(state == tabState),
      child: Container(
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width * .15),
          padding: EdgeInsets.only(top: 10, bottom: 10),
          alignment: Alignment.center,
          child: Row(
            children: <Widget>[
              (tabState.subtabs.length > 0
                  ? Icon(Icons.arrow_drop_down)
                  : Container()),
              Text(
                tabState.text,
//            text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _buttonTextColor(state == tabState), fontSize: 10),
              )
            ],
          )),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return BlocBuilder<TabSwitchBloc, PanelTabState>(builder: (context, state) {
      return
//        Stack(
//        children: <Widget>[
//          Container(
//            padding: EdgeInsets.only(top: 15),
//            alignment: Alignment.bottomCenter,
//            child: Divider(
//              thickness: 1,
//              color: Colors.grey,
//            ),
//          ),
          Container(
              padding: EdgeInsets.only(right: 20, left: 20),
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Tab(
                      isOn: state.isSame(widget.thirdTab),
                      tabState: widget.thirdTab,
                      backgroundColor:
                          _buttonBackground(state.isSame(widget.thirdTab)),
                      color: _buttonTextColor(state.isSame(widget.thirdTab))),
                  Tab(
                      isOn: state.isSame(widget.secondTab),
                      tabState: widget.secondTab,
                      backgroundColor:
                          _buttonBackground(state.isSame(widget.secondTab)),
                      color: _buttonTextColor(state.isSame(widget.secondTab))),
                  Tab(
                      isOn: state.isSame(widget.firstTab),
                      tabState: widget.firstTab,
                      backgroundColor:
                          _buttonBackground(state.isSame(widget.firstTab)),
                      color: _buttonTextColor(state.isSame(widget.firstTab))),
//                  _button(
//                      tabState: widget.secondTab,
//                      state: state,
//                      context: context),
//                  _button(
//                      tabState: widget.firstTab,
//                      state: state,
//                      context: context),
                ],
              ));
//        ],
//      );
    });
  }
}
