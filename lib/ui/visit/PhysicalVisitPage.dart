import 'package:docup/blocs/DoctorInfoBloc.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'VisitUtils.dart';

class PhysicalVisitPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final Function(String, dynamic) onPush;

  PhysicalVisitPage({Key key, this.doctorEntity, this.onPush})
      : super(key: key);

  @override
  _PhysicalVisitPageState createState() => _PhysicalVisitPageState();
}

class _PhysicalVisitPageState extends State<PhysicalVisitPage>
    with TickerProviderStateMixin {
  DoctorInfoBloc _bloc = DoctorInfoBloc();

  Map<String, String> typeSelected = {
    VISIT_METHOD: "حضوری",
    TIME_SELECTION: ""
  };
  bool policyChecked = false;
  TextEditingController dateTextController = TextEditingController();
  TextEditingController timeTextController = TextEditingController();
  int timeIndexSelected = -1;

  @override
  void initState() {
    dateTextController.text = getTomorrowInJalali();
    _bloc.visitRequestStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        showOneButtonDialog(context, Strings.physicalVisitRequestedMessage,
            "در انتظار تایید پزشک", () => Navigator.pop(context),
            color: Colors.black54);
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
          AnimatedSize(
              duration: Duration(milliseconds: 400),
              vsync: this,
              child: VisitDateTimePicker(
                dateTextController,
                timeTextController,
                widget.doctorEntity,
                scrollableTimeSelectorType: true,
              )),
          ALittleVerticalSpace(),
//          _labelWidget(TIME_SELECTION),
//          ALittleVerticalSpace(),
//          _timesWidget(TIME_SELECTION, _getVisitTimes()),
          ALittleVerticalSpace(),
          _acceptPolicyWidget(),
          ALittleVerticalSpace(),
          _submitWidget(),
          ALittleVerticalSpace(),
        ]),
      ),
    );
  }

  _getVisitTimes() {
    if (widget.doctorEntity.plan.workTimes == null) return [];
    List<String> visitTimes = [];
    for (WorkTimes workTime in widget.doctorEntity.plan.workTimes) {
      final startHour = workTime.startTime.split(":")[0];
      final endHour = int.parse(workTime.endTime.split(":")[0]) + 1;
      visitTimes.add(replaceFarsiNumber("از " + startHour + " تا $endHour"));
    }
    return visitTimes.toList();
  }

  _submitWidget() => ActionButton(
        color: policyChecked ? IColors.themeColor : Colors.grey,
        title: "رزرو نوبت",
        callBack: _sendVisitRequest,
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

  _timesWidget(String title, List<String> items) => Container(
        height: 50,
        child: ListView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            for (var index = 0; index < items.length; index++)
              Wrap(
                children: <Widget>[
                  Padding(
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
                  ),
                ],
              ),
          ],
        ),
      );

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
    String currentTime =
        DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString();
    if (!policyChecked) return;
    if (dateTextController.text.isEmpty) {
      /// empty date
      showOneButtonDialog(
          context, Strings.enterVisitDateMessage, Strings.okAction, () {});
    } else if (timeTextController.text.isEmpty ||
        timeTextController.text.split("-").length != 2 ||
        timeTextController.text.split("-")[0] == "") {
      /// empty time
      showOneButtonDialog(
          context, Strings.emptyStartVisitTimeMessage, Strings.okAction, () {});
    } else if (getTimeMinute(timeTextController.text.split("-")[0]) <
            getTimeMinute(currentTime) &&
        getTodayInJalaliString() == dateTextController.text) {
      /// invalid time
      showOneButtonDialog(
          context, Strings.pastStartVisitTimeMessage, Strings.okAction, () {});
    } else {
      sendVisitRequest();
    }
  }

  _getStartTime(int timeIndexSelected) {
    return widget.doctorEntity.plan.workTimes[timeIndexSelected].startTime;
  }

  void sendVisitRequest() {
    /// TODO amir: timeTextController.text should be used here later
    String startTime = timeTextController.text.split("-")[0];
    int startMinute = getTimeMinute(startTime);
    String endTime = timeTextController.text.split("-")[1];
    int endMinute = getTimeMinute(endTime);
    if (endMinute < startMinute) {
      endMinute += 24 * 60;
    }
    int duration = getTimeMinute(endTime) - getTimeMinute(startTime);

    String visitDuration = "+" + convertMinuteToTimeString(duration);
    String timeZone = "+03:30";
    _bloc.visitRequest(
        widget.doctorEntity.id,
        0,
        0,
        0,
        convertToGeorgianDate(dateTextController.text) +
            "T" +
            startTime +
            timeZone);
  }
}
