import 'dart:math';

import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/NoronioService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AutoText.dart';
import 'DocupHeader.dart';

class SquareBoxNeuronioClinicService extends StatelessWidget {
  final NeuronioServiceItem neuronioService;
  double boxSize;
  double bFontSize;
  double lFontSize;
  final Color defaultBgColor;
  bool showServiceTitle;
  bool showLocation;
  bool showDoneIcon;
  Widget doneIcon;

  SquareBoxNeuronioClinicService(this.neuronioService,
      {Key key,
      this.boxSize,
      this.defaultBgColor,
      this.bFontSize,
      this.showServiceTitle = true,
      this.showLocation = true,
      this.showDoneIcon = false,
      this.doneIcon,
      this.lFontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (neuronioService.isEmpty) {
      bgColor = Color.fromARGB(0, 0, 0, 0);
    } else {
      bgColor = defaultBgColor ?? Color.fromRGBO(255, 255, 255, .8);
    }
    double opacity;
    if (neuronioService.enable) {
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
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: bgColor),
                    width: boxSize,
                    height: boxSize,
                    child: neuronioService.iconAddress == null
                        ? SizedBox()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              showLocation
                                  ? Container(
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
                                    )
                                  : SizedBox(),
                              Container(
                                  width: boxSize * (40 / 100),
                                  child: imageHandler()),
                              showServiceTitle
                                  ? DocUpSubHeader(
                                      title: neuronioService.title,
                                      textAlign: TextAlign.center,
                                      fontSize: this.bFontSize,
                                    )
                                  : SizedBox(),
                            ],
                          ),
                  ),
                  showDoneIcon
                      ? (doneIcon ??
                          Container(
                            child: Icon(Icons.check_circle_outline_rounded),
                          ))
                      : SizedBox()
                ],
              ),
              neuronioService.responseNormalTime != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: DocUpSubHeader(
                        title: neuronioService.responseNormalTime,
                        textAlign: TextAlign.center,
                        fontSize: 12,
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
      onTap: neuronioService.onTap != null ? neuronioService.onTap : () {},
    );
  }

  Widget imageHandler() {
    Widget defaultImage() {
      return Image.asset(
        Assets.neuronioServiceBrainTest,
        width: boxSize * (40 / 100),
        height: boxSize * (40 / 100),
      );
    }

    if (neuronioService != null &&
        neuronioService.iconURL != null &&
        neuronioService.iconURL != "") {
      Widget image;
      try {
        image = Image.network(
          neuronioService.iconURL,
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
    if (neuronioService != null &&
        neuronioService.iconAddress != null &&
        neuronioService.iconAddress != "") {
      Widget image;
      try {
        image = Image.asset(
          neuronioService.iconAddress,
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
