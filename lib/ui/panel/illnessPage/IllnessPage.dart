import 'package:docup/models/Doctor.dart';
import 'package:docup/models/VisitTime.dart';
import 'package:docup/ui/panel/chatPage/DoctorInfo.dart';
import 'package:docup/ui/widgets/VisitBox.dart';
import 'package:flutter/material.dart';

import 'IllnessPicList.dart';

class IllnessPage extends StatelessWidget {
  final Doctor doctor;
  final ValueChanged<String> onPush;

  IllnessPage({Key key, this.doctor, @required this.onPush}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<VisitTime> times = [];
    times.add(VisitTime(Month.ESF, '۷', '۱۳۹۸', true));
    times.add(VisitTime(Month.DAY, '۱۶', '۱۳۹۸', false));
    times.add(VisitTime(Month.ABN, '۷', '۱۳۹۸', false));
    times.add(VisitTime(Month.TIR, '۱۲', '۱۳۹۸', false));
    times.add(VisitTime(Month.FAR, '۲۱', '۱۳۹۸', false));

    return SingleChildScrollView(child: Container(
      child: Column(
        children: <Widget>[
          DoctorInfo(
            doctor: doctor,
            onPush: onPush,
          ),
          VisitBox(
            visitTimes: times,
          ),
          PicList()
        ],
      ),
    ));
  }
}
