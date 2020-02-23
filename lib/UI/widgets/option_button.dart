import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class OptionButton extends StatefulWidget {
  String title;
  String asset;
  Color color;

  OptionButton(String title, String asset, Color color) {
    this.title = title;
    this.asset = asset;
    this.color = color;
  }

  @override
  _OptionButtonState createState() {
    return _OptionButtonState(title, asset, color);
  }
}

class _OptionButtonState extends State<OptionButton> {
  bool _isSelected = false;
  String title;
  String asset;
  Color color;

  _OptionButtonState(String title, String asset, Color color) {
    this.title = title;
    this.asset = asset;
    this.color = color;
  }

  Color getCurrentColor() {
    return _isSelected ? color : Colors.grey;
  }

  void _switch() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  Widget radioButton(bool isSelected) => Container(
        width: 16,
        height: 16,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: getCurrentColor(), width: 2.0)),
        child: isSelected
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: getCurrentColor()),
              )
            : Container(),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: <Widget>[
        InkWell(
          child: DecoratedBox(
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: _isSelected
                    ? Border.all(width: 2.0, color: color)
                    : Border.all(width: 0.0),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(children: <Widget>[
                  Row(children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 13,
                          color: getCurrentColor(),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      child: radioButton(_isSelected),
                    ),
                  ]),
                  SvgPicture.asset(
                    asset,
                    color: getCurrentColor(),
                    width: 60,
                    height: 60,
                  ),
                ])),
          ),
          onTap: _switch,
        )
      ],
    ));
  }
}
