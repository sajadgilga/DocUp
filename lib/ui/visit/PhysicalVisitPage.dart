import 'package:Neuronio/blocs/DoctorInfoBloc.dart';
import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/DoctorPlan.dart';
import 'package:Neuronio/networking/CustomException.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/ContactUsAndPolicy.dart';
import 'package:Neuronio/ui/widgets/DoctorSummaryWidget.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/ui/widgets/VisitDateTimePicker.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhysicalVisitPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final int screeningId;
  final Function(String, dynamic) onPush;

  PhysicalVisitPage({Key key, this.doctorEntity, this.onPush, this.screeningId})
      : super(key: key);

  @override
  _PhysicalVisitPageState createState() => _PhysicalVisitPageState();
}

class _PhysicalVisitPageState extends State<PhysicalVisitPage>
    with TickerProviderStateMixin {
  DoctorInfoBloc _bloc = DoctorInfoBloc();
  bool submitLoadingToggle = false;

  Map<String, int> typeSelected = {
    // VISIT_METHOD: VirtualVisitMethod.TEXT.index,
    // VISIT_DURATION_PLAN: VisitDurationPlan.BASE.index
  };

  bool policyChecked = false;
  TextEditingController dateTextController = TextEditingController();
  TextEditingController timeTextController = TextEditingController();
  int timeIndexSelected = -1;

  /// plan duration: visit time in minute
  final TextEditingController _planMinuteDurationController =
      TextEditingController();

  @override
  void initState() {
    // try {
    //   typeSelected[VISIT_DURATION_PLAN] =
    //       widget.doctorEntity.plan.visitDurationPlan.first;
    // } catch (e) {}

    _bloc.visitRequestStream.listen((data) {
      setState(() {
        submitLoadingToggle = false;
      });
      if (data.status == Status.COMPLETED) {
        /// update user credit
        BlocProvider.of<EntityBloc>(context).add(EntityUpdate());

        /// update doctor plan if needed

        /// pop to prev page
        showOneButtonDialog(context, Strings.physicalVisitRequestedMessage,
            Strings.waitingForApproval, () => Navigator.pop(context));
      } else if (data.status == Status.ERROR) {
        if (data.error is ApiException) {
          ApiException apiException = data.error;
          if (apiException.getCode() == 602) {
            showOneButtonDialog(
                context,
                Strings.notEnoughCreditMessage,
                Strings.addCreditAction,
                () => widget.onPush(NavigatorRoutes.account, "10000"));
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
          _labelWidget("نوع مشاوره:"),
          ALittleVerticalSpace(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ActionButton(
                  width: 120,
                  color: IColors.themeColor,
                  title: "حضوری",
                  callBack: () {}),
            ],
          ),
          ALittleVerticalSpace(),
          // ALittleVerticalSpace(),
          // _visitTypeWidget(
          //     VISIT_DURATION_PLAN,
          //     {0: "پایه ۱۵ دقیقه", 1: "تکمیلی ۳۰ دقیقه", 2: "طولانی ۴۵ دقیقه"}
          //       ..removeWhere((key, value) {
          //         if (widget.doctorEntity.plan.visitDurationPlan
          //             .contains(key)) {
          //           return false;
          //         }
          //         return true;
          //       }),
          //     width: 160,
          //     height: 50,
          //     fontSize: 14),
          // _doctorDurationPlanInfo(),
          AnimatedSize(
            duration: Duration(milliseconds: 400),
            vsync: this,
            child: VisitDateTimePicker(
              dateTextController,
              timeTextController,
              widget.doctorEntity?.plan,
              widget.doctorEntity?.plan?.physicalVisitType,
              timeSelectorType: TimeSelectorType.Table,
              planDurationInMinute: _planMinuteDurationController,
              onBlocTap: () {
                setState(() {
                  /// to update cost every time duration changes
                });
              },
            ),
          ),
          ALittleVerticalSpace(),
//          _labelWidget(TIME_SELECTION),
//          ALittleVerticalSpace(),
//          _timesWidget(TIME_SELECTION, _getVisitTimes()),
          _priceAndDurationWidget(),
          ALittleVerticalSpace(),
          ALittleVerticalSpace(),
          _acceptPolicyWidget(),
          ALittleVerticalSpace(),
          _submitWidget(),
          ALittleVerticalSpace(),
        ]),
      ),
    );
  }

  Widget _doctorDurationPlanInfo() {
    List<Widget> res = [];
    widget.doctorEntity.plan.physicalVisitDurationPlan?.forEach((values) {
      res.add(Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            AutoText(
              ((values + 1) * DoctorPlan.hourMinutePart).toString() +
                  " " +
                  "دقیقه ای",
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ));
    });
    if ((widget.doctorEntity?.plan?.physicalVisitDurationPlan ?? []).length ==
        0) {
      res.add(Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            AutoText(
              "زمانی مورد تایید پزشک وجود ندارد!",
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ));
    }
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    AutoText(
                      "نوع زمان مورد تایید پزشک",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ] +
            res,
      ),
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
          /// TODO
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
    int cost = widget.doctorEntity.plan.basePhysicalVisitPrice;
    // cost *= (typeSelected[VISIT_DURATION_PLAN] + 1);
    cost *= ((getVisitDurationPlanFromVisitSelectedMinutes() ?? -1) + 1);

    return cost.toString();
  }

  String _calculateTime() {
    return _planMinuteDurationController.text == ""
        ? "0"
        : _planMinuteDurationController.text;
  }

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

  // _getVisitTimes() {
  //   if (widget.doctorEntity.plan.weeklyWorkTimes == null) return [];
  //   List<String> visitTimes = [];
  //
  //
  //   // for (WorkTimes workTime in widget.doctorEntity.plan.weeklyWorkTimes) {
  //   //   final startHour = workTime.startTime.split(":")[0];
  //   //   final endHour = int.parse(workTime.endTime.split(":")[0]) + 1;
  //   //   visitTimes.add(replaceFarsiNumber("از " + startHour + " تا $endHour"));
  //   // }
  //   return visitTimes.toList();
  // }

  _submitWidget() => ActionButton(
        color: policyChecked ? IColors.themeColor : Colors.grey,
        title: "رزرو نوبت",
        callBack: _sendVisitRequest,
        loading: this.submitLoadingToggle,
      );

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width - 80,
              child: AutoText(
                Strings.physicalVisitPrivacyPolicyMessage,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 10),
                maxLines: 2,
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
      );

  //
  // _timesWidget(String title, List<String> items) => Container(
  //       height: 50,
  //       child: ListView(
  //         reverse: true,
  //         scrollDirection: Axis.horizontal,
  //         children: <Widget>[
  //           for (var index = 0; index < items.length; index++)
  //             Wrap(
  //               children: <Widget>[
  //                 Padding(
  //                   padding: const EdgeInsets.only(right: 4.0, left: 4.0),
  //                   child: ActionButton(
  //                     width: 120,
  //                     color: typeSelected[title] == items[index]
  //                         ? IColors.themeColor
  //                         : Colors.grey,
  //                     title: items[index],
  //                     callBack: () {
  //                       setState(() {
  //                         timeIndexSelected = index;
  //                         typeSelected[title] = items[index];
  //                       });
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //         ],
  //       ),
  //     );

  _labelWidget(String title) => Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            AutoText(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      );

  _sendVisitRequest() {
    /// TODO amir: clean this part. It is so messy;
    if (this.submitLoadingToggle) return;
    if (!policyChecked) return;
    DateTime now = DateTimeService.getCurrentDateTime();
    String currentTime = now.hour.toString() + ":" + now.minute.toString();
    if (dateTextController.text.isEmpty) {
      /// empty date
      showOneButtonDialog(
          context, Strings.enterVisitDateMessage, Strings.okAction, () {});
    } else if (timeTextController.text.isEmpty ||
        timeTextController.text == "") {
      /// empty time
      showOneButtonDialog(
          context, Strings.emptyStartVisitTimeMessage, Strings.okAction, () {});
    } else if (DateTimeService.getTimeMinute(timeTextController.text) <
            DateTimeService.getTimeMinute(currentTime) &&
        DateTimeService.getTodayInJalaliString() == dateTextController.text) {
      /// invalid time
      showOneButtonDialog(
          context, Strings.pastStartVisitTimeMessage, Strings.okAction, () {});
    } else if (!widget.doctorEntity.plan.physicalVisitDurationPlan
        .contains(getVisitDurationPlanFromVisitSelectedMinutes())) {
      /// invalid duration plan
      if (widget.doctorEntity.plan.physicalVisitDurationPlan.length == 0) {
        showOneButtonDialog(
            context,
            Strings.invalidDurationPlan_EmptyDurationPlan,
            Strings.okAction,
            () {});
      } else {
        showOneButtonDialog(
            context,
            Strings.invalidDurationPlan_Plans[0] +
                " " +
                widget.doctorEntity.plan.physicalVisitDurationPlan
                    .map(
                        (e) => ((e + 1) * DoctorPlan.hourMinutePart).toString())
                    .join("و ") +
                " " +
                Strings.invalidDurationPlan_Plans[2],
            Strings.okAction,
            () {});
      }
    } else {
      sendVisitRequest();
    }
  }

  // _getStartTime(int timeIndexSelected) {
  //   // return widget.doctorEntity.plan.weeklyWorkTimes[timeIndexSelected].startTime;
  // }

  void sendVisitRequest() {
    /// TODO amir: timeTextController.text should be used here later
    String startTime = timeTextController.text.split("-")[0];
    int startMinute = DateTimeService.getTimeMinute(startTime);
    // String endTime = timeTextController.text.split("-")[1];
    // int endMinute = getTimeMinute(endTime);
    // if (endMinute < startMinute) {
    //   endMinute += 24 * 60;
    // }
    // int duration = getTimeMinute(endTime) - getTimeMinute(startTime);
    //
    // String visitDuration = "+" + convertMinuteToTimeString(duration);
    String timeZone = "+03:30";
    _bloc.visitRequest(
        widget.screeningId,
        widget.doctorEntity.id,
        0,
        0,
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
}
