import 'package:docup/main.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/home/iDoctor/ChatBox.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/widgets/DoctorSummary.dart';

class IDoctorBody extends StatelessWidget {
  final Doctor doctor;
  final ValueChanged<String> onPush;
  final ValueChanged<String> globalOnPush;

  IDoctorBody({Key key, this.doctor, @required this.onPush, this.globalOnPush}) : super(key: key);

  void _showDoctorDialogue() {
    globalOnPush(NavigatorRoutes.doctorDialogue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(child: ChatBox()),
        SizedBox(
          width: 5,
        ),
        SizedBox(
          height: 60,
          child: VerticalDivider(
            color: Colors.grey,
            thickness: 1.5,
            width: 10,
          ),
        ),
        SizedBox(
          width: 3,
        ),
        GestureDetector(
          onTap: () {
            _showDoctorDialogue();
          },
          child: DoctorSummary(doctor.name, doctor.speciality, doctor.location),
        )
      ],
    );
  }
}
