import 'dart:async';

import 'package:docup/models/UserEntity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import '../../constants/strings.dart';
import '../../constants/colors.dart';

class SearchBox extends StatefulWidget {
  Function(String, UserEntity) onPush;
  bool isPatient;
  final Function() onTap;
  final bool enableFlag;
  final Function(String c) onSubmit;
  final Function(String c) onChange;

  SearchBox(
      {this.onPush,
      @required this.isPatient = true,
      this.onTap,
      this.onSubmit,
      this.onChange,
      this.enableFlag = true});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchBoxState();
  }
}

class _SearchBoxState extends State<SearchBox> {
  String searchTag;
  TextEditingController _controller;
  bool _tooltip = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    searchTag = (widget.isPatient ? 'تخصص' : 'درحال درمان');
    _setToolTip();
    super.initState();
  }

  void _setToolTip() async {
    var _prefs = await SharedPreferences.getInstance();
    if (!_prefs.containsKey('tooltip_shown')) {
      _tooltip = widget.isPatient;
      Timer(Duration(seconds: 10), () {
        setState(() {
          _tooltip = false;
        });
      });
      _prefs.setBool("tooltip_shown", true);
    }
  }

  double _getSearchBoxWidth(width) {
    return (width > 550
        ? width * .65
        : (width > 400 ? width * .60 : width * .55));
  }

  void _changeTag() {}

  void _showTags() {}

  Widget _filterText() {
    return Text(searchTag,
        style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: IColors.themeColor));
  }

  @override
  Widget build(BuildContext context) {
//    FocusScope.of(context).unfocus();
    return widget.enableFlag
        ? _simpleTooltip()
        : GestureDetector(onTap: widget.onTap, child: _simpleTooltip());
  }

  Widget _simpleTooltip() {
    return SimpleTooltip(
      hideOnTooltipTap: true,
      show: _tooltip,
      tooltipDirection: TooltipDirection.down,
      backgroundColor: IColors.whiteTransparent,
      borderColor: IColors.themeColor,
      content: Text(
        Strings.PatientSearchBoxTooltip,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 12,
          decoration: TextDecoration.none,
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * .8,
        height: 50,
        padding: EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: MediaQuery.of(context).size.width * .07,
            right: MediaQuery.of(context).size.width * .04),
        decoration: BoxDecoration(
            color: Color.fromRGBO(247, 247, 247, .9),
            borderRadius: BorderRadius.all(Radius.circular(50))),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.search,
                size: 25,
              ),
              Container(
                  width: _getSearchBoxWidth(MediaQuery.of(context).size.width),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(left: 5, right: 15),
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.end,
                    enabled: widget.enableFlag,
                    textDirection: TextDirection.ltr,
                    onSubmitted: widget.onSubmit,
                    onChanged: widget.onChange,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: (widget.isPatient
                            ? Strings.PatientSearchBoxHint
                            : Strings.DoctorSearchBoxHint),
                        focusColor: IColors.themeColor,
                        fillColor: IColors.themeColor),
                  )),
              GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: <Widget>[
//                          _filterText(),
                      Container(
                        child: Icon(
                          Icons.filter_list,
                          size: 20,
                        ),
                        margin: EdgeInsets.only(left: 5),
                      ),
                    ],
                  ))
            ]),
//      ),child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          TextField(
//            textAlign: TextAlign.end,
//            textDirection: TextDirection.rtl,
//            decoration: InputDecoration(
//                hintText: Strings.searchBoxHint, icon: Icon(Icons.search)),
//          ),
//          Icon(Icons.filter_list)
//        ],
//      ),
      ),
    );
  }
}
