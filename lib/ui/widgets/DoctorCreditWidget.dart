import 'package:docup/constants/colors.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AutoText.dart';

class DoctorCreditWidget extends StatefulWidget {
  final String credit;
  final DoctorEntity doctorEntity;
  final Function onTakeMoney;

  DoctorCreditWidget({this.credit,this.doctorEntity,this.onTakeMoney});

  @override
  _DoctorCreditWidgetState createState() => _DoctorCreditWidgetState();
}

class _DoctorCreditWidgetState extends State<DoctorCreditWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.6,
        height: 60,
        decoration: BoxDecoration(
            color: IColors.themeColor,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                widget.onTakeMoney();
              },
              child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.3,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 0),
                          color: IColors.themeColor,
                          blurRadius: 3)
                    ]),
                child: AutoText("برداشت"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: AutoText(
                "اعتبار حساب" + "\n" + replaceFarsiNumber(widget.credit),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
