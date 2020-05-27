import 'package:DocUp/models/DoctorEntity.dart';
import 'package:DocUp/models/PatientEntity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PatientData extends StatelessWidget {
  final PatientEntity patientEntity;

  const PatientData({
    Key key, this.patientEntity
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        children: <Widget>[
          Text(
              "${patientEntity.user.firstName} ${patientEntity.user.lastName}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 5),
              Text("${patientEntity.user.firstName} ${patientEntity.user.lastName}",
                  style: TextStyle(
                    fontSize: 14,
                  )),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "کد نظام پزشکی :‌ ${patientEntity.user.password}",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.end,
              ),
              SizedBox(width: 10),
              Icon(
                Icons.info_outline,
                color: Colors.black,
              )
            ],
          ),
        ],
      ),
    );
  }
}
