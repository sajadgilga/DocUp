import 'package:flutter/material.dart';

import 'package:docup/ui/home/iDoctor/IDoctorBody.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/widgets/DoctorSummary.dart';

class IDoctor extends StatelessWidget {
  final Doctor doctor;

  IDoctor({Key key, this.doctor}) : super(key: key);

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
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
      decoration: _IDoctorDecoration(),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width, maxHeight: 140),
      child: Column(
        children: <Widget>[
          _IDoctorLabel(),
          Expanded(child: IDoctorBody(doctor: doctor,),),
        ],
      ),
    );
  }
}
