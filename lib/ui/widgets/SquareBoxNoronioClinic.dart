import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AutoText.dart';
import 'DocupHeader.dart';

class SquareBoxNoronioClinicService extends StatelessWidget {
  final String iconAsset;
  final Function() onTap;
  final String titleText;
  final Color bgColor;
  final double opacity;

  SquareBoxNoronioClinicService(this.iconAsset, this.onTap, this.titleText,
      {Key key,
      this.bgColor = const Color.fromRGBO(255, 255, 255, .8),
      this.opacity = 1.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double boxSize = MediaQuery.of(context).size.width * (40 / 100);
    return GestureDetector(
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: EdgeInsets.only(bottom: 30, left: 10, right: 10),
          padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: bgColor),
          width: boxSize,
          height: boxSize,
          child: iconAsset == null
              ? SizedBox()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      width: boxSize,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          AutoText(
                            'نورونیو',
                            style: TextStyle(
                                color: IColors.themeColor, fontSize: 10),
                          ),
                          Icon(
                            Icons.add_location,
                            color: IColors.themeColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    Container(
                        width: boxSize * (40 / 100),
                        child: Image.asset(iconAsset)),
                    DocUpSubHeader(
                      title: titleText,
                    )
                  ],
                ),
        ),
      ),
      onTap: onTap != null ? onTap : () {},
    );
  }
}
