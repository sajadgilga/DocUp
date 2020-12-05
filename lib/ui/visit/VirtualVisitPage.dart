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
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/DescriptionAlertDialog.dart';
import 'package:docup/ui/widgets/DoctorSummaryWidget.dart';
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

class _VirtualVisitPageState extends State<VirtualVisitPage>
    with TickerProviderStateMixin {
  DoctorInfoBloc _bloc = DoctorInfoBloc();
  TextEditingController timeTextController = TextEditingController();
  TextEditingController dateTextController = TextEditingController();
  bool submitLoadingToggle = false;

  Map<String, int> typeSelected = {
    VISIT_METHOD: VisitMethod.TEXT.index,
    // VISIT_DURATION_PLAN: VisitDurationPlan.BASE.index
  };

  bool visitTimeChecked = false;
  bool policyChecked = false;

  /// plan duration: visit time in minute
  final TextEditingController _planMinuteDurationController =
      TextEditingController();

  @override
  void initState() {
    try {
      typeSelected[VISIT_METHOD] = widget.doctorEntity.plan.visitMethod.first;
      // typeSelected[VISIT_DURATION_PLAN] =
      //     widget.doctorEntity.plan.visitDurationPlan.first;
    } catch (e) {}

    _bloc.visitRequestStream.listen((data) {
      setState(() {
        submitLoadingToggle = false;
      });
      if (data.status == Status.COMPLETED) {
        /// update user credit
        BlocProvider.of<EntityBloc>(context).add(EntityUpdate());

        /// update doctor plan if needed

        /// pop to prev page
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
          _visitTypeWidget(
              VISIT_METHOD,
              {0: "متنی", 1: "صوتی", 2: "تصویری"}..removeWhere((key, value) {
                  if (widget.doctorEntity.plan.visitMethod.contains(key)) {
                    return false;
                  }
                  return true;
                }),
              width: 120,
              height: 50,
              fontSize: 16),
          ALittleVerticalSpace(),
          // _visitTypeWidget(
          //     VISIT_DURATION_PLAN,
          //     {0: "پایه ۱۵ دقیقه", 1: "تکمیلی ۳۰ دقیقه", 2: "طولانی ۴۵ دقیقه"}..removeWhere((key, value) {
          //         if (widget.doctorEntity.plan.visitDurationPlan
          //             .contains(key)) {
          //           return false;
          //         }
          //         return true;
          //       }),
          //     width: 160,
          //     height: 50,
          //     fontSize: 14),
          // ALittleVerticalSpace(),
          // _visitDurationTimeWidget(),
          // ALittleVerticalSpace(),
          _enableVisitTimeWidget(),
          AnimatedSize(
            vsync: this,
            duration: Duration(milliseconds: 400),
            child: visitTimeChecked
                ? VisitDateTimePicker(
                    dateTextController,
                    timeTextController,
                    widget.doctorEntity,
                    timeSelectorType: TimeSelectorType.Table,
                    planDurationInMinute: _planMinuteDurationController,
                    onBlocTap: () {
                      setState(() {
                        /// to update cost every time duration changes
                      });
                    },
                  )
                : SizedBox(),
          ),
          ALittleVerticalSpace(),
          _priceAndDurationWidget(),
          ALittleVerticalSpace(),
          _acceptPolicyWidget(),
          ALittleVerticalSpace(),
          _submitWidget(),
          ALittleVerticalSpace(),
        ]),
      ),
    );
  }

  // AutoText _visitDurationTimeWidget() {
  //   return AutoText(
  //       "ویزیت مجازی حداکثر ${replaceFarsiNumber((VisitDurationPlan.values[typeSelected[VISIT_DURATION_PLAN]].duration).toString())} دقیقه می‌باشد",
  //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
  // }

  _visitTypeWidget(String title, Map<int, String> items,
      {double width = 120, double height = 40, double fontSize = 17}) {
    List<Widget> res = [];
    items.forEach((key, value) {
      res.add(Padding(
        padding: const EdgeInsets.only(right: 4.0, left: 4.0),
        child: ActionButton(
          width: width,
          height: height,
          fontSize: fontSize,
          color: typeSelected[title] == key ? IColors.themeColor : Colors.grey,
          title: items[key],
          callBack: () {
            setState(() {
              typeSelected[title] = key;
            });
          },
        ),
      ));
    });
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AutoText(
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
          children: res,
        )
      ],
    );
  }

  _priceAndDurationWidget() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AutoText("دقیقه", style: TextStyle(fontSize: 16)),
              SizedBox(width: 5),
              AutoText(replaceFarsiNumber(_calculateTime()),
                  style: TextStyle(
                      color: IColors.themeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              SizedBox(width: 5),
              AutoText("مدت زمان ویزیت", style: TextStyle(fontSize: 16))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AutoText("ریال", style: TextStyle(fontSize: 16)),
              SizedBox(width: 5),
              AutoText(replaceFarsiNumber(_calculateVisitCost()),
                  style: TextStyle(
                      color: IColors.themeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              SizedBox(width: 5),
              AutoText("قیمت نهایی", style: TextStyle(fontSize: 16))
            ],
          ),
        ],
      );

  int getVisitDurationPlanFromVisitSelectedMinutes() {
    try {
      int minutes = int.parse(_planMinuteDurationController.text);
      int planDuration = minutes ~/ DoctorPlan.hourMinutePart;
      return planDuration - 1;
    } catch (e) {}
    return null;
  }

  String _calculateVisitCost() {
    int cost = 0;
    if (typeSelected[VISIT_METHOD] == VisitMethod.TEXT.index) {
      cost = widget.doctorEntity.plan.baseTextPrice;
    } else if (typeSelected[VISIT_METHOD] == VisitMethod.VOICE.index) {
      cost = widget.doctorEntity.plan.baseVoicePrice;
    } else if (typeSelected[VISIT_METHOD] == VisitMethod.VIDEO.index) {
      cost = widget.doctorEntity.plan.baseVideoPrice;
    }
    // cost *= (typeSelected[VISIT_DURATION_PLAN] + 1);
    cost *= ((getVisitDurationPlanFromVisitSelectedMinutes() ?? -1) + 1);

    return cost.toString();
  }

  String _calculateTime() {
    return _planMinuteDurationController.text == ""
        ? "0"
        : _planMinuteDurationController.text;
  }

