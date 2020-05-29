import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/DoctorSummaryWidget.dart';
import 'package:docup/ui/widgets/TimeSelectionWidget.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const VISIT_METHOD = "نوع مشاوره";
const VISIT_DURATION_PLAN = "مدت زمان مشاوره";

enum VisitMethod { TEXT, VOICE, VIDEO }

enum VisitDurationPlan { BASE, SUPPLEMENTARY, LONG }

extension VisitDurationPlanExtension on VisitDurationPlan {
  int get duration {
    switch (this) {
      case VisitDurationPlan.BASE:
        return 30;
      case VisitDurationPlan.SUPPLEMENTARY:
        return 60;
      case VisitDurationPlan.LONG:
        return 90;
      default:
        return 30;
    }
  }
}

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
        if (data.message.startsWith("Unauthorised")) {
          showOneButtonDialog(
              context,
              Strings.notEnoughCreditMessage,
              Strings.addCreditAction,
              () => widget.onPush(
                  NavigatorRoutes.account, _calculateVisitCost()));
        } else {
          toast(context, data.message);
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
          _visitTypeWidget(VISIT_METHOD, ["متنی", "تصویری"]),
          ALittleVerticalSpace(),
          _visitTypeWidget(VISIT_DURATION_PLAN, ["پایه", "تکمیلی", "طولانی"]),
          ALittleVerticalSpace(),
          _visitDurationTimeWidget(),
          ALittleVerticalSpace(),
          _priceWidget(),
          ALittleVerticalSpace(),
          _enableVisitTimeWidget(),
          _timeSelectionWidget(),
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

  _visitTypeWidget(String title, List<String> items) => Column(
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
                Padding(
                  padding: const EdgeInsets.only(right: 4.0, left: 4.0),
                  child: ActionButton(
                    width: 120,
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
              style: TextStyle(color: IColors.themeColor, fontSize: 18)),
          SizedBox(width: 5),
          Text("قیمت نهایی", style: TextStyle(fontSize: 16))
        ],
      );

  String _calculateVisitCost() {
    int cost = 0;
    if (typeSelected[VISIT_METHOD] == VisitMethod.TEXT.index) {
      cost = widget.doctorEntity.plan.baseTextPrice;
    } else if (typeSelected[VISIT_METHOD] == VisitMethod.VIDEO.index - 1) {
      cost = widget.doctorEntity.plan.baseVideoPrice;
    }
    cost *= (typeSelected[VISIT_DURATION_PLAN] + 1);
    return cost.toString();
  }

  _timeSelectionWidget() => Visibility(
        visible: visitTimeChecked,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "ساعت",
                  textAlign: TextAlign.right,
                ),
                Icon(Icons.access_time, size: 30),
                SizedBox(width: 50),
                Text("تاریخ"),
                Icon(Icons.calendar_today),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: TimeSelectionWidget(
                      timeTextController: timeTextController),
                ),
                SizedBox(width: 50),
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: TextField(
                      controller: dateTextController,
                      onTap: () => showDatePickerDialog(
                          context,
                          widget.doctorEntity.plan.availableDays,
                          dateTextController)),
                ),
              ],
            )
          ],
        ),
      );

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
        title: _isDoctorOnline() ? "ویزیت مجازی هم‌اکنون" : "ویزیت مجازی",
        callBack: _submit,
      );

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
        sendVisitRequest();
      } else {
        showOneButtonDialog(
            context, Strings.offlineDoctorMessage, Strings.okAction, () {});
      }
    }
  }

  void sendVisitRequest() {
    DateTime doctorStartTime = getDateAndTimeFromWS(
        convertToGeorgianDate(dateTextController.text) +
            "T" +
            widget.doctorEntity.plan.startTime);
    DateTime doctorEndTime = getDateAndTimeFromWS(
        convertToGeorgianDate(dateTextController.text) +
            "T" +
            widget.doctorEntity.plan.endTime);
    DateTime selectedTime = getDateAndTimeFromJalali(
        dateTextController.text, timeTextController.text);
    if (selectedTime.isAfter(doctorStartTime) &&
        selectedTime.isBefore(doctorEndTime)) {
      _bloc.visitRequest(
          widget.doctorEntity.id,
          1,
          typeSelected[VISIT_METHOD],
          typeSelected[VISIT_DURATION_PLAN],
          convertToGeorgianDate(dateTextController.text) +
              "T" +
              timeTextController.text +
              "+04:30");
    } else {
      showOneButtonDialog(
          context,
          "زمان انتخاب شده خالی نیست. لطفا زمان دیگری را برای ویزیت انتخاب کنید " +
              "\n" +
              "پزشک ساعت ${replaceFarsiNumber(widget.doctorEntity.plan.startTime)} الی  ${replaceFarsiNumber(widget.doctorEntity.plan.endTime)} را تخصیص داده است ",
          "متوجه شدم",
          () {});
    }
  }
}
