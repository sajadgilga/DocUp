import 'package:DocUp/ui/visit/calendar/widget/day_container2.dart';
import 'package:DocUp/ui/visit/calendar/widget/partition.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class RenderTable2 extends StatefulWidget {
  final initDate;
  final startSelectedDate;
  final endSelectedDate;
  final Function(Jalali) onSelect;

  RenderTable2({
    this.initDate,
    this.startSelectedDate,
    this.endSelectedDate,
    this.onSelect,
  });
  @override
  _RenderTable2State createState() => _RenderTable2State();
}

class _RenderTable2State extends State<RenderTable2> {
  var initDate;
  int monthLength;
  int currentDayOfMonth;
  int numberOfFirstDayOfMonthInWeek;
  List allDaysOfTable; //valid and invalid days



  @override
  void didUpdateWidget(RenderTable2 oldWidget) {
    if (oldWidget.initDate != widget.initDate) {
      setState(() {
        allDaysOfTable = [];
        initDate = widget.initDate;
        monthLength = initDate.monthLength;
        currentDayOfMonth = int.parse(initDate.formatter.d);
        numberOfFirstDayOfMonthInWeek = initDate.copy(day: 1).weekDay;

        for (int i = 1; i <= 42; i++) {
          if (i < numberOfFirstDayOfMonthInWeek) {
            allDaysOfTable.add('');
          } else if (i < monthLength + numberOfFirstDayOfMonthInWeek) {
            allDaysOfTable.add(i - (numberOfFirstDayOfMonthInWeek - 1));
          } else {
            allDaysOfTable.add('');
          }
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    allDaysOfTable = [];
    initDate = widget.initDate;
    monthLength = initDate.monthLength;
    currentDayOfMonth = int.parse(initDate.formatter.d);
    numberOfFirstDayOfMonthInWeek = initDate.copy(day: 1).weekDay;

    for (int i = 1; i <= 42; i++) {
      if (i < numberOfFirstDayOfMonthInWeek) {
        allDaysOfTable.add('');
      } else if (i < monthLength + numberOfFirstDayOfMonthInWeek) {
        allDaysOfTable.add(i - (numberOfFirstDayOfMonthInWeek - 1));
      } else {
        allDaysOfTable.add('');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final cellWidth = 42.0;
    final cellHeight = 35.0;


    List<Widget> allDaysWidget = allDaysOfTable.map((dayNumber) {
      var date = dayNumber != '' ? initDate.copy(day: dayNumber) : '';
      return DayContainer2(
        date: date,
        startDate: widget.startSelectedDate,
        endDate: widget.endSelectedDate,
        width: cellWidth,
        height: cellHeight,
        onSelect: (date) {
          widget.onSelect(date);
        },
      );
    }).toList();

    List chunkAllDays = partition(allDaysWidget, 7).toList();

    List chunkWeeksWidget = chunkAllDays.map((week) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: week,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: chunkWeeksWidget,
        )
      ],
    );
  }
}
