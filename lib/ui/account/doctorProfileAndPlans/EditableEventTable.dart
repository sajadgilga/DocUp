import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorPlan.dart';
import 'package:Neuronio/ui/visit/VisitUtils.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/TimeSelectionWidget.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/calendar_views-0.5.2/lib/day_view.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/calendar_views-0.5.2/lib/days_page_view.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shamsi_date/shamsi_date.dart';

class EditableDoctorPlanEventTable extends StatefulWidget {
  bool smallPreviewFlag;
  DoctorPlan plan;
  bool showEventTitle;
  int daysPerPage;
  List<int> availableVisitTypes;

  EditableDoctorPlanEventTable(this.plan, this.availableVisitTypes,
      {this.showEventTitle = true,
      this.daysPerPage = 4,
      this.smallPreviewFlag = false});

  /// state managing
  /// this parameter should be here cause we need updating state with dirty every time prent calls setstate
  bool isDirty = true;

  @override
  State createState() => new _EditableDoctorPlanEventTableState();
}

class _EditableDoctorPlanEventTableState
    extends State<EditableDoctorPlanEventTable> {
  DataSourceWorkTime selectedObject;
  Map<DateTime, DataSourceDailyWorkTimes> _daysWorkTimes;

  void updateStateWithDirtyDaysWorkTime() {
    setState(() {
      widget.isDirty = true;
    });
  }

  Map<DateTime, DataSourceDailyWorkTimes> get daysWorkTimes {
    if (widget.isDirty) {
      _daysWorkTimes =
          widget.plan?.totalWorkTimes ?? <DateTime, DataSourceDailyWorkTimes>{};
      widget.isDirty = false;
    }
    return _daysWorkTimes;
  }

  @override
  void initState() {
    super.initState();
  }

  String _minuteOfDayToHourMinuteString(int minuteOfDay) {
    return "${(minuteOfDay ~/ 60).toString().padLeft(2, "0")}"
        ":"
        "${(minuteOfDay % 60).toString().padLeft(2, "0")}";
  }

  List<StartDurationItem> _getEventsOfDay(DateTime day) {
    List<DataSourceWorkTime> events = [];
    daysWorkTimes.forEach((dateTime, daysWorkTimes) {
      if (DateTimeService.getDateStringFormDateTime(day) ==
          DateTimeService.getDateStringFormDateTime(dateTime)) {
        events = daysWorkTimes?.dataSourceWorkTimes;
      }
    });

    return events
        .map(
          (event) => new StartDurationItem(
            startMinuteOfDay: event.startMinuteOfDay,
            duration: event.duration,
            builder: (context, itemPosition, itemSize) => _eventBuilder(
              context,
              itemPosition,
              itemSize,
              event,
            ),
          ),
        )
        .toList();
  }

  Widget speedDialFloatingButton() {
    return SpeedDial(
      // both default to 16
      marginRight: 18,
      marginBottom: 20,
      animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: IconThemeData(size: 22.0),
      // this is ignored if animatedIcon is non null
      // child: Icon(Icons.add),
      visible: widget.availableVisitTypes.contains(0) ||
          widget.availableVisitTypes.contains(1),
      // If true user is forced to close dial manually
      // by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 8.0,
      shape: CircleBorder(),
      children: ((widget.availableVisitTypes.contains(0))
              ? [
                  SpeedDialChild(
                    labelWidget: Container(
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                      child: AutoText(
                        "اضافه کردن زمان ویزیت حضوری",
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                    child: Icon(Icons.add),
                    backgroundColor: IColors.blue,
                    onTap: () {
                      AddWorkTimeDataSourceDialog ad =
                          AddWorkTimeDataSourceDialog.AddDialog(context, 0,
                              widget.plan, updateStateWithDirtyDaysWorkTime);
                      ad.showWorkTimeDialog();
                    },
                  )
                ]
              : <SpeedDialChild>[]) +
          ((widget.availableVisitTypes.contains(1))
              ? [
                  SpeedDialChild(
                    child: Icon(Icons.add),
                    labelWidget: Container(
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                      child: AutoText(
                        "اضافه کردن زمان ویزیت مجازی",
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                    backgroundColor: IColors.green,
                    onTap: () {
                      AddWorkTimeDataSourceDialog ad =
                          AddWorkTimeDataSourceDialog.AddDialog(context, 1,
                              widget.plan, updateStateWithDirtyDaysWorkTime);
                      ad.showWorkTimeDialog();
                    },
                  )
                ]
              : <SpeedDialChild>[]),
    );
  }

  Widget _daysPageBuilder(BuildContext context, List<DateTime> days) {
    Map<String, DataSourceDailyWorkTimes> daysWorkTimesPartition = {};

    /// initialization
    days.forEach((element) {
      String dateString = DateTimeService.getDateStringFormDateTime(element);
      daysWorkTimesPartition[dateString] =
          DataSourceDailyWorkTimes(element, []);
    });

    // daysWorkTimes.forEach((dateTime, daysWorkTimes) {
    //   String dateString = DateTimeService.getDateStringFormDateTime(dateTime);
    //   if (daysStrings.contains(dateString)) {
    //     daysWorkTimesPartition[dateString] = daysWorkTimes;
    //   }
    // });

    return new Container(
      child: new DayViewEssentials(
        properties: new DayViewProperties(
            days: daysWorkTimesPartition.keys
                .map((e) => DateTimeService.getDateTimeFormDateString(e))
                .toList()),
        widths: DayViewWidths(
          daySeparationAreaWidth: 2,
          timeIndicationAreaWidth: 30,
          mainAreaStartPadding: 0,
          mainAreaEndPadding: 0,
        ),
        child: new Column(
          children: <Widget>[
            new Container(
              color: Colors.grey[200],
              child: new DayViewDaysHeader(
                headerItemBuilder: _headerItemBuilder,
              ),
            ),
            new Expanded(
              child: new SingleChildScrollView(
                child: new DayViewSchedule(
                  heightPerMinute: 0.5,
                  components: <ScheduleComponent>[
                    new TimeIndicationComponent.intervalGenerated(
                      generatedTimeIndicatorBuilder:
                          _generatedTimeIndicatorBuilder,
                    ),
                    new SupportLineComponent.intervalGenerated(
                      generatedSupportLineBuilder: _generatedSupportLineBuilder,
                    ),
                    new DaySeparationComponent(
                      generatedDaySeparatorBuilder:
                          _generatedDaySeparatorBuilder,
                    ),
                    new EventViewComponent(
                      getEventsOfDay: _getEventsOfDay,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerItemBuilder(BuildContext context, DateTime day) {
    Jalali jalali = DateTimeService.getJalaliformDateTime(day);
    return new Container(
      color: Colors.grey[300],
      padding: new EdgeInsets.symmetric(vertical: 4.0),
      child: new Column(
        children: <Widget>[
          new Text(
            "${Strings.persianDaysSigns[jalali.weekDay - 1]}",
            style: new TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
          new Text(
            "${jalali.day}",
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Positioned _generatedTimeIndicatorBuilder(
    BuildContext context,
    ItemPosition itemPosition,
    ItemSize itemSize,
    int minuteOfDay,
  ) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemSize.width,
      height: itemSize.height,
      child: new Container(
        child: new Center(
          child: new Text(
              _minuteOfDayToHourMinuteString(minuteOfDay).split(":")[0]),
        ),
      ),
    );
  }

  Positioned _generatedSupportLineBuilder(
    BuildContext context,
    ItemPosition itemPosition,
    double itemWidth,
    int minuteOfDay,
  ) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemWidth,
      child: new Container(
        height: 0.7,
        color: Colors.grey[700],
      ),
    );
  }

  Positioned _generatedDaySeparatorBuilder(
    BuildContext context,
    ItemPosition itemPosition,
    ItemSize itemSize,
    int daySeparatorNumber,
  ) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemSize.width,
      height: itemSize.height,
      child: new Center(
        child: new Container(
          width: 0.7,
          color: Colors.grey,
        ),
      ),
    );
  }

  Positioned _eventBuilder(
    BuildContext context,
    ItemPosition itemPosition,
    ItemSize itemSize,
    DataSourceWorkTime event,
  ) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemSize.width,
      height: itemSize.height,
      child: GestureDetector(
        onTap: widget.smallPreviewFlag
            ? null
            : () {
                AddWorkTimeDataSourceDialog dialog =
                    AddWorkTimeDataSourceDialog.DetailDialog(context, event,
                        widget.plan, updateStateWithDirtyDaysWorkTime);
                dialog.showWorkTimeDialog();
                setState(() {
                  selectedObject = event;
                });
              },
        child: new Container(
          decoration: BoxDecoration(
              border: selectedObject?.isEqual(event) ?? false
                  ? Border.all(width: 4, color: IColors.yelllow)
                  : null,
              color: event.color ?? IColors.themeColor),
          margin: new EdgeInsets.only(left: 1.0, right: 1.0, bottom: 1.0),
          padding: new EdgeInsets.all(3.0),
          child: widget.showEventTitle
              ? new AutoText(
                  "${event.title}",
                )
              : SizedBox(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DaysPageController _daysPageController = new DaysPageController(
      firstDayOnInitialPage: DateTimeService.getCurrentDateTime(),
      daysPerPage: widget.daysPerPage,
    );
    if (widget.smallPreviewFlag) {
      return new DaysPageView(
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        reverse: false,
        controller: _daysPageController,
        pageBuilder: _daysPageBuilder,
      );
    } else {
      return Scaffold(
        floatingActionButton: speedDialFloatingButton(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PageTopLeftIcon(
              topLeft: Icon(
                Icons.arrow_back,
                size: 25,
              ),
              onTap: () {
                Navigator.pop(context);
              },
              topRightFlag: true,
              topRight: DocUpHeader(
                title: "زمان‌های ویزیت پزشک",
                docUpLogo: false,
              ),
              topLeftFlag: CrossPlatformDeviceDetection.isIOS,
            ),
            Expanded(
              child: new DaysPageView(
                scrollDirection: Axis.horizontal,
                pageSnapping: true,
                reverse: false,
                controller: _daysPageController,
                pageBuilder: _daysPageBuilder,
              ),
            ),
          ],
        ),
      );
    }
  }
}

class AddWorkTimeDataSourceDialog {
  bool detailMode = false;
  int visitType;
  BuildContext dialogContext;
  BuildContext context;
  StateSetter alertStateSetter;
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  bool addFor4Weeks = false;
  DoctorPlan plan;
  Function onApplyChange;

  final _formKey = GlobalKey<FormState>();

  AddWorkTimeDataSourceDialog.AddDialog(
      this.context, this.visitType, this.plan, this.onApplyChange);

  AddWorkTimeDataSourceDialog.DetailDialog(
      this.context, DataSourceWorkTime event, this.plan, this.onApplyChange) {
    detailMode = true;

    dateController.text =
        DateTimeService.getJalaliStringFormGeorgianDateTimeString(
            event.dateString);
    visitType = event.visitType;
    startTimeController.text = event.workTime.startTime;
    endTimeController.text = event.workTime.endTime;
  }

  void showWorkTimeDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter dialogStateSetter) {
              alertStateSetter = dialogStateSetter;
              dialogContext = context;
              return Container(
                constraints: BoxConstraints.tightFor(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        constraints: BoxConstraints.tightFor(
                            width: MediaQuery.of(context).size.width * 0.8),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _title(),
                              Container(
                                child: _dateWidget(),
                                height: 50,
                              ),
                              ALittleVerticalSpace(),
                              Container(
                                height: 50,
                                child: TimeSelectionWidget(
                                  title: "زمان شروع",
                                  timeTextController: startTimeController,
                                  forced: true,
                                  enable: !this.detailMode,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: new BorderSide(
                                          color: IColors.darkGrey, width: 1)),
                                ),
                              ),
                              ALittleVerticalSpace(),
                              Container(
                                height: 50,
                                child: TimeSelectionWidget(
                                    title: "زمان پایان",
                                    timeTextController: endTimeController,
                                    enable: !this.detailMode,
                                    forced: true,
                                    extraValidator: (DateTime) {
                                      if (startTimeController.text.isNotEmpty &&
                                          endTimeController.text.isNotEmpty) {
                                        int startMinute =
                                            DateTimeService.getTimeMinute(
                                                startTimeController.text);
                                        int endMinute =
                                            DateTimeService.getTimeMinute(
                                                endTimeController.text);
                                        if (endMinute < startMinute) {
                                          return "زمان پایان باید بعد از زمان شروع باشد.";
                                        }
                                      }
                                      return null;
                                    },
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: new BorderSide(
                                            color: IColors.darkGrey,
                                            width: 1))),
                              ),
                              ALittleVerticalSpace(),
                              this.detailMode
                                  ? SizedBox()
                                  : addToAllDaysToggle(),
                              ALittleVerticalSpace(),
                              this.detailMode
                                  ? deleteApplyButton()
                                  : addApplyButton()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        }).then((value) {});
  }

  Widget _title() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        menuLabel("ویزیت " + VisitTypes.values[visitType].title),
      ],
    );
  }

  Widget _dateWidget() {
    if (this.detailMode) {
      return AutoText(this.dateController.text ?? "");
    } else {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          controller: dateController,
          onTap: () {
            showDatePickerDialog(context, [], dateController,
                restrictMinDate: false);
          },
          validator: (value) {
            if (value.isEmpty) return "فیلد خالی است!";
            var jalali = DateTimeService.getJalalyDateFromJalilyString(value);
            if (jalali == null) {
              return "تاریخ نامعتبر";
            } else {
              return null;
            }
          },
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.datetime,
          maxLines: 1,
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: "تاریخ",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: new BorderSide(color: IColors.darkGrey, width: 1)),
          ),
        ),
      );
    }
  }

  Widget addApplyButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        ActionButton(
          title: Strings.cancelAction,
          callBack: _closeDialog,
          color: IColors.themeColor,
        ),
        ActionButton(
          title: Strings.okAction,
          callBack: _submit,
          color: IColors.themeColor,
        ),
      ],
    );
  }

  Widget deleteApplyButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: [
        ActionButton(
          title: Strings.cancelAction,
          callBack: _closeDialog,
          color: IColors.themeColor,
        ),
        ActionButton(
          title: Strings.deleteAction,
          callBack: _submit,
          color: IColors.red,
        ),
      ],
    );
  }

  void _closeDialog() {
    Navigator.of(dialogContext).pop();
  }

  void _submit() {
    if (detailMode) {
      DateTime date =
          DateTimeService.getDateAndTimeFromJalali(dateController.text);
      plan.getVisitTypeDataWithType(visitType).removeWorkTime(
          date, startTimeController.text, endTimeController.text);
      onApplyChange();
      _closeDialog();
    } else {
      if (_formKey.currentState.validate()) {
        DateTime date =
            DateTimeService.getDateAndTimeFromJalali(dateController.text);
        if (this.addFor4Weeks) {
          for (int i = 0; i < 4; i++) {
            plan.getVisitTypeDataWithType(visitType).addWorkTime(
                date, startTimeController.text, endTimeController.text);
            date = date.add(Duration(days: 7));
          }
        } else {
          plan.getVisitTypeDataWithType(visitType).addWorkTime(
              date, startTimeController.text, endTimeController.text);
        }

        onApplyChange();
        _closeDialog();
      }
    }
  }

  Widget addToAllDaysToggle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Switch(
          value: addFor4Weeks,
          activeColor: IColors.themeColor,
          onChanged: (bool value) {
            alertStateSetter(() {
              addFor4Weeks = !addFor4Weeks;
            });
          },
        ),
        AutoText(
          "برای ۴ هفته آینده تکرار کن!",
          textAlign: TextAlign.right,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: addFor4Weeks ? Colors.black : Colors.grey),
        ),
      ],
    );
  }
}
