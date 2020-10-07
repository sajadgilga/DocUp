import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DocUpHeader extends StatelessWidget {
  final String title;
  final bool docUpLogo;

  DocUpHeader({Key key, this.title, this.docUpLogo = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10, right: 20),
          child: docUpLogo
              ? Container(width: 40, child: Image.asset(Assets.logoTransparent))
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
            child: Text(title == null ? "" : title,
                style: TextStyle(color: IColors.themeColor, fontSize: 24))),
      );
}

class DocUpSubHeader extends StatelessWidget {
  final String title;

  DocUpSubHeader({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_headerWidget()],
    );
  }

  _headerWidget() => Visibility(
        visible: title != null,
        child: Center(
            child: Text(title == null ? "" : title,
                style: TextStyle(fontSize: 14))),
      );
}

Widget menuLabel(title, {double fontSize = 14, bool divider = true}) => Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
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
