import 'package:DocUp/constants/colors.dart';
import 'package:flutter/material.dart';

class PanelAlert extends StatelessWidget {
  final String label;
  final String buttonLabel;
  final Function callback;
  final Color btnColor;

  PanelAlert({this.label, this.buttonLabel, this.callback, this.btnColor});

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
              constraints: BoxConstraints(maxHeight: 280, maxWidth: 280),
              padding:
                  EdgeInsets.only(top: 80, bottom: 40, right: 40, left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                      onTap: callback,
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, right: 25, left: 25),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: (btnColor != null? btnColor:IColors.themeColor)),
                        child: Text(
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
