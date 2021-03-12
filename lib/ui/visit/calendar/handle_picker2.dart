
import 'package:Neuronio/ui/visit/calendar/date_picker2.dart';
import 'package:Neuronio/ui/visit/calendar/utils/date.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class HandlePicker2 extends StatefulWidget {
  final bool isRangeDate;
  final initDateTime;
  final type;
  final Function(String) onSelect;

  HandlePicker2({this.isRangeDate, this.initDateTime, this.type, this.onSelect});

  @override
  _HandlePicker2State createState() => _HandlePicker2State();
}

class _HandlePicker2State extends State<HandlePicker2>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  // var initDate;
  // var initTime;
  var startSelectedInitDate;
  var startSelectedInitTime;
  var endSelectedInitDate;
  var endSelectedInitTime;
  var initDateTime;

  bool isSecondSelect;
  String pickerType = 'date';

  String outPutFormat(Date d) {
    final f = d.formatter;

    return '${f.yyyy}/${f.mm}/${f.dd}';
  }

  @override
  void initState() {
    super.initState();
    initDateTime = widget.initDateTime;
    Jalali jalaliNow = DateTimeService.getCurrentJalali();
    DateTime nowGeorgian = DateTimeService.getCurrentDateTime();
    if (initDateTime == null) {
      switch (widget.type) {
        case 'rangedate':
          initDateTime = '${DateUtils.jalaliToString(jalaliNow)} # ${DateUtils.jalaliToString(jalaliNow)}';
          break;
        case 'datetime':
          initDateTime = '${DateUtils.jalaliToString(jalaliNow)} 00:00';
          break;
        case 'date':
          initDateTime = '${DateUtils.jalaliToString(jalaliNow)}';
          break;
        case 'time':
          initDateTime = '00:00';
          break;
        case 'year':
          initDateTime = '${jalaliNow.formatter.yyyy}';

          break;
        case 'month':
          initDateTime = '${jalaliNow.formatter.mm}';
          break;
        default:
      }
    }
    isSecondSelect = false;
    if (widget.type == 'rangedate') {
      if (initDateTime != null) {
        var splitInitDateTimes = initDateTime.split('#');
        var splitStartDateTime = splitInitDateTimes[0].split(' ');
        var splitEndDateTime = splitInitDateTimes[1].split(' ');
        startSelectedInitDate =
            splitStartDateTime.length > 0 ? splitStartDateTime[0] : null;
        startSelectedInitTime =
            splitStartDateTime.length > 1 ? splitStartDateTime[1] : null;

        endSelectedInitDate =
            splitEndDateTime.length > 0 ? splitEndDateTime[0] : null;
        endSelectedInitTime =
            splitEndDateTime.length > 1 ? splitEndDateTime[1] : null;
      } else {
        startSelectedInitDate = '${jalaliNow}';
        endSelectedInitDate = '${jalaliNow}';
        startSelectedInitTime =
            "${nowGeorgian.hour}:${nowGeorgian.minute}";
        endSelectedInitTime = "${nowGeorgian.hour}:${nowGeorgian.minute}";
      }
    } else {
      if (initDateTime != null) {
        var splitDateTime = initDateTime.split(' ');
        startSelectedInitDate =
            splitDateTime.length > 0 ? splitDateTime[0] : null;
        endSelectedInitDate =
            splitDateTime.length > 0 ? splitDateTime[0] : null;
        endSelectedInitTime =
            splitDateTime.length > 1 ? splitDateTime[1] : null;
      } else {
        startSelectedInitDate = '${jalaliNow}';
        endSelectedInitDate = '${jalaliNow}';
        startSelectedInitTime =
            "${nowGeorgian.hour}:${nowGeorgian.minute}";
        endSelectedInitTime = "${nowGeorgian.hour}:${nowGeorgian.minute}";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget picker;

    switch (widget.type) {
      case 'date':
        Widget picked;

        switch (pickerType) {
          case 'date':
            picked = DatePicker2(
              startSelectedDate: startSelectedInitDate,
              endSelectedDate: endSelectedInitDate,
              isRangeDate: false,
              onConfirmedDate: (date) {
                startSelectedInitDate = date;
//                Navigator.pop(context);
              },
              onSelectDate: (date) {
                widget.onSelect("${date.year}/${date.month}/${date.day}");
                setState(() {
                  startSelectedInitDate = outPutFormat(date);
                  endSelectedInitDate = outPutFormat(date);
                });
              },
              onChangePicker: (picker) {
                setState(() {
                  pickerType = 'year';
                });
              },
            );
            break;
          default:
        }
        picker = Container(child: picked);
        break;
      default:
        Widget picked;

        switch (pickerType) {
          case 'date':
            picked = DatePicker2(
              startSelectedDate: startSelectedInitDate,
              endSelectedDate: endSelectedInitDate,
              isRangeDate: false,
              onConfirmedDate: (date) {
                startSelectedInitDate = date;
                widget.onSelect('$startSelectedInitDate');
                Navigator.pop(context);
              },
              onSelectDate: (date) {
                setState(() {
                  startSelectedInitDate = outPutFormat(date);
                  endSelectedInitDate = outPutFormat(date);
                });
              },
              onChangePicker: (picker) {
                setState(() {
                  pickerType = 'year';
                });
              },
            );
            break;
          default:
        }
        picker = Container(child: picked);
        break;
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: picker,
    );
  }
}
