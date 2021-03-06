import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AutoText.dart';

class NeuronioHeader extends StatelessWidget {
  final String title;
  final bool docUpLogo;
  final Color color;
  final double width;

  NeuronioHeader(
      {Key key,
      this.title,
      this.docUpLogo = false,
      this.color,
      this.width = 40})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10, right: 20),
          child: docUpLogo
              ? Container(
                  width: width, child: Image.asset(Assets.logoTransparent))
              : SizedBox(),
          alignment: Alignment.centerRight,
        ),
        _headerWidget()
      ],
    );
  }

  _headerWidget() => Visibility(
        visible: title != null,
        child: Center(
            child: AutoText(title == null ? "" : title,
                style: TextStyle(
                    color: this.color ?? IColors.themeColor, fontSize: 24))),
      );
}

class DocUpSubHeader extends StatelessWidget {
  final String title;
  final Color color;
  final double fontSize;
  final TextAlign textAlign;

  DocUpSubHeader(
      {Key key,
      this.title,
      this.color,
      this.fontSize,
      this.textAlign = TextAlign.right})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_headerWidget()],
    );
  }

  _headerWidget() => Visibility(
        visible: title != null,
        child: Center(
            child: AutoText(
          title == null ? "" : title,
          style: TextStyle(
              fontSize: fontSize ?? 14, color: color ?? IColors.black),
          textAlign: TextAlign.center,
        )),
      );
}

Widget menuLabel(title, {double fontSize = 14, bool divider = true}) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        AutoText(
          (title),
          style: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: fontSize,
              color: IColors.darkGrey),
        ),
        Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(right: 5),
            width: 20,
            height: 20,
            child: divider
                ? Divider(
                    thickness: 2,
                    color: IColors.darkGrey,
                  )
                : SizedBox()),
      ],
    );
