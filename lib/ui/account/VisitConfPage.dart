import 'dart:developer';

import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/DoctorPlan.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/visit/VisitUtils.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/ui/widgets/FlutterDateTimePickerCustom/flutter_datetime_picker.dart';
import 'package:docup/ui/widgets/FlutterDateTimePickerCustom/src/datetime_picker_theme.dart';
import 'package:docup/ui/widgets/FlutterDateTimePickerCustom/src/i18n_model.dart';
import 'package:docup/ui/widgets/LabelAndListWidget.dart';
import 'package:docup/ui/widgets/PriceWidget.dart';
import 'package:docup/ui/widgets/TimeSelectionWidget.dart';
import 'package:docup/ui/widgets/TimeSelectorHeaderWidget.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/ui/widgets/modifiedPackages/calendar_views-0.5.2/widgets/DoctorWorkTImeCalendar/day_view_example.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

enum TypeSelect {
  visitType,
  virtualDurationPlan,
  virtualVisitMethod,
  physicalDurationPlan
}

extension CatExtension on TypeSelect {
  String get title {
    switch (this) {
      case TypeSelect.visitType:
        return 'انواع مشاوره';
      case TypeSelect.virtualDurationPlan:
        return 'زمان های مشاوره مجازی';
      case TypeSelect.virtualVisitMethod:
        return "انواع مشاوره مجازی";
      case TypeSelect.physicalDurationPlan:
        return "زمان های مشاوره حضوری";
      default:
        return "";
    }
  }

  List<String> get items {
    switch (this) {
      case TypeSelect.visitType:
        return [VisitTypes.PHYSICAL.title, VisitTypes.VIRTUAL.title];
      case TypeSelect.virtualDurationPlan:
        return [
          VisitDurationPlan.BASE.title,
          VisitDurationPlan.SUPPLEMENTARY.title,
          VisitDurationPlan.LONG.title
        ];
      case TypeSelect.virtualVisitMethod:
        return [
          // VirtualVisitMethod.TEXT.title,
          VirtualVisitMethod.VOICE.title,
          VirtualVisitMethod.VIDEO.title
        ];
      case TypeSelect.physicalDurationPlan:
        return [
          VisitDurationPlan.BASE.title,
          VisitDurationPlan.SUPPLEMENTARY.title,
          VisitDurationPlan.LONG.title
        ];
      default:
        return [];
    }
  }
}

class VisitConfPage extends StatefulWidget {
  final Function(String, dynamic) onPush;
  final int doctorId;

  VisitConfPage({Key key, @required this.onPush, this.doctorId})
      : super(key: key);

  @override
  _VisitConfPageState createState() => _VisitConfPageState();
}

