import 'package:Neuronio/ui/visit/calendar/utils/consts.dart';
import 'package:Neuronio/ui/visit/calendar/widget/render_table2.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DatePicker2 extends StatefulWidget {
  final bool isRangeDate;
  final bool isSecondDate;
  final startSelectedDate;
  final endSelectedDate;
  final Function(dynamic) onSelectDate;
  final Function(String) onConfirmedDate;
  final Function(String) onChangePicker;

  DatePicker2(
      {this.isRangeDate,
      this.startSelectedDate = false,
      this.isSecondDate = false,
      this.endSelectedDate,
      this.onChangePicker,
      this.onSelectDate,
      this.onConfirmedDate});

  @override
  _DatePicker2State createState() => _DatePicker2State();
}

class _DatePicker2State extends State<DatePicker2>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  Jalali initDate;
  Jalali startSelectedDate;
  Jalali endSelectedDate;
  bool isRangeDate;

  bool isSlideForward = true;

  final weekDaysName = [
    'ش',
    'ی',
    'د',
    'س ',
    'چ',
    'پ',
    'ج',
  ];

  @override
  void didUpdateWidget(DatePicker2 oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      setState(() {
        isRangeDate = widget.isRangeDate;
        if (widget.endSelectedDate != null) {
          var splitStartDate = widget.startSelectedDate.split('/');
          var splitEndDate = widget.endSelectedDate.split('/');
          startSelectedDate = Jalali(int.parse(splitStartDate[0]),
                  int.parse(splitStartDate[1]), int.parse(splitStartDate[2])) ??
              DateTimeService.getCurrentJalali();
          endSelectedDate = Jalali(int.parse(splitEndDate[0]),
                  int.parse(splitEndDate[1]), int.parse(splitEndDate[2])) ??
              DateTimeService.getCurrentJalali();

          initDate = startSelectedDate = Jalali(int.parse(splitStartDate[0]),
                  int.parse(splitStartDate[1]), int.parse(splitStartDate[2])) ??
              DateTimeService.getCurrentJalali();
        }
      });
    }
  }

  @override
  void dispose() {
    try {
      controller.dispose();
    } catch (e) {}
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isRangeDate = widget.isRangeDate;
    if (widget.endSelectedDate != null) {
      var splitStartDate = widget.startSelectedDate.split('/');
      var splitEndDate = widget.endSelectedDate.split('/');
      startSelectedDate = Jalali(int.parse(splitStartDate[0]),
              int.parse(splitStartDate[1]), int.parse(splitStartDate[2])) ??
          DateTimeService.getCurrentJalali();
      endSelectedDate = Jalali(int.parse(splitEndDate[0]),
              int.parse(splitEndDate[1]), int.parse(splitEndDate[2])) ??
          DateTimeService.getCurrentJalali();

      initDate = startSelectedDate = Jalali(int.parse(splitStartDate[0]),
              int.parse(splitStartDate[1]), int.parse(splitStartDate[2])) ??
          DateTimeService.getCurrentJalali();
    }

    controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut)
      ..addListener(() {
        setState(() {});
      });
  }

  _changeMonth(type) {
    setState(() {
      controller.forward(from: 0);
      int year = int.parse(initDate.formatter.y);
      int month = int.parse(initDate.formatter.m);
      int day = int.parse(initDate.formatter.d);
      var newDate = initDate;
      switch (type) {
        case 'prev':
          isSlideForward = true;

          newDate = initDate.copy(
              month: month > 1 ? month - 1 : 12,
              year: month == 1 ? year - 1 : year);
          break;
        case 'next':
          isSlideForward = false;

          newDate = initDate.copy(
              month: month < 12 ? month + 1 : 1,
              year: month == 12 ? year + 1 : year);
          break;
        case 'now':
          newDate = DateTimeService.getCurrentJalali();
          break;
        default:
      }

      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          initDate = newDate;

          isSlideForward = type == 'prev' ? false : true;
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          // controller.forward();
        }
      });
    });
  }

  String outPutFormat(Date d) {
    final f = d.formatter;

    return '${f.yyyy}/${f.mm}/${f.dd}';
  }

  String fullFormat(Date d) {
    final f = d.formatter;

    return '${f.wN} ${f.d} ${f.mN} ${f.yy}';
  }

  String yearMonthNFormat(Date d) {
    final f = d.formatter;

    return '${f.mN} ${f.yy}';
  }

  String monthDayFormat(Date d) {
    final f = d.formatter;

    return '${f.wN} ${f.dd} ${f.mN}';
  }

  @override
  Widget build(BuildContext context) {
    final cellWidth = 42.0;
    final cellHeight = 35.0;
    List weekDaysWidget = weekDaysName.map((day) {
      return Container(
        width: cellWidth,
        height: cellHeight,
        child: AutoText(
          day,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
          child: Column(
        children: <Widget>[
          Visibility(
            visible: false,
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Global.color,
                ),
                child: isRangeDate
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AutoText(
                            'از ${fullFormat(startSelectedDate)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white),
                          ),
                          AutoText(
                            'تا ${fullFormat(endSelectedDate)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AutoText(
                            '${startSelectedDate.formatter.yyyy}',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white),
                          ),
                          AutoText(
                            '${monthDayFormat(startSelectedDate)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          _changeMonth('prev');
                        },
                        icon: Icon(Icons.chevron_left),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Transform(
                            transform: Matrix4.translationValues(
                                animation.value * (isSlideForward ? 100 : -100),
                                0,
                                0),
                            child: Opacity(
                              opacity: 1 - animation.value,
                              child: TextButton(
                                onPressed: () {
                                  widget.onChangePicker('year');
                                },
                                child: AutoText(yearMonthNFormat(initDate)),
                              ),
                            )),
                      ),
                      IconButton(
                        onPressed: () {
                          _changeMonth('next');
                        },
                        icon: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: weekDaysWidget,
                  ),
                ),
                Transform(
                  transform: Matrix4.translationValues(
                      animation.value * (isSlideForward ? 300 : -300), 0, 0),
                  child: Opacity(
                    opacity: 1 - animation.value,
                    child: RenderTable2(
                      initDate: initDate,
                      startSelectedDate: startSelectedDate,
                      endSelectedDate: endSelectedDate,
                      onSelect: (date) {
                        _okDate();
                        widget.onSelectDate(date);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: false,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    child: AutoText(
                      'تایید',
                      style: TextStyle(fontSize: 16, color: Global.color),
                    ),
                    onPressed: () {
                      _okDate();
                    },
                  ),
                  TextButton(
                    child: AutoText(
                      'انصراف',
                      style: TextStyle(fontSize: 16, color: Global.color),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: AutoText(
                      'اکنون',
                      style: TextStyle(fontSize: 16, color: Global.color),
                    ),
                    onPressed: () {
                      startSelectedDate = DateTimeService.getCurrentJalali();
                      endSelectedDate = DateTimeService.getCurrentJalali();
                      _changeMonth('now');
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }

  void _okDate() {
    if (isRangeDate) {
      widget.onConfirmedDate(
          '${outPutFormat(startSelectedDate)} # ${outPutFormat(endSelectedDate)}');
    } else {
      widget.onConfirmedDate('${outPutFormat(startSelectedDate)}');
    }
  }
}
