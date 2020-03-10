import 'dart:ui';

import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:dashed_container/dashed_container.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PicList extends StatefulWidget {
  @override
  _PicListState createState() => _PicListState();
}

class _PicListState extends State<PicList> {
  Widget _label() => Container(
        padding: EdgeInsets.only(bottom: 15),
        child: Text(
          Strings.illnessPicListLabel,
          style: TextStyle(
              color: IColors.red, fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
      );

  Widget _uploadBoxLabel() => Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset(
            "assets/cloud.svg",
            height: 35,
            width: 35,
            color: IColors.red,
          ),
          Text(
            Strings.illnessPicUploadLabel,
            style: TextStyle(
                fontSize: 8, color: IColors.red, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )
        ],
      ));

  Widget _uploadBox() => DashedContainer(
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
            Radius.circular(10),
          )),
          child: _uploadBoxLabel(),
        ),
        dashColor: IColors.red,
        borderRadius: 10.0,
        dashedLength: 10,
        blankLength: 10,
        strokeWidth: 2.5,
      );

  Widget _picListBox(width) {
    List<Widget> pictures = [];
    for (int i = 0; i < _calculatePossiblePicCount(width); i++) {
      pictures.add(Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage('assets/hand1.jpg')),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            color: Colors.white.withOpacity(.4),
          ),
        ),
      ));
    }
    return Container(
      margin: EdgeInsets.only(right: 15, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: pictures,
      ),
    );
  }

  int _calculatePossiblePicCount(width) {
    return ((width - 190) / 110).toInt();
  }

  Widget _picListHeader() => Container(
        margin: EdgeInsets.only(right: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                Strings.illnessPicShowLabel,
                style: TextStyle(
                    color: IColors.red,
                    fontSize: 8,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    Strings.illnessLastPicsLabel,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 8,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 8,
                    height: 5,
                    child: Divider(
                      thickness: 2,
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );

  Widget _picList(width) => Expanded(
        flex: 2,
        child: Container(
          child: Column(
            children: <Widget>[_picListHeader(), _picListBox(width)],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 50,
          maxWidth: MediaQuery.of(context).size.width - 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _label(),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _picList(MediaQuery.of(context).size.width),
                _uploadBox(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
