import 'package:flutter/material.dart';

import '../../widgets/medicine_reminder.dart';
class ReminderList extends StatefulWidget {
  @override
  ReminderListState createState() => ReminderListState();
}

class ReminderListState extends State<ReminderList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          MedicineReminder('۱۸:۰۰', 'کپسول فلان', Medicine.capsule, 'دوعدد'),
          MedicineReminder('۱۸:۰۰', 'کپسول فلان', Medicine.capsule, 'دوعدد'),
          MedicineReminder('۱۸:۰۰', 'کپسول فلان', Medicine.capsule, 'دوعدد'),
          MedicineReminder('۱۸:۰۰', 'کپسول فلان', Medicine.capsule, 'دوعدد'),
          MedicineReminder('۱۸:۰۰', 'کپسول فلان', Medicine.capsule, 'دوعدد'),
        ],
      ),
    );
  }
}
