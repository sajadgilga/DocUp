import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ActionButton.dart';

class WholeIntoChild1 extends StatelessWidget {
  final String header = "داکآپ، پل ارتباطی پزشک و بیمار";
  final String subHeader =
      "رزرو نوبت، گفتگو با پزشکان متخصص و پیگیر آنلاین روند درمان";
  final String imageAddress = Assets.introPage1;
  final Color bgColor = Color.fromARGB(255, 245, 245, 245);

  @override
  Widget build(BuildContext context) {
    double x = MediaQuery.of(context).size.width;
    double y = MediaQuery.of(context).size.height;
    return Container(
      width: x,
      height: y,
      color: bgColor,
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          _buildImage(imageAddress, 1.8,
              EdgeInsets.only(top: y * (260 / 640), right: x * (15 / 100))),
          getIntro(
              padding: EdgeInsets.only(top: y * (102 / 640)),
              height: y * (155 / 640),
              width: x * (286 / 360),
              headerFontSize: 22,
              subHeaderFontSize: 17,
              header: header,
              subHeader: subHeader,
              headerColor: IColors.black,
              subHeaderColor: IColors.black),
        ],
      ),
    );
  }
}

class WholeIntoChild2 extends StatelessWidget {
  final String header = "مطب مجازی";
  final String subHeader =
      "تسهیل روند تشخیص و درمان با کمک تست‌های آنلاین و هوش مصنوعی";
  final String imageAddress = Assets.introPage2;
  final Color bgColor = Color.fromARGB(255, 125, 174, 164);

  @override
  Widget build(BuildContext context) {
    double x = MediaQuery.of(context).size.width;
    double y = MediaQuery.of(context).size.height;
    return Container(
      width: x,
      height: y,
      color: bgColor,
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          _buildImage(imageAddress, 1.5,
              EdgeInsets.only(top: y * (44 / 640), left: x * (10 / 100))),
          getIntro(
              padding: EdgeInsets.only(top: y * (454 / 640)),
              height: y * (115 / 640),
              width: x * (305 / 360),
              headerFontSize: 22,
              subHeaderFontSize: 17,
              header: header,
              subHeader: subHeader,
              headerColor: IColors.whiteTransparent,
              subHeaderColor: IColors.whiteTransparent),
        ],
      ),
    );
  }
}

class WholeIntoChild3 extends StatelessWidget {
  final String header = "تقویم سلامت";
  final String subHeader =
      "ایجاد رویداد سلامت، یادآوری داروها و نوبت‌های ویزیت";
  final String imageAddress = Assets.introPage3;
  final Color bgColor = Color.fromARGB(255, 105, 129, 168);
  final Function() onDone;

  WholeIntoChild3({Key key, this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double x = MediaQuery.of(context).size.width;
    double y = MediaQuery.of(context).size.height;
    return Container(
      width: x,
      height: y,
      color: bgColor,
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          _buildImage(imageAddress, 1.4,
              EdgeInsets.only(top: y * (246 / 640), right: x * (10 / 100))),
          getIntro(
              padding: EdgeInsets.only(top: y * (101 / 640)),
              height: y * (115 / 640),
              width: x * (305 / 360),
              headerFontSize: 22,
              subHeaderFontSize: 17,
              header: header,
              subHeader: subHeader,
              headerColor: IColors.whiteTransparent,
              subHeaderColor: IColors.whiteTransparent),
          _loginOrRegister(x * (286 / 360), y * (49 / 640),
              EdgeInsets.only(top: y * (521 / 640)))
        ],
      ),
    );
  }

  Widget _loginOrRegister(
      double width, double height, EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: ActionButton(
        width: width,
        callBack: onDone,
        extraLeftIcon: Icon(
          Icons.arrow_back_ios,
          color: bgColor,
        ),
        height: height,
        title: "ورود یا ثبت نام",
        borderRadius: 25,
        textColor: bgColor,
        color: Colors.white,
      ),
    );
  }
}

Widget getIntro(
    {padding,
    double height,
    double width,
    double headerFontSize,
    double subHeaderFontSize,
    String header,
    String subHeader,
    Color headerColor,
    Color subHeaderColor}) {
  return Padding(
    padding: padding,
    child: Container(
      height: height,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              header,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: headerFontSize, color: headerColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              subHeader,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.fade,
              style:
                  TextStyle(fontSize: subHeaderFontSize, color: subHeaderColor),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildImage(
    String assetAddress, double scale, EdgeInsetsGeometry padding) {
  return Padding(
    padding: padding,
    child: Transform.scale(
      scale: scale,
      alignment: Alignment.topCenter,
      child: Container(
        alignment: Alignment.topCenter,
        child: Image.asset(
          assetAddress,
        ),
      ),
    ),
  );
}
