import 'package:flutter/material.dart';

import 'IDoctorBody.dart';
import '../../../models/Doctor.dart';
import '../../widgets/DoctorSummary.dart';

class IDoctor extends StatelessWidget {

  Widget _IDoctorLabel() => Container(
        constraints: BoxConstraints(maxHeight: 35),
        child: Align(
          alignment: Alignment.topRight,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)),
            child: Container(
              alignment: Alignment.center,
              color: Colors.red,
              width: 60,
              height: 30,
              child: Text(
                'پزشک من',
                style: TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

  BoxDecoration _IDoctorDecoration() => BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Color.fromRGBO(255, 255, 255, .8));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 30),
      decoration: _IDoctorDecoration(),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: Column(
        children: <Widget>[
          _IDoctorLabel(),
          IDoctorBody(doctor: Doctor('دکتر زهرا شادلو', 'متخصص پوست', 'اقدسیه', Image(image: AssetImage(' ')), null),),
        ],
      ),
    );
  }
}
