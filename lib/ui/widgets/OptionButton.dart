import 'dart:async';

import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/ui/start/RoleType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'AutoText.dart';

// ignore: must_be_immutable
class OptionButton extends StatefulWidget {
  final Stream<RoleType> stream;
  RoleType roleType;

  OptionButton(RoleType roleType, {this.stream}) {
    this.roleType = roleType;
  }

  @override
  _OptionButtonState createState() {
    return _OptionButtonState(roleType);
  }
}

class _OptionButtonState extends State<OptionButton> {
  bool _isSelected = false;
  RoleType roleType;

  _OptionButtonState(RoleType roleType) {
    this.roleType = roleType;
  }

  Color getCurrentColor() => _isSelected ? IColors.themeColor : Colors.grey;

  Widget radioButton() => Container(
        width: 16,
        height: 16,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: getCurrentColor(), width: 2.0)),
        child: _isSelected
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: getCurrentColor()),
              )
            : Container(),
      );
  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.stream.listen((selectedRoleType) {
      setState(() {
        _isSelected = selectedRoleType == roleType;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 110,
        height: 110,
        child: Stack(
          children: <Widget>[
            InkWell(
              child: DecoratedBox(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: _isSelected
                        ? Border.all(width: 2.0, color: IColors.themeColor)
                        : Border.all(width: 0.0),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AutoText(
                              roleType.name,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: getCurrentColor(),
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10),
                            radioButton(),
                          ]),
                      Container(
                        padding: EdgeInsets.all(5),
                        width: 60,
                        height: 60,
                        child: SvgPicture.asset(
                          roleType.asset,
                          color: getCurrentColor(),
                        ),
                      )
                    ])),
              ),
            )
          ],
        ));
  }
}
