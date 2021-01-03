import 'dart:math';

import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/NoronioService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AutoText.dart';
import 'DocupHeader.dart';

class SquareBoxNoronioClinicService extends StatelessWidget {
  final NoronioServiceItem noronioService;
  double boxSize;
  double bFontSize;
  double lFontSize;
  final Color defaultBgColor;

  SquareBoxNoronioClinicService(this.noronioService,
      {Key key,
      this.boxSize,
      this.defaultBgColor,
      this.bFontSize,
      this.lFontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (noronioService.isEmpty) {
      bgColor = Color.fromARGB(0, 0, 0, 0);
    } else {
      bgColor = defaultBgColor ?? Color.fromRGBO(255, 255, 255, .8);
    }
    double opacity;
    if (noronioService.enable) {
      opacity = 1.0;
    } else {
      opacity = 0.5;
    }

    boxSize = boxSize == null
        ? MediaQuery.of(context).size.width * (40 / 100)
        : min(MediaQuery.of(context).size.width * (40 / 100), boxSize);
    return GestureDetector(
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: EdgeInsets.only(bottom: 30, left: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: bgColor),
                width: boxSize,
                height: boxSize,
                child: noronioService.iconAddress == null
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
                                      color: IColors.themeColor,
                                      fontSize: this.lFontSize ?? 10),
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
                              child: imageHandler()),
                          DocUpSubHeader(
                            title: noronioService.title,
                            textAlign: TextAlign.center,
                            fontSize: this.bFontSize,
                          ),
                        ],
                      ),
              ),
              noronioService.responseNormalTime != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: DocUpSubHeader(
                        title: noronioService.responseNormalTime,
                        textAlign: TextAlign.center,
                        fontSize: 12,
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
      onTap: noronioService.onTap != null ? noronioService.onTap : () {},
    );
  }

  Widget imageHandler() {
    Widget defaultImage() {
      return Image.asset(
        Assets.noronioServiceBrainTest,
        width: boxSize * (40 / 100),
        height: boxSize * (40 / 100),
      );
    }

    if (noronioService != null &&
        noronioService.iconURL != null &&
        noronioService.iconURL != "") {
      Widget image;
      try {
        image = Image.network(
          noronioService.iconURL,
          width: boxSize * (40 / 100),
          height: boxSize * (40 / 100),
          errorBuilder: (context, error, stackTrace) {
            return defaultImage();
          },
        );
      } catch (e) {
        image = defaultImage();
      }
      return image;
    }
    if (noronioService != null &&
        noronioService.iconAddress != null &&
        noronioService.iconAddress != "") {
      Widget image;
      try {
        image = Image.asset(
          noronioService.iconAddress,
          width: boxSize * (40 / 100),
          height: boxSize * (40 / 100),
          errorBuilder: (context, error, stackTrace) {
            return defaultImage();
          },
        );
      } catch (e) {
        image = defaultImage();
      }
      return image;
    }
    return defaultImage();
  }
}
