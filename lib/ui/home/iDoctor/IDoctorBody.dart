import 'package:flutter/material.dart';

import 'package:docup/ui/home/iDoctor/ChatBox.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/widgets/DoctorSummary.dart';

class IDoctorBody extends StatelessWidget {
  final Doctor doctor;

  IDoctorBody({Key key, this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(child: ChatBox()),
        SizedBox(width: 5,),
        SizedBox(
          height: 60,
          child: VerticalDivider(
            color: Colors.grey,
            thickness: 1.5,
            width: 10,
          ),
        ),
        SizedBox(width: 3,),
        DoctorSummary(doctor.name, doctor.speciality, doctor.location),
      ],
    );
  }
}
