import 'dart:math';

import 'package:docup/constants/colors.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/ui/visit/calendar/persian_datetime_picker2.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'FlutterDateTimePickerCustom/flutter_datetime_picker.dart';
import 'FlutterDateTimePickerCustom/src/datetime_picker_theme.dart';
import 'FlutterDateTimePickerCustom/src/i18n_model.dart';
import 'TimeSelectorHeaderWidget.dart';
import 'TimeSelectorWidget.dart';

class VisitDateTimePicker extends StatefulWidget {
  TextEditingController dateTextController;
  TextEditingController timeTextController;

  DoctorEntity doctorEntity;
  final bool scrollableTimeSelectorType;

  VisitDateTimePicker(
      this.dateTextController, this.timeTextController, this.doctorEntity,
      {this.scrollableTimeSelectorType = false});

  @override
  _VisitDateTimePickerState createState() => _VisitDateTimePickerState();
}

class _VisitDateTimePickerState extends State<VisitDateTimePicker> {
  bool timeIsSelected = false;
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  @override
  void initState() {
    widget.dateTextController.text = getTodayInJalali();
    super.initState();
  }

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
                    initial: getTodayInJalali(),
                    min: getYesterdayInJalily(),
                    disable: getDisableDays((widget.doctorEntity == null ||
                            widget.doctorEntity.plan == null)
                        ? <int>[]
                        : widget.doctorEntity.plan.availableDays),
                    onSelect: (date) {
                      widget.dateTextController.text = date;
                    },
                  ),
                )
              : (widget.scrollableTimeSelectorType
                  ? scrollableTimeSelector()
                  : TimeSelectorWidget(
                      timeController: widget.timeTextController,
                    ))
        ],
      ),
    );
  }

  Widget scrollableTimeSelector() {
    double xSize = MediaQuery.of(context).size.width;
    return Container(
      width: xSize * 0.9,
      height: 150,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              int hour = 0;
              if (![null, ""].contains(startTimeController.text)) {
                hour = int.parse(startTimeController.text.split(":")[0]);
              } else {
                DateTime now = DateTime.now();
                hour = now.hour;
              }
              DateTime startDateTime = DateTime(2020, 1, 1, hour, 0, 0);
              showTime(endTimeController, startDateTime);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  border: Border.all(width: 1, color: IColors.darkGrey)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AutoText("پایان"),
                  SizedBox(
                    width: min(70, xSize * 0.3),
                    child: TextField(
                      controller: endTimeController,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      enabled: false,
                      maxLines: 1,
                      decoration: InputDecoration(hintText: "۰۰ : ۰۰"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              DateTime now = DateTime.now();
              DateTime startDateTime = DateTime(2020, 1, 1, now.hour, 0, 0);
              showTime(startTimeController, startDateTime);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  border: Border.all(width: 1, color: IColors.darkGrey)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AutoText("شروع"),
                  SizedBox(
                    width: min(70, xSize * 0.3),
                    child: TextField(
                      controller: startTimeController,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      enabled: false,
                      decoration: InputDecoration(hintText: "۰۰ : ۰۰"),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void showTime(
      TextEditingController textEditingController, DateTime startDateTime) {
    DatePicker.showTimePicker(context,
        showTitleActions: true,
        theme: DatePickerTheme(
            doneStyle: TextStyle(color: IColors.themeColor),
            titles: {0: "ساعت", 1: "دقیقه"},
            itemStyle: TextStyle(
                fontWeight: FontWeight.w700, color: Color(0xFF000046))),
        onChanged: (date) {}, onConfirm: (date) {
      textEditingController.text =
          date.hour.toString() + ':' + date.minute.toString();
      widget.timeTextController.text =
          startTimeController.text + "-" + endTimeController.text;
    }, currentTime: startDateTime, locale: LocaleType.fa);
  }

  void changeBetweenTimeAndDate(bool timeIsSelected) {
    setState(() {
      this.timeIsSelected = timeIsSelected;
    });
  }
}