class _VisitConfPageState extends State<VisitConfPage>
    with TickerProviderStateMixin {
  final TextEditingController textBasePriceController = TextEditingController();
  final TextEditingController voiceBasePriceController =
      TextEditingController();
  final TextEditingController videoBasePriceController =
      TextEditingController();
  final TextEditingController physicalBasePriceController =
      TextEditingController();

  Map<String, Set<int>> typeSelected = {
    TypeSelect.visitType.title: Set.identity(),
    TypeSelect.virtualDurationPlan.title: Set.identity(),
    TypeSelect.virtualVisitMethod.title: Set.identity(),
    TypeSelect.physicalDurationPlan.title: Set.identity(),
  };

  Offset tappedOffset;
  DoctorInfoBloc _bloc = DoctorInfoBloc();
  bool isLoaded = false;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  bool _toolTipVisitTime = false;

  // List<List<List<int>>> virtualDaysPlanTable = [];
  // List<List<List<int>>> physicalDaysPlanTable = [];
  DoctorPlan plan;
  CalendarController calendarController = CalendarController();

  bool timeIsSelected = true;

  // StreamController<Set<int>> controller = BehaviorSubject();

  @override
  void initState() {
    /// intial doctor loading
    if (!isLoaded) {
      _bloc.getDoctor(widget.doctorId, true);
    }

    /// change listening
    _bloc.doctorPlanStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        toast(context, "تغییرات با موفقیت ثبت شد");
        Navigator.pop(context);
      } else if (data.status == Status.ERROR) {
        toast(context, data.error.toString());
      }
    });
    // controller.stream.listen((event) {
    //   print("set times from listener $event");
    //   typeSelected["ساعت‌های برگزاری"] = event;
    // });
    super.initState();
  }

  // _getVisitTimes(DoctorPlan plan) {
  //   List<int> visitTimes = [];
  //
  //   /// TODO amir
  //   // for (WorkTimes workTime in plan.weeklyWorkTimes) {
  //   //   final startHour = int.parse(workTime.startTime.split(":")[0]);
  //   //   final endHour = int.parse(workTime.endTime.split(":")[0]);
  //   //   for (int i = startHour; i <= endHour; i++) {
  //   //     visitTimes.add(i);
  //   //   }
  //   // }
  //   return visitTimes.toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _bloc.getDoctor(widget.doctorId, true),
        child: StreamBuilder<Response<DoctorEntity>>(
          stream: _bloc.doctorInfoStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return DocUpAPICallLoading2();
                  break;
                case Status.COMPLETED:
                  return _rootWidget(snapshot.data.data);
                  break;
                case Status.ERROR:
                  return APICallError(
                    () => _bloc.getDoctor(widget.doctorId, true),
                    errorMessage: snapshot.data.error.toString(),
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _rootWidget(DoctorEntity doctorEntity) {
    if (!isLoaded) {
      typeSelected[TypeSelect.virtualVisitMethod.title]
          .addAll(doctorEntity.plan.virtualVisitMethod);
      typeSelected[TypeSelect.virtualDurationPlan.title]
          .addAll(doctorEntity.plan.virtualVisitDurationPlan);
      typeSelected[TypeSelect.physicalDurationPlan.title]
          .addAll(doctorEntity.plan.physicalVisitDurationPlan);
      // if (doctorEntity.plan.weeklyWorkTimes != null &&
      //     doctorEntity.plan.weeklyWorkTimes.isNotEmpty) {
      //   print("set times from root ${_getVisitTimes(doctorEntity.plan)}");
      //   typeSelected["ساعت‌های برگزاری"]
      //       .addAll(_getVisitTimes(doctorEntity.plan));
      // }

      // typeSelected["روزهای برگزاری"].addAll(doctorEntity.plan.availableDays);
      typeSelected[TypeSelect.visitType.title]
          .addAll(doctorEntity.plan.visitTypesNumber);

      /// setting initial base price
      textBasePriceController.text =
          doctorEntity.plan?.baseTextPrice.toString();
      voiceBasePriceController.text =
          doctorEntity.plan?.baseVoicePrice.toString();
      videoBasePriceController.text =
          doctorEntity.plan?.baseVideoPrice.toString();
      physicalBasePriceController.text =
          doctorEntity.plan?.basePhysicalVisitPrice.toString();

      /// initial table data
      this.plan = doctorEntity.plan;
      // for (int i = 0; i < DoctorPlan.daysCount; i++) {
      //   var a = doctorEntity.plan.virtualVisitType?.getDailyWorkTimeTable(i);
      //   if (a != null) {
      //     this.virtualDaysPlanTable.add(a);
      //   } else {
      //     List<List<int>> workTimeTable = VisitType.getEmptyTablePlan();
      //     this.virtualDaysPlanTable.add(workTimeTable);
      //   }
      // }
      // for (int i = 0; i < DoctorPlan.daysCount; i++) {
      //   var a = doctorEntity.plan.physicalVisitType?.getDailyWorkTimeTable(i);
      //   if (a != null) {
      //     this.physicalDaysPlanTable.add(a);
      //   } else {
      //     List<List<int>> workTimeTable = VisitType.getEmptyTablePlan();
      //     this.physicalDaysPlanTable.add(workTimeTable);
      //   }
      // }
    }
    isLoaded = true;
    return Scaffold(
      floatingActionButton: SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.add_event,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: typeSelected[TypeSelect.visitType.title].contains(0) ||
            typeSelected[TypeSelect.visitType.title].contains(1),
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
        children: ((typeSelected[TypeSelect.visitType.title].contains(0))
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
                            AddWorkTimeDataSourceDialog(context, 0);
                        ad.showWorkTimeDialog();
                      },
                    )
                  ]
                : <SpeedDialChild>[]) +
            ((typeSelected[TypeSelect.virtualVisitMethod.title].length != 0 &&
                    typeSelected[TypeSelect.visitType.title].contains(1))
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
                            AddWorkTimeDataSourceDialog(context, 1);
                        ad.showWorkTimeDialog();
                      },
                    )
                  ]
                : <SpeedDialChild>[]),
      ),
      body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
            DocUpHeader(
              docUpLogo: false,
            ),
            ALittleVerticalSpace(),
            LabelAndListWidget(
              smallSize: true,
              title: TypeSelect.visitType.title,
              items: TypeSelect.visitType.items,
              selectedIndex: typeSelected[TypeSelect.visitType.title],
              callback: labelAndListCallback,
            ),
            ALittleVerticalSpace(),
            AnimatedSize(
              duration: Duration(milliseconds: 400),
              vsync: this,
              child: typeSelected[TypeSelect.visitType.title].contains(1)
                  ? LabelAndListWidget(
                      smallSize: true,
                      title: TypeSelect.virtualVisitMethod.title,
                      items: TypeSelect.virtualVisitMethod.items,
                      selectedIndex:
                          typeSelected[TypeSelect.virtualVisitMethod.title],
                      callback: labelAndListCallback,
                    )
                  : SizedBox(),
            ),
            ALittleVerticalSpace(),
            AnimatedSize(
              duration: Duration(milliseconds: 400),
              vsync: this,
              child: typeSelected[TypeSelect.visitType.title].contains(1)
                  ? LabelAndListWidget(
                      smallSize: false,
                      title: TypeSelect.virtualDurationPlan.title,
                      items: TypeSelect.virtualDurationPlan.items,
                      selectedIndex:
                          typeSelected[TypeSelect.virtualDurationPlan.title],
                      callback: labelAndListCallback,
                    )
                  : SizedBox(),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 400),
              vsync: this,
              child: typeSelected[TypeSelect.visitType.title].contains(0)
                  ? LabelAndListWidget(
                      smallSize: false,
                      title: TypeSelect.physicalDurationPlan.title,
                      items: TypeSelect.physicalDurationPlan.items,
                      selectedIndex:
                          typeSelected[TypeSelect.physicalDurationPlan.title],
                      callback: labelAndListCallback,
                    )
                  : SizedBox(),
            ),
            ALittleVerticalSpace(),
            AnimatedSize(
              duration: Duration(milliseconds: 400),
              vsync: this,
              child:
                  (typeSelected[TypeSelect.virtualVisitMethod.title].length !=
                                  0 &&
                              typeSelected[TypeSelect.visitType.title]
                                  .contains(1)) ||
                          (typeSelected[TypeSelect.visitType.title].contains(0))
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              AutoText(
                                "قیمت پایه",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
            ),

            AnimatedSize(
              duration: Duration(milliseconds: 400),
              vsync: this,
              child: typeSelected[TypeSelect.virtualVisitMethod.title]
                          .contains(1) &&
                      typeSelected[TypeSelect.visitType.title].contains(1)
                  ? PriceWidget(
                      title: "مشاوره " + VirtualVisitMethod.VOICE.title,
                      priceController: voiceBasePriceController,
                    )
                  : SizedBox(),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 400),
              vsync: this,
              child: typeSelected[TypeSelect.virtualVisitMethod.title]
                          .contains(2) &&
                      typeSelected[TypeSelect.visitType.title].contains(1)
                  ? PriceWidget(
                      title: "مشاوره " + VirtualVisitMethod.VIDEO.title,
                      priceController: videoBasePriceController,
                    )
                  : SizedBox(),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 400),
              vsync: this,
              child: typeSelected[TypeSelect.visitType.title].contains(0)
                  ? PriceWidget(
                      title: "مشاوره " + VisitTypes.PHYSICAL.title,
                      priceController: physicalBasePriceController,
                    )
                  : SizedBox(),
            ),
            ALittleVerticalSpace(),
            getVirtualPhysicalWidgetTimeTable(),
            // getWeeklyVirtualAndPhysicalTimeTable(),
            ALittleVerticalSpace(),
            ActionButton(
              title: "ثبت اطلاعات برای بررسی",
              color: IColors.themeColor,
              callBack: () => submit(doctorEntity.plan),
            ),
            ALittleVerticalSpace(),
          ])),
    );
  }

  Widget getVirtualPhysicalWidgetTimeTable() {
    log(typeSelected[TypeSelect.virtualVisitMethod.title].length.toString());
    return AnimatedSize(
      duration: Duration(milliseconds: 400),
      vsync: this,
      child: (typeSelected[TypeSelect.virtualVisitMethod.title].length != 0 &&
                  typeSelected[TypeSelect.visitType.title].contains(1)) ||
              (typeSelected[TypeSelect.visitType.title].contains(0))
          ? Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _toolTipVisitTime = !_toolTipVisitTime;
                    });
                  },
                  child: SimpleTooltip(
                    show: _toolTipVisitTime,
                    hideOnTooltipTap: true,
                    borderColor: IColors.themeColor,
                    tooltipDirection: TooltipDirection.down,
                    content: AutoText(Strings.doctorPlanVisitTimeHelp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(top: 10.0, left: 10, bottom: 10),
                          child: Icon(
                            Icons.help_outline_sharp,
                            color: IColors.darkGrey,
                            size: 22,
                          ),
                        ),
                        TimeSelectorHeaderWidget(
                          callback: (timeIsSelected) {
                            setState(() {
                              this.timeIsSelected = timeIsSelected;
                            });
                          },
                          timeDateWidgetsFlag: false,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    height: 350,
                    color: Color.fromARGB(0, 0, 0, 0),
                    child: DayViewExample(
                      plan?.totalWorkTimes ??
                          <DateTime, DataSourceDailyWorkTimes>{},
                      showEventTitle: false,
                    )
                    // SfCalendar(
                    //   // backgroundColor: Color.fromARGB(0, 0, 0, 0),
                    //   view: CalendarView.week,
                    //   allowViewNavigation: false,
                    //   dataSource: this.doctorWorkDataSource,
                    //   showNavigationArrow: true,
                    //   showDatePickerButton: true,
                    //   cellEndPadding: 1,
                    //   controller: this.calendarController,
                    //   onTap: (calendarTapDetails) {
                    //     log("");
                    //   },
                    //   appointmentTextStyle: TextStyle(fontWeight: FontWeight.bold),
                    //   // appointmentBuilder: (context, calendarAppointmentDetails) {},
                    // ),
                    ),
              ],
            )
          : SizedBox(),
    );
  }

  //
  // Widget getWeeklyVirtualAndPhysicalTimeTable() {
  //   int initialIndex = 1;
  //   if (typeSelected[TypeSelect.visitType.title].length < 2) {
  //     initialIndex = 0;
  //   }
  //   TabController tabController = TabController(
  //       length: typeSelected[TypeSelect.visitType.title].length,
  //       vsync: this,
  //       initialIndex: 0);
  //
  //   List<WeeklyTimeTable> tabsView =
  //       (typeSelected[TypeSelect.visitType.title].contains(0)
  //               ? <WeeklyTimeTable>[
  //                   WeeklyTimeTable(
  //                     context,
  //                     this.physicalDaysPlanTable,
  //                     startTableHour: 6,
  //                     endTableHour: 24,
  //                   )
  //                 ]
  //               : <WeeklyTimeTable>[]) +
  //           (typeSelected[TypeSelect.visitType.title].contains(1)
  //               ? <WeeklyTimeTable>[
  //                   WeeklyTimeTable(
  //                     context,
  //                     this.virtualDaysPlanTable,
  //                     startTableHour: 6,
  //                     endTableHour: 24,
  //                   )
  //                 ]
  //               : <WeeklyTimeTable>[]);
  //   double tabViewHeight = tabsView.length == 0 ? 0 : tabsView[0].tableHeight;
  //   List<int> visitTypes = typeSelected[TypeSelect.visitType.title].toList();
  //   visitTypes.sort();
  //   List<Widget> tabsTable = [
  //     for (var visitTypeNumber in visitTypes)
  //       Container(
  //         alignment: Alignment.center,
  //         padding: EdgeInsets.symmetric(vertical: 10),
  //         child: AutoText(
  //           "ویزیت" + " " + VisitType.getVisitTypeName(visitTypeNumber),
  //           style: TextStyle(fontSize: 18, color: IColors.themeColor),
  //           maxLines: 1,
  //         ),
  //       ),
  //   ];
  //   return AnimatedSize(
  //     duration: Duration(milliseconds: 400),
  //     vsync: this,
  //     child: Column(
  //       children: [
  //         (typeSelected[TypeSelect.virtualVisitMethod.title].length != 0 &&
  //                     typeSelected[TypeSelect.visitType.title].contains(1)) ||
  //                 (typeSelected[TypeSelect.visitType.title].contains(0))
  //             ? GestureDetector(
  //                 onTap: () {
  //                   setState(() {
  //                     _toolTipVisitTime = !_toolTipVisitTime;
  //                   });
  //                 },
  //                 child: SimpleTooltip(
  //                   show: _toolTipVisitTime,
  //                   hideOnTooltipTap: true,
  //                   borderColor: IColors.themeColor,
  //                   tooltipDirection: TooltipDirection.down,
  //                   content: AutoText(Strings.doctorPlanVisitTimeHelp),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       Padding(
  //                         padding:
  //                             EdgeInsets.only(top: 10.0, left: 10, bottom: 10),
  //                         child: Icon(
  //                           Icons.help_outline_sharp,
  //                           color: IColors.darkGrey,
  //                           size: 22,
  //                         ),
  //                       ),
  //                       TimeSelectorHeaderWidget(
  //                         callback: (timeIsSelected) {
  //                           setState(() {
  //                             this.timeIsSelected = timeIsSelected;
  //                           });
  //                         },
  //                         timeDateWidgetsFlag: false,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               )
  //             : SizedBox(),
  //         DefaultTabController(
  //           length: 2,
  //           child: Column(
  //             children: [
  //               Container(
  //                 height: 50,
  //                 child: TabBar(
  //                   controller: tabController,
  //                   tabs: tabsTable,
  //                   isScrollable: true,
  //                 ),
  //               ),
  //               ALittleVerticalSpace(),
  //               Container(
  //                 height: tabViewHeight,
  //                 alignment: Alignment.center,
  //                 child: TabBarView(
  //                   physics: NeverScrollableScrollPhysics(),
  //                   controller: tabController,
  //                   children: tabsView,
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String correctTimeFormat(String text) {
    if (text.split(":").length == 3) {
      /// TODO amir: we don't user second so maybe later
    } else if (text.split(":").length == 2) {
      String hour = text.split(":")[0];
      String minute = text.split(":")[1];
      if (hour.length == 1) {
        hour = "0" + hour;
      }
      if (minute.length == 1) {
        minute = "0" + minute;
      }
      return hour + ":" + minute;
    }
    return text;
  }

  void showTime(
      TextEditingController textEditingController, DateTime startDateTime) {
    DatePicker.showTimePicker(context,
        showTitleActions: true,
        theme: DatePickerTheme(
            doneStyle: TextStyle(color: IColors.themeColor),
            titles: {0: "ساعت", 1: "دقیقه"},
            itemStyle: TextStyle(
                fontWeight: FontWeight.w700, color: Color(0xFF000046))),
        onChanged: (date) {},
        onConfirm: (date) {},
        currentTime: startDateTime,
        locale: LocaleType.fa);
  }

  labelAndListCallback(title, index) {
    setState(() {
      if (typeSelected[title].contains(index)) {
        typeSelected[title].remove(index);
      } else {
        typeSelected[title].add(index);
      }
    });
  }

  void submit(DoctorPlan plan) async {
    /// updating plan by table data
    List<int> visitTypesListNumber =
        typeSelected[TypeSelect.visitType.title].toList();
    _bloc.updateDoctor(
        widget.doctorId,
        DoctorPlan(
          visitTypes: (visitTypesListNumber.contains(0)
                  ? <VisitType>[getPhysicalVisitTypeDetail()]
                  : <VisitType>[]) +
              (visitTypesListNumber.contains(1)
                  ? <VisitType>[getVirtualVisitTypeDetail()]
                  : <VisitType>[]),
          enabled: true,
        ));
  }

  VisitType getVirtualVisitTypeDetail() {
    /// TODO
    List<DailyWorkTimes> virtualPlanDaysWorkTimes = [];
    // DoctorPlan.getWeeklyWorkTimesWithTableData([]);
    return VisitType(
        visitType: 1,
        visitMethod: typeSelected[TypeSelect.virtualVisitMethod.title].toList(),
        visitDurationPlan:
            typeSelected[TypeSelect.virtualDurationPlan.title].toList(),
        baseTextPrice:
            intPossible(textBasePriceController.text, defaultValues: 0),
        baseVideoPrice:
            intPossible(videoBasePriceController.text, defaultValues: 0),
        baseVoicePrice:
            intPossible(voiceBasePriceController.text, defaultValues: 0),
        basePhysicalVisitPrice: 0,
        DaysWorkTimes: virtualPlanDaysWorkTimes);
  }

  VisitType getPhysicalVisitTypeDetail() {
    /// TODO
    List<DailyWorkTimes> physicalPlanDaysWorkTimes = [];
    // DoctorPlan.getWeeklyWorkTimesWithTableData([]);
    return VisitType(
        visitType: 0,
        visitMethod: [],
        visitDurationPlan:
            typeSelected[TypeSelect.physicalDurationPlan.title].toList(),
        basePhysicalVisitPrice:
            intPossible(physicalBasePriceController.text, defaultValues: 0),
        baseTextPrice: 0,
        baseVideoPrice: 0,
        baseVoicePrice: 0,
        DaysWorkTimes: physicalPlanDaysWorkTimes);
  }

  // bool repeatableForSelectedDays = false;
  //
  // Row _helpWidget(BuildContext context) {
  //   return Row(
  //     children: <Widget>[
  //       Padding(
  //         padding: const EdgeInsets.only(left: 16.0),
  //         child: ActionButton(
  //           color: IColors.themeColor,
  //           title: "راهنما",
  //           callBack: () => showOneButtonDialog(
  //               context,
  //               "زمان هایی که با زدن آنها انتخاب می‌شوند به معنای ساعات امکان پذیر برای ارایه خدمت توسط شما، می باشند. اگر زمان های صبح را هم به بازه می خواهید اضافه کنید به پشتیبانی اطلاع دهید",
  //               "باشه",
  //               () {}),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  void dispose() {
    super.dispose();
  }
}

