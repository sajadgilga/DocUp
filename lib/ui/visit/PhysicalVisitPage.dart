import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/visit/calendar/persian_datetime_picker2.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/DoctorSummaryWidget.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum WeekDay { SATURDAY, SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY }

extension WeekDaysExtension on WeekDay {
  String get name {
    switch (this) {
      case WeekDay.SATURDAY:
        return "saturday";
      case WeekDay.SUNDAY:
        return "sunday";
      case WeekDay.MONDAY:
        return "monday";
      case WeekDay.TUESDAY:
        return "tuesday";
      case WeekDay.WEDNESDAY:
        return "wednesday";
      case WeekDay.THURSDAY:
        return "thursday";
      case WeekDay.FRIDAY:
        return "friday";
    }
  }
}

const VISIT_METHOD = "نوع مشاوره";
const String TIME_SELECTION = "انتخاب ساعت";

class PhysicalVisitPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final Function(String, dynamic) onPush;

  PhysicalVisitPage({Key key, this.doctorEntity, this.onPush})
      : super(key: key);

  @override
  _PhysicalVisitPageState createState() => _PhysicalVisitPageState();
}

class _PhysicalVisitPageState extends State<PhysicalVisitPage> {
  DoctorInfoBloc _bloc = DoctorInfoBloc();

  Map<String, String> typeSelected = {
    VISIT_METHOD: "حضوری",
    TIME_SELECTION: ""
  };
  bool policyChecked = false;
  TextEditingController dateTextController = TextEditingController();
  int timeIndexSelected = -1;

  @override
  void initState() {
    dateTextController.text = getTomorrowInJalali();
    _bloc.visitRequestStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        showOneButtonDialog(context, Strings.physicalVisitRequestedMessage,
            "در انتظار تایید پزشک", () => Navigator.pop(context), color: Colors.black54);
      } else if (data.status == Status.ERROR) {
        toast(context, data.message);
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 50),
        constraints:
        BoxConstraints(maxWidth: MediaQuery
            .of(context)
            .size
            .width),
        child: Column(children: <Widget>[
          DoctorSummaryWidget(doctorEntity: widget.doctorEntity),
          ALittleVerticalSpace(),
          _labelWidget("حضوری"),
          ALittleVerticalSpace(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ActionButton(
                width: 120,
                color: IColors.themeColor,
                title: "حضوری",
                callBack: () {}
              ),
            ],
          ),
          ALittleVerticalSpace(),
          _calendarWidget(),
          ALittleVerticalSpace(),
          _labelWidget(TIME_SELECTION),
          ALittleVerticalSpace(),
          _timesWidget(TIME_SELECTION, _getVisitTimes()),
          ALittleVerticalSpace(),
          _acceptPolicyWidget(),
          ALittleVerticalSpace(),
          _submitWidget(),
          ALittleVerticalSpace(),
        ]),
      ),
    );
  }

  _calendarWidget() =>
      Column(
        children: <Widget>[
          _labelWidget("زمان برگزاری"),
          ALittleVerticalSpace(),
          Container(
            color: IColors.grey,
            child: PersianDateTimePicker2(
              color: IColors.themeColor,
              type: "date",
              initial: getTomorrowInJalali(),
              min: getTodayInJalali(),
              disable: _getDisableDays(),
              onSelect: (date) {
                dateTextController.text = date;
              },
            ),
          ),
        ],
      );

  _getDisableDays() {
    List<String> disableDays = [];
    final availableDays = widget.doctorEntity.plan.availableDays;
    for (int i = 0; i < 7; i++) {
      if (!availableDays.contains(i)) disableDays.add(WeekDay.values[i].name);
    }
    return disableDays;
  }

  _getVisitTimes() {
    List<String> visitTimes = [];
    final startTime = widget.doctorEntity.plan.startTime;
    final endTime = widget.doctorEntity.plan.endTime;
    final startHour = int.parse(startTime.split(":")[0]);
    final endHour = int.parse(endTime.split(":")[0]);
    for (int i = startHour; i <= endHour; i += 2) {
      final from = i.toString();
      final to = (i + 2).toString();
      visitTimes.add(replaceFarsiNumber("از " + from + " تا " + to));
    }
    return visitTimes
        .toList();
  }

  _submitWidget() =>
      ActionButton(
        color: policyChecked ? IColors.themeColor : Colors.grey,
        title: "رزرو نوبت",
        callBack: _sendVisitRequest,
      );

  _acceptPolicyWidget() =>
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            Strings.physicalVisitPrivacyPolicyMessage,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10),
          ),
          Checkbox(
            activeColor: IColors.themeColor,
            value: policyChecked,
            onChanged: (d) {
              setState(() {
                policyChecked = !policyChecked;
              });
            },
          ),
        ],
      );

  _timesWidget(String title, List<String> items) =>
      Container(
        height: 50,
        child: ListView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            for (var index = 0; index < items.length; index++)
              Wrap(
                children: <Widget>[Padding(
                  padding: const EdgeInsets.only(right: 4.0, left: 4.0),
                  child: ActionButton(
                    width: 120,
                    color: typeSelected[title] == items[index]
                        ? IColors.themeColor
                        : Colors.grey,
                    title: items[index],
                    callBack: () {
                      setState(() {
                        timeIndexSelected = index;
                        typeSelected[title] = items[index];
                      });
                    },
                  ),
                ),],
              ),
          ],
        ),
      );


  _labelWidget(String title) =>
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      );

  _sendVisitRequest() {
    if (timeIndexSelected == -1) {
      showOneButtonDialog(
          context, "لطفا زمان رزرو ویزیت را وارد کنید", "باشه", () {});
    } else {
      //TODO: fit start time
      _bloc.visitRequest(
          widget.doctorEntity.id,
          0,
          0,
          0,
          convertToGeorgianDate(dateTextController.text) +
              "T" +
              widget.doctorEntity.plan.startTime +
              "+04:30");
    }
  }
}
