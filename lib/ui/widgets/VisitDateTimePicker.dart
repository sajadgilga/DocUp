import 'package:docup/constants/colors.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/ui/visit/calendar/persian_datetime_picker2.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'TimeSelectorHeaderWidget.dart';
import 'TimeSelectorWidget.dart';

class VisitDateTimePicker extends StatefulWidget {
  TextEditingController dateTextController;
  DoctorEntity doctorEntity;

  VisitDateTimePicker(this.dateTextController, this.doctorEntity);

  @override
  _VisitDateTimePickerState createState() => _VisitDateTimePickerState();
}

class _VisitDateTimePickerState extends State<VisitDateTimePicker> {
  bool timeIsSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TimeSelectorHeaderWidget(
            callback: changeBetweenTimeAndDate,
            initialTimeIsSelected: false,
          ),
          !this.timeIsSelected
              ? Container(
                  color: IColors.grey,
                  child: PersianDateTimePicker2(
                    color: IColors.themeColor,
                    type: "date",
                    initial: getTomorrowInJalali(),
                    min: getTodayInJalali(),
                    disable:
                        getDisableDays(widget.doctorEntity.plan.availableDays),
                    onSelect: (date) {
                      widget.dateTextController.text = date;
                    },
                  ),
                )
              : TimeSelectorWidget()
        ],
      ),
    );
  }

  void changeBetweenTimeAndDate(bool timeIsSelected) {
    setState(() {
      this.timeIsSelected = timeIsSelected;
    });
  }
}