//  _timeSelectionWidget() => Visibility(
//        visible: visitTimeChecked,
//        child: Column(
//          children: <Widget>[
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//                AutoText(
//                  "ساعت",
//                  textAlign: TextAlign.right,
//                ),
//                Icon(Icons.access_time, size: 30),
//                SizedBox(width: 50),
//                AutoText("تاریخ"),
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
        AutoText(
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

  _acceptPolicyWidget() => GestureDetector(
        onTap: () {
          showDescriptionAlertDialog(context,
              title: Strings.privacyAndPolicy,
              description: Strings.policyDescription, action: () {
            setState(() {
              policyChecked = !policyChecked;
            });
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width - 80,
                child: AutoText(
                  Strings.virtualVisitPrivacyPolicyMessage,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 10),
                  maxLines: 3,
                ),
              ),
              Checkbox(
                activeColor: IColors.themeColor,
                value: policyChecked,
                onChanged: (d) {
                  showDescriptionAlertDialog(context,
                      title: Strings.privacyAndPolicy,
                      description: Strings.policyDescription, action: () {
                    setState(() {
                      policyChecked = !policyChecked;
                    });
                  });
                },
              ),
            ],
          ),
        ),
      );

  _submitWidget() => ActionButton(
        color: policyChecked ? IColors.themeColor : Colors.grey,
        title: !visitTimeChecked ? "ویزیت مجازی هم‌اکنون" : "ویزیت مجازی",
        callBack: _submit,
        loading: this.submitLoadingToggle,
      );

  _nowVisitCondition() => _isDoctorOnline() && !visitTimeChecked;

  _isDoctorOnline() => widget.doctorEntity.user.online == 1;

  void _submit() {
    /// TODO amir: clean this part. It is so messy;'
    if (this.submitLoadingToggle) return;
    if (!policyChecked) return;
    if (visitTimeChecked) {
      String currentTime = DateTime.now().hour.toString() +
          ":" +
          DateTime.now().minute.toString();
      if (dateTextController.text.isEmpty) {
        /// empty date
        showOneButtonDialog(
            context, Strings.enterVisitDateMessage, Strings.okAction, () {});
      } else if (timeTextController.text.isEmpty ||
          timeTextController.text == "") {
        /// empty time
        showOneButtonDialog(context, Strings.emptyStartVisitTimeMessage,
            Strings.okAction, () {});
      } else if (getTimeMinute(timeTextController.text) <
              getTimeMinute(currentTime) &&
          getTodayInJalaliString() == dateTextController.text) {
        /// invalid time
        showOneButtonDialog(context, Strings.pastStartVisitTimeMessage,
            Strings.okAction, () {});
      } else {
        /// sending request
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
        // typeSelected[VISIT_DURATION_PLAN],
        getVisitDurationPlanFromVisitSelectedMinutes(),
        convertToGeorgianDate(getTodayInJalaliString()) +
            "T" +
            "${DateTime.now().hour}:${DateTime.now().minute}" +
            "+04:30");
    setState(() {
      submitLoadingToggle = true;
    });
  }

  void sendVisitRequest() {
    /// TODO amir: timeTextController.text should be used here later
    String startTime = timeTextController.text.split("-")[0];
    // int startMinute = getTimeMinute(startTime);

    // String endTime = timeTextController.text.split("-")[1];
    // int endMinute = getTimeMinute(endTime);
    // if (endMinute < startMinute) {
    //   endMinute += 24 * 60;
    // }
    // int duration = getTimeMinute(endTime) - getTimeMinute(startTime);

    // String visitDuration = "+" + convertMinuteToTimeString(duration);
    String timeZone = "+03:30";
    _bloc.visitRequest(
        widget.doctorEntity.id,
        1,
        typeSelected[VISIT_METHOD],
        // typeSelected[VISIT_DURATION_PLAN],
        getVisitDurationPlanFromVisitSelectedMinutes(),
        convertToGeorgianDate(dateTextController.text) +
            "T" +
            startTime +
            timeZone);
    setState(() {
      submitLoadingToggle = true;
    });
  }

  String getEnabledTimeString(DoctorPlan plan) {
    List<String> availableDaysList = [];

    /// TODO amir DoctorPlan Incomplete
    // for (int day in plan.availableDays) {
    //   availableDaysList.add(WeekDay.values[day].name);
    // }
    String availableDays = availableDaysList.join("، ") + " ";
    String workTimes = "";

    /// TODO DoctorPlan Incomplete
    // for (WorkTimes workTime in plan.weeklyWorkTimes) {
    //   workTimes += "از " +
    //       workTime.startTime.split(":")[0] +
    //       " تا " +
    //       (int.parse(workTime.endTime.split(":")[0]) + 1).toString() +
    //       "\n";
    // }
    return replaceFarsiNumber("درخواست ویزیت به پزشک مورد نظر در روزهای " +
        availableDays +
        "امکان پذیر است " +
        "\n"
            "ساعات ارائه ویزیت  " +
        "\n" +
        workTimes);
  }
}