class AddWorkTimeDataSourceDialog {
  String currentDate;
  int visitType;
  BuildContext dialogContext;
  BuildContext context;
  StateSetter alertStateSetter;
  TextEditingController startTimeController;
  TextEditingController endTimeController;
  bool visitTimeChecked = false;

  AddWorkTimeDataSourceDialog(this.context, this.visitType);

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TimeSelectionWidget(
                              title: "زمان شروع",
                              timeTextController: startTimeController,
                            ),
                            TimeSelectionWidget(
                              title: "زمان پایان",
                              timeTextController: endTimeController,
                            ),
                            ALittleVerticalSpace(),
                            addToAllDaysToggle(),
                            ALittleVerticalSpace(),
                            ActionButton(
                              title: Strings.okAction,
                              callBack: _submit,
                              color: IColors.themeColor,
                            )
                          ],
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

  Widget currentSelectedDate() {
    /// TODO
    return null;
  }

  Widget addToAllDaysToggle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Switch(
          value: visitTimeChecked,
          activeColor: IColors.themeColor,
          onChanged: (bool value) {
            alertStateSetter(() {
              visitTimeChecked = !visitTimeChecked;
            });
          },
        ),
        AutoText(
          "برای ۴ هفته دیگه ست کن!",
          textAlign: TextAlign.right,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: visitTimeChecked ? Colors.black : Colors.grey),
        ),
      ],
    );
  }

  void _submit() {}
}
