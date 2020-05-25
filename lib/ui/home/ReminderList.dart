import 'package:docup/models/Medicine.dart';
import 'package:flutter/material.dart';

import '../widgets/MedicineReminder.dart';

class ReminderList extends StatelessWidget {
  final List<Medicine> medicines;

  ReminderList({Key key, this.medicines}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (medicines != null) {
      for (var medicine in medicines) {
        items.add(MedicineReminder(medicine.consumingTime, medicine.drugName,
            MedicineType.capsule, medicine.usage, state: ReminderState.near,));
      }
    }
    else {
      items.add(MedicineReminder(
        null,
        'دارویی در حال حاضر موجود نمی باشد',
        MedicineType.capsule,
        '',
        state: ReminderState.disabled,
        textSize: 9,
      ));
    }
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          height: 160,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items),
        ));
  }
}
