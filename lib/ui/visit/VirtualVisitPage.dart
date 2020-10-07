import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/DoctorPlan.dart';
import 'package:docup/networking/CustomException.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/DoctorSummaryWidget.dart';
import 'package:docup/ui/widgets/TimeSelectionWidget.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/ui/widgets/VisitDateTimePicker.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'VisitUtils.dart';

class VirtualVisitPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final Function(String, dynamic) onPush;

  VirtualVisitPage({Key key, this.doctorEntity, this.onPush}) : super(key: key);

  @override
  _VirtualVisitPageState createState() => _VirtualVisitPageState();
}

class _VirtualVisitPageState extends State<VirtualVisitPage> {
  DoctorInfoBloc _bloc = DoctorInfoBloc();
  TextEditingController timeTextController = TextEditingController();
  TextEditingController dateTextController = TextEditingController();

  Map<String, int> typeSelected = {
    VISIT_METHOD: VisitMethod.TEXT.index,
    VISIT_DURATION_PLAN: VisitDurationPlan.BASE.index
  };

  bool visitTimeChecked = false;
  bool policyChecked = false;

  @override
  void initState() {
    _bloc.visitRequestStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        showOneButtonDialog(context, Strings.visitRequestedMessage,
            Strings.understandAction, () => Navigator.pop(context));
      } else if (data.status == Status.ERROR) {
        if (data.error is ApiException) {
          ApiException apiException = data.error;
          if (apiException.getCode() == 602) {
            showOneButtonDialog(
                context,
                Strings.notEnoughCreditMessage,
                Strings.addCreditAction,
                () => widget.onPush(
                    NavigatorRoutes.account, _calculateVisitCost()));
          } else if (apiException.getCode() == 601) {
            showOneButtonDialog(
                context,
                getEnabledTimeString(widget.doctorEntity.plan),
                Strings.understandAction,
                () => {});
          } else {
            toast(context, data.error.toString());
          }
        } else {
          toast(context, data.error.toString());
        }
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 50),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
        child: Column(children: <Widget>[
          DoctorSummaryWidget(doctorEntity: widget.doctorEntity),
          ALittleVerticalSpace(),
          _visitTypeWidget(VISIT_METHOD, ["متنی", "صوتی", "تصویری"],
              width: 120, height: 50, fontSize: 16),
          ALittleVerticalSpace(),
          _visitTypeWidget(VISIT_DURATION_PLAN, ["پایه", "تکمیلی", "طولانی"],
              width: 100, height: 45, fontSize: 14),
          ALittleVerticalSpace(),
          _visitDurationTimeWidget(),
          ALittleVerticalSpace(),
          _enableVisitTimeWidget(),
          visitTimeChecked
              ? VisitDateTimePicker(dateTextController, widget.doctorEntity)
              : SizedBox(),
          ALittleVerticalSpace(),
          _priceWidget(),
          ALittleVerticalSpace(),
          _acceptPolicyWidget(),
          ALittleVerticalSpace(),
          _submitWidget(),
          ALittleVerticalSpace(),
        ]),
      ),
    );
  }

  Text _visitDurationTimeWidget() {
    return Text(
        "ویزیت مجازی حداکثر ${replaceFarsiNumber((VisitDurationPlan.values[typeSelected[VISIT_DURATION_PLAN]].duration).toString())} دقیقه می‌باشد",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
  }

  _visitTypeWidget(String title, List<String> items,
          {double width = 120, double height = 40, double fontSize = 17}) =>
      Column(
        children: <Widget>[
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
          ),
          ALittleVerticalSpace(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              for (var index = items.length - 1; index >= 0; index--)
                Visibility(
                  visible: title == VISIT_DURATION_PLAN ||
                      index != VisitMethod.VOICE.index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0, left: 4.0),
                    child: ActionButton(
                      width: width,
                      height: height,
                      fontSize: fontSize,
                      color: typeSelected[title] == index
                          ? IColors.themeColor
                          : Colors.grey,
                      title: items[index],
                      callBack: () {
                        setState(() {
                          typeSelected[title] = index;
                        });
                      },
                    ),
                  ),
                ),
            ],
          )
        ],
      );

  _priceWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("ریال", style: TextStyle(fontSize: 16)),
          SizedBox(width: 5),
          Text(replaceFarsiNumber(_calculateVisitCost()),
              style: TextStyle(
                  color: IColors.themeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          SizedBox(width: 5),
          Text("قیمت نهایی", style: TextStyle(fontSize: 16))
        ],
      );

  String _calculateVisitCost() {
    int cost = 0;
    if (typeSelected[VISIT_METHOD] == VisitMethod.TEXT.index) {
      cost = widget.doctorEntity.plan.baseTextPrice;
    } else if (typeSelected[VISIT_METHOD] == VisitMethod.VOICE.index) {
      cost = widget.doctorEntity.plan.baseVoicePrice;
    } else if (typeSelected[VISIT_METHOD] == VisitMethod.VIDEO.index) {
      cost = widget.doctorEntity.plan.baseVideoPrice;
    }
    cost *= (typeSelected[VISIT_DURATION_PLAN] + 1);
    return cost.toString();
  }

