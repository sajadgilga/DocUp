import 'package:Neuronio/ui/visit/calendar/utils/consts.dart';
import 'package:Neuronio/ui/visit/calendar/utils/date.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DayContainer2 extends StatefulWidget {
  final date;
  final startDate;
  final endDate;
  final Function(Jalali) onSelect;
  final width;
  final height;

  DayContainer2(
      {this.date,
      this.startDate,
      this.endDate,
      this.onSelect,
      this.height,
      this.width});

  @override
  _DayContainer2State createState() => _DayContainer2State();
}

class _DayContainer2State extends State<DayContainer2> {
  var date;
  bool isDisable;

  @override
  void initState() {
    date = widget.date;
    var dateUtils = new CalendarDateUtils();
    isDisable = date != '' ? dateUtils.isDisable(outPutFormat(date)) : false;

    // TODO: implement initState
    super.initState();
  }

  String outPutFormat(Date d) {
    final f = d.formatter;

    return '${f.yyyy}/${f.mm}/${f.dd}';
  }

  @override
  void didUpdateWidget(DayContainer2 oldWidget) {
    if (oldWidget != widget) {
      date = widget.date;
      var dateUtils = new CalendarDateUtils();
      isDisable = date != '' ? dateUtils.isDisable(outPutFormat(date)) : false;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var decoration = BoxDecoration();

    bool isValid = date != '';
    bool isStart = isValid && date == widget.startDate;
    bool isBetween =
        isValid && date > widget.startDate && date < widget.endDate;
    bool isEnd = isValid && date == widget.endDate;

    if (isStart) {
      decoration = BoxDecoration(
          color: Global.color,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(0.0, 2.0),
                spreadRadius: 1.0,
                blurRadius: 1.0)
          ],
          borderRadius: BorderRadius.horizontal(right: Radius.circular(50.0)));
    }
    if (isEnd) {
      decoration = BoxDecoration(
          color: Global.color,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(0.0, 4.0),
                spreadRadius: -2.0,
                blurRadius: 1.0)
          ],
          borderRadius: BorderRadius.horizontal(left: Radius.circular(50.0)));
    }
    if (isEnd && isStart) {
      decoration = BoxDecoration(
          color: Global.color,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(0.0, 4.0),
                spreadRadius: -2.0,
                blurRadius: 1.0)
          ],
          borderRadius: BorderRadius.all(Radius.circular(50.0)));
    }
    if (isBetween) {
      decoration = BoxDecoration(
        color: Global.color,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0.0, 4.0),
              spreadRadius: -2.0,
              blurRadius: 1.0)
        ],
      );
    }

    return InkWell(
      onTap: () {
        if (date != '' && !isDisable) {
          widget.onSelect(date);
        }
      },
      child: date != ''
          ? Container(
              decoration: decoration,
              width: widget.width,
              height: widget.height,
              child: Container(
                margin: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: isStart || isEnd ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: Center(
                  child: AutoText(
                    date != '' ? date.formatter.d : '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDisable ? Colors.grey : Colors.black,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            )
          : Container(
              width: widget.width,
              height: widget.height,
            ),
    );
  }
}
