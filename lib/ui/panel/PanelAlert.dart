import 'package:docup/constants/colors.dart';
import 'package:flutter/material.dart';

class PanelAlert extends StatelessWidget {
  String label;
  String buttonLabel;

  PanelAlert({this.label, this.buttonLabel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height),
        decoration: BoxDecoration(color: Color.fromRGBO(10, 10, 10, .3)),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Container(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 240),
            child: Center(child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white),
              constraints: BoxConstraints(maxHeight: 260, maxWidth: 260),
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
                  Container(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, right: 25, left: 25),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: IColors.themeColor),
                    child: Text(
                      buttonLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),),
      ),
    );
  }
}