//  _timeSelectionWidget() => Visibility(
//        visible: visitTimeChecked,
//        child: Column(
//          children: <Widget>[
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//                Text(
//                  "ساعت",
//                  textAlign: TextAlign.right,
//                ),
//                Icon(Icons.access_time, size: 30),
//                SizedBox(width: 50),
//                Text("تاریخ"),
//                Icon(Icons.calendar_today),
//              ],
//            ),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//                Container(
//                  width: MediaQuery.of(context).size.width * 0.35,
//                  child: TimeSelectionWidget(
//                      timeTextController: timeTextController),
//                ),
//                SizedBox(width: 50),
//                Container(
//                  width: MediaQuery.of(context).size.width * 0.35,
//                  child: TextField(
//                      controller: dateTextController,
//                      onTap: () => showDatePickerDialog(
//                          context,
//                          widget.doctorEntity.plan.availableDays,
//                          dateTextController)),
//                ),
//              ],
//            )
//          ],
//        ),
//      );

  Row _enableVisitTimeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          "تعیین وقت قبلی ویزیت مجازی",
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Switch(
          value: visitTimeChecked,
          activeColor: IColors.themeColor,
          onChanged: (bool value) {
            setState(() {
              visitTimeChecked = !visitTimeChecked;
            });
          },
        )
      ],
    );
  }

  _acceptPolicyWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            Strings.virtualVisitPrivacyPolicyMessage,
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

  _submitWidget() => ActionButton(
        color: policyChecked ? IColors.themeColor : Colors.grey,
        title: _nowVisitCondition() ? "ویزیت مجازی هم‌اکنون" : "ویزیت مجازی",
        callBack: _submit,
      );

  _nowVisitCondition() => _isDoctorOnline() && !visitTimeChecked;

  _isDoctorOnline() => widget.doctorEntity.user.online == 1;

  void _submit() {
    if (!policyChecked) return;
    if (visitTimeChecked) {
      if (dateTextController.text.isEmpty || timeTextController.text.isEmpty) {
        showOneButtonDialog(
            context, Strings.enterVisitTimeMessage, Strings.okAction, () {});
      } else {
        sendVisitRequest();
      }
    } else {
      if (_isDoctorOnline()) {
        sendNowVisitRequest();
      } else {
        showOneButtonDialog(
            context, Strings.offlineDoctorMessage, Strings.okAction, () {});
      }
    }
  }

  void sendNowVisitRequest() {
    _bloc.visitRequest(
        widget.doctorEntity.id,
        1,
        typeSelected[VISIT_METHOD],
        typeSelected[VISIT_DURATION_PLAN],
        convertToGeorgianDate(getTodayInJalali()) +
            "T" +
            "${DateTime.now().hour}:${DateTime.now().minute}" +
            "+04:30");
  }

  void sendVisitRequest() {
    _bloc.visitRequest(
        widget.doctorEntity.id,
        1,
        typeSelected[VISIT_METHOD],
        typeSelected[VISIT_DURATION_PLAN],
        convertToGeorgianDate(dateTextController.text) +
            "T" +
            timeTextController.text +
            "+04:30");
  }

  String getEnabledTimeString(DoctorPlan plan) {
    String availableDays = "";
    for (int day in plan.availableDays) {
      availableDays += WeekDay.values[day].name + " ";
    }
    String workTimes = "";
    for (WorkTimes workTime in plan.workTimes) {
      workTimes += "از " +
          workTime.startTime.split(":")[0] +
          " تا " +
          (int.parse(workTime.endTime.split(":")[0]) + 1).toString() +
          "\n";
    }
    return replaceFarsiNumber("درخواست ویزیت به پزشک مورد نظر در روزهای " +
        availableDays +
        "امکان پذیر است " +
        "\n"
            "ساعات ارائه ویزیت  " +
        "\n" +
        workTimes);
  }
}
