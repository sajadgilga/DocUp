import 'package:flutter/material.dart';

import 'header.dart';
import 'search_box.dart';
import '../../widgets/medicine_reminder.dart';
import '../../../constants/strings.dart';

class Home extends StatelessWidget {
  Widget _intro(double width) => ListView(
    padding: EdgeInsets.only(right: width * .075),
    shrinkWrap: true,
    children: <Widget>[
      Text(
        Strings.docUpIntroHomePart1,
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 22),

      ),
      Text(
        Strings.docUpIntroHomePart2,
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Header(),
        Container(
          height: 10,
        ),
        _intro(MediaQuery.of(context).size.width),
        Container(height: 20,),
        SearchBox(),
        SizedBox(height: 30,),
        Text(Strings.medicineReminder, textAlign: TextAlign.center,),
        MedicineReminder('۱۸:۰۰', 'کپسول فلان', Medicine.capsule, 'دوعدد')
      ],
    ));
  }
}
