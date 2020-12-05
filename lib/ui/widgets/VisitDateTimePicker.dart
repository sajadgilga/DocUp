import 'dart:math';

import 'package:docup/constants/colors.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/ui/visit/calendar/persian_datetime_picker2.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/DailyTimeTable.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'FlutterDateTimePickerCustom/flutter_datetime_picker.dart';
import 'FlutterDateTimePickerCustom/src/datetime_picker_theme.dart';
import 'FlutterDateTimePickerCustom/src/i18n_model.dart';
import 'TimeSelectorHeaderWidget.dart';
import 'TimeSelectorWidget.dart';

enum TimeSelectorType { Scrollable, Circular, Table }

class VisitDateTimePicker extends StatefulWidget {
  final TextEditingController dateTextController;
  final TextEditingController timeTextController;

  DoctorEntity doctorEntity;
  final TimeSelectorType timeSelectorType;

  /// scrollable widget
  final bool endTimeWidget;

  /// table widget
  final TextEditingController planDurationInMinute;
  final Function onBlocTap;

  VisitDateTimePicker(
      this.dateTextController, this.timeTextController, this.doctorEntity,
      {this.timeSelectorType = TimeSelectorType.Table,
      this.endTimeWidget = false,
      this.planDurationInMinute,
      this.onBlocTap});

  @override
  _VisitDateTimePickerState createState() => _VisitDateTimePickerState();
}

class _VisitDateTimePickerState extends State<VisitDateTimePicker> {
  bool timeIsSelected = false;
  int selectedDay = 0;
  String initialDate;
  Map<int, String> disableDays = {};

  @override
  void initState() {
    disableDays = getDisableDays(
        (widget.doctorEntity == null || widget.doctorEntity.plan == null)
            ? {}
            : widget.doctorEntity.plan.availableDays);
    initialDate = ['', null].contains(widget.dateTextController.text)
        ? getInitialDate(disableDays)
        : widget.dateTextController.text;
    widget.dateTextController.text = initialDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var jalali = getJalalyDateFromJalilyString(widget.dateTextController.text);
    if (jalali != null) {
      selectedDay = jalali.weekDay - 1;
    }
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
                    initial: initialDate,
                    min: getYesterdayInJalilyString(),
                    disable: disableDays,
                    onSelect: (date) {
                      widget.dateTextController.text = date;
                      initialDate = date;
                    },
                  ),
                )
              : (widget.timeSelectorType == TimeSelectorType.Scrollable
                  ? ScrollableTimeSelector(
                      endTimeWidget: widget.endTimeWidget,
                      timeTextController: widget.timeTextController,
                    )
                  : (widget.timeSelectorType == TimeSelectorType.Circular
                      ? CircularTimeSelector(
                          timeController: widget.timeTextController,
                        )
                      : DailyAvailableVisitTime(
                          startTableHour: widget.doctorEntity.plan
                              .getMinWorkTimeHour(selectedDay),
                          endTableHour: widget.doctorEntity.plan
                              .getMaxWorkTimeHour(selectedDay),

                          /// TODO
                          planDurationInMinute: widget.planDurationInMinute,
                          selectedDateController: widget.dateTextController,
                          selectedTimeController: widget.timeTextController,
                          dailyDoctorWorkTime: widget.doctorEntity.plan
                              .getDailyWorkTimeTable(selectedDay),
                          dayUnAvailableTimeTable: widget.doctorEntity.plan
                              .getTakenVisitDailyTimeTable(
                                  widget.dateTextController.text),
                          onBlocTap: widget.onBlocTap,
                        )))
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

class ScrollableTimeSelector extends StatefulWidget {
  final bool endTimeWidget;
  final TextEditingController timeTextController;

  const ScrollableTimeSelector(
      {Key key, this.endTimeWidget, this.timeTextController})
      : super(key: key);

  @override
  _ScrollableTimeSelectorState createState() => _ScrollableTimeSelectorState();
}

class _ScrollableTimeSelectorState extends State<ScrollableTimeSelector> {
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  Widget scrollableTimeSelector() {
    double xSize = MediaQuery.of(context).size.width;
    return Container(
      width: xSize * 0.9,
      height: 150,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: widget.endTimeWidget
            ? MainAxisAlignment.spaceAround
            : MainAxisAlignment.center,
        children: [
          widget.endTimeWidget
              ? GestureDetector(
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
                )
              : SizedBox(),
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

  String correctTimeFormat(String text) {
    if (text.split(":").length == 3) {
      /// TODO amir: we don't user second so maybe later
    } else if (text.split(":").length == 2) {
      String hour = text.split(":")[0];
      String minute = text.split(":")[1];
      if (hour.length == 1) {
        hour = "0" + hour;
      }
      if (minute.length == 1) {
        minute = "0" + minute;
      }
      return hour + ":" + minute;
    }
    return text;
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
      textEditingController.text = correctTimeFormat(
          date.hour.toString() + ':' + date.minute.toString());
      widget.timeTextController.text =
          correctTimeFormat(startTimeController.text) +
              "-" +
              correctTimeFormat(endTimeController.text);
    }, currentTime: startDateTime, locale: LocaleType.fa);
  }
}
