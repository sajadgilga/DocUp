import 'dart:async';

import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/PopupMenues/PopUpMenus.dart';
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
  TextEditingController controller;
  final Rect popMenuRect;
  final List<String> popUpMenuItems;
  int selectedIndex;
  final Function(MenuItemProvider) onMenuClick;
  final bool filterPopup;
  final String hintText;

  SearchBox(
      {this.onPush,
      @required this.isPatient = true,
      this.onTap,
      this.onSubmit,
      this.onChange,
      this.controller,
      this.popMenuRect,
      this.popUpMenuItems,
      this.selectedIndex,
      this.onMenuClick,
      this.hintText,
      this.filterPopup = true,
      this.enableFlag = true}) {
    if (controller == null) {
      controller = TextEditingController();
    }
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchBoxState();
  }
}

class _SearchBoxState extends State<SearchBox> {
  String searchTag;
  bool _tooltip = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    widget.controller?.dispose();
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
        ? width * .60
        : (width > 400 ? width * .60 : width * .55));
  }

  void _changeTag() {}

  void _showTags() {}

  Widget _filterText() {
    return AutoText(searchTag,
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

  /// TODO amir: cleaning hintText for all pages

  Widget _simpleTooltip() {
    return SimpleTooltip(
      hideOnTooltipTap: true,
      show: _tooltip,
      tooltipDirection: TooltipDirection.down,
      backgroundColor: IColors.whiteTransparent,
      borderColor: IColors.themeColor,
      content:AutoText(
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
              Expanded(
                  // width: _getSearchBoxWidth(MediaQuery.of(context).size.width),
                  // alignment: Alignment.centerRight,
                  // padding: EdgeInsets.only(left: 5, right: 15),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5,right: 5),
                    child: TextField(
                      controller: widget.controller,
                      textAlign: TextAlign.end,
                      enabled: widget.enableFlag,
                      textDirection: TextDirection.ltr,
                      onSubmitted: widget.onSubmit,
                      onChanged: widget.onChange,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: widget.hintText ??
                              (widget.isPatient
                                  ? Strings.PatientSearchBoxHint
                                  : Strings.DoctorSearchBoxHint),
                          focusColor: IColors.themeColor,
                          fillColor: IColors.themeColor),
                    ),
                  )),
              widget.filterPopup
                  ? GestureDetector(
                      onTap: widget.enableFlag ? _showPopUpMenu : widget.onTap,
                      child: Container(
                        width: 25,
                        height: 25,
                        child: Icon(
                          Icons.filter_list,
                          size: 25,
                        ),
                        margin: EdgeInsets.only(left: 5),
                      ))
                  : SizedBox(),
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

  void _showPopUpMenu() {
    double itemHeight = 35;
    double itemWidth = 125;
    Widget getText(String title, {bool selected = false}) {
      return Container(
        alignment: Alignment.center,
        width: itemWidth,
        height: itemHeight,
        child: Container(
          alignment: Alignment.center,
          height: itemHeight * (70 / 100),
          width: itemWidth * (85 / 100),
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color:
                  selected ? IColors.themeColor : Color.fromARGB(0, 0, 0, 0)),
          child:AutoText(
            title,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white : IColors.darkGrey),
          ),
        ),
      );
    }

    List<MenuItem> items = [];
    if (widget.popUpMenuItems != null) {
      for (int i = 0; i < widget.popUpMenuItems.length; i++) {
        items.add(MenuItem(
            child: getText(widget.popUpMenuItems[i],
                selected: i == widget.selectedIndex),
            title: widget.popUpMenuItems[i]));
      }
    }

    PopupMenu menu = PopupMenu(
        items: items,
        context: context,
        maxColumn: 1,
        backgroundColor: Colors.white,
        onClickMenu: (c) {
          widget.selectedIndex = -1;
          for (int i = 0; i < widget.popUpMenuItems.length; i++) {
            if (c.menuTitle == widget.popUpMenuItems[i]) {
              setState(() {
                widget.selectedIndex = i;
              });
              break;
            }
          }
          if (widget.onMenuClick != null) {
            widget.onMenuClick(c);
          }
        },
        stateChanged: (c) {},
        itemHeight: itemHeight,
        itemWidth: itemWidth,
        arrowHeight: 0,
        highlightColor: Colors.red,
        lineColor: Colors.white,
        onDismiss: () {});

    menu.show(rect: widget.popMenuRect);
  }
}
