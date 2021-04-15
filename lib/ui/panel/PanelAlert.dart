import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:flutter/material.dart';

enum AlertSize { SM, MD, LG }

extension AlertSizeExtension on AlertSize {
  double get width {
    switch (this) {
      case AlertSize.LG:
        return 320;
      case AlertSize.MD:
        return 280;
      case AlertSize.SM:
        return 150;
    }
    return 280;
  }

  double get height {
    switch (this) {
      case AlertSize.LG:
        return 300;
      case AlertSize.MD:
        return 280;
      case AlertSize.SM:
        return 150;
    }
    return 280;
  }
}

class PanelAlert extends StatelessWidget {
  final String label;
  final String buttonLabel;
  final Function callback;
  final Color btnColor;
  final AlertSize size;
  final Widget extraChildWidget;

  PanelAlert(
      {this.label,
      this.buttonLabel,
      this.callback,
      this.btnColor,
      this.extraChildWidget,
      this.size = AlertSize.MD});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          minHeight: MediaQuery.of(context).size.height),
      decoration: BoxDecoration(color: Color.fromRGBO(10, 10, 10, .3)),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        child: Container(
          constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 240),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white),
              constraints: BoxConstraints(maxWidth: size.width),
              padding:
                  EdgeInsets.only(top: 80, bottom: 40, right: 40, left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AutoText(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  ALittleVerticalSpace(),
                  extraChildWidget ?? SizedBox(),
                  ALittleVerticalSpace(),
                  GestureDetector(
                      onTap: callback,
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, right: 25, left: 25),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: (btnColor != null
                                ? btnColor
                                : IColors.themeColor)),
                        child: AutoText(
                          buttonLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
