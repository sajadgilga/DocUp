import 'dart:math';

import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/DoctorPlan.dart';
import 'package:Neuronio/ui/visit/calendar/persian_datetime_picker2.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DailyTimeTable.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/FlutterDateTimePickerCustom/flutter_datetime_picker.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/FlutterDateTimePickerCustom/src/datetime_picker_theme.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/FlutterDateTimePickerCustom/src/i18n_model.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'TimeSelectorHeaderWidget.dart';
import 'TimeSelectorWidget.dart';

enum TimeSelectorType { Scrollable, Circular, Table }

class VisitDateTimePicker extends StatefulWidget {
  final TextEditingController dateTextController;
  final TextEditingController timeTextController;

  DoctorPlan doctorPlan;
  VisitType visitType;
  final TimeSelectorType timeSelectorType;

  /// scrollable widget
  final bool endTimeWidget;

  /// table widget
  final TextEditingController planDurationInMinute;
  final Function onBlocTap;

  VisitDateTimePicker(this.dateTextController, this.timeTextController,
      this.doctorPlan, this.visitType,
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
        (widget.visitType == null) ? <int>[] : widget.visitType.availableDays);
    initialDate = ['', null].contains(widget.dateTextController.text)
        ? getInitialDate(disableDays)
        : widget.dateTextController.text;
    widget.dateTextController.text = initialDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var jalali = DateTimeService.getJalalyDateFromJalilyString(
        widget.dateTextController.text);
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
                    min: DateTimeService.getYesterdayInJalilyString(),
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
                          startTableHour: widget.visitType
                                  ?.getMinWorkTimeHour(selectedDay) ??
                              0,
                          endTableHour: widget.visitType
                                  ?.getMaxWorkTimeHour(selectedDay) ??
                              0,

                          /// TODO
                          planDurationInMinute: widget.planDurationInMinute,
                          selectedDateController: widget.dateTextController,
                          selectedTimeController: widget.timeTextController,
                          /// TODO
                          dailyDoctorWorkTime: null ??
                              VisitType.getEmptyTablePlan(),
                          dayReservedTimeTable: widget.doctorPlan
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
                      DateTime now = DateTimeService.getCurrentDateTime();
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
              DateTime now = DateTimeService.getCurrentDateTime();
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
