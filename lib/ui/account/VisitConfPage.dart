import 'dart:async';

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
import 'package:docup/ui/widgets/DailyTimeTable.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/ui/widgets/FlutterDateTimePickerCustom/flutter_datetime_picker.dart';
import 'package:docup/ui/widgets/FlutterDateTimePickerCustom/src/datetime_picker_theme.dart';
import 'package:docup/ui/widgets/FlutterDateTimePickerCustom/src/i18n_model.dart';
import 'package:docup/ui/widgets/LabelAndListWidget.dart';
import 'package:docup/ui/widgets/PriceWidget.dart';
import 'package:docup/ui/widgets/TimeSelectorHeaderWidget.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

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
    "انواع مشاوره ها": Set.identity(),
    "انواع زمان مشاوره": Set.identity(),
    "وقت ویزیت": Set.identity(),
    "روزهای برگزاری": Set.identity(),
    "ساعت‌های برگزاری": Set.identity(),
    'نوع ویزیت': Set.identity()
  };

  Offset tappedOffset;
  DoctorInfoBloc _bloc = DoctorInfoBloc();
  bool isLoaded = false;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  bool _toolTipVisitTime = false;

  List<List<List<int>>> daysPlanTable = [];

  bool timeIsSelected = true;
  StreamController<Set<int>> controller = BehaviorSubject();

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
    controller.stream.listen((event) {
      print("set times from listener $event");
      typeSelected["ساعت‌های برگزاری"] = event;
    });
    super.initState();
  }

  _getVisitTimes(DoctorPlan plan) {
    List<int> visitTimes = [];

    /// TODO amir
    // for (WorkTimes workTime in plan.weeklyWorkTimes) {
    //   final startHour = int.parse(workTime.startTime.split(":")[0]);
    //   final endHour = int.parse(workTime.endTime.split(":")[0]);
    //   for (int i = startHour; i <= endHour; i++) {
    //     visitTimes.add(i);
    //   }
    // }
    return visitTimes.toList();
  }

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
                  return Center(child: _rootWidget(snapshot.data.data));
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
      typeSelected["انواع مشاوره ها"].addAll(doctorEntity.plan.visitMethod);
      typeSelected["انواع زمان مشاوره"]
          .addAll(doctorEntity.plan.visitDurationPlan);
      if (doctorEntity.plan.weeklyWorkTimes != null &&
          doctorEntity.plan.weeklyWorkTimes.isNotEmpty) {
        print("set times from root ${_getVisitTimes(doctorEntity.plan)}");
        typeSelected["ساعت‌های برگزاری"]
            .addAll(_getVisitTimes(doctorEntity.plan));
      }

      /// TODO Incomplete DoctorPlan
      // typeSelected["روزهای برگزاری"].addAll(doctorEntity.plan.availableDays);
      typeSelected["نوع ویزیت"].addAll(doctorEntity.plan.visitType);

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
      for (int i = 0; i < DoctorPlan.daysCount; i++) {
        var a = doctorEntity.plan?.getDailyWorkTimeTable(i);
        if (a != null) this.daysPlanTable.add(a);
      }
    }
    isLoaded = true;
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          DocUpHeader(),
          ALittleVerticalSpace(),
          LabelAndListWidget(
            smallSize: true,
            title: "نوع ویزیت",
            items: ["حضوری", "مجازی"],
            selectedIndex: typeSelected["نوع ویزیت"],
            callback: labelAndListCallback,
          ),
          ALittleVerticalSpace(),
          typeSelected["نوع ویزیت"].contains(1)
              ? LabelAndListWidget(
                  smallSize: true,
                  title: "انواع مشاوره ها",
                  items: [
                    VisitMethod.TEXT.title,
                    VisitMethod.VOICE.title,
                    VisitMethod.VIDEO.title
                  ],
                  selectedIndex: typeSelected["انواع مشاوره ها"],
                  callback: labelAndListCallback,
                )
              : SizedBox(),
          ALittleVerticalSpace(),
          LabelAndListWidget(
            smallSize: false,
            title: "انواع زمان مشاوره",
            items: [
              VisitDurationPlan.BASE.title,
              VisitDurationPlan.SUPPLEMENTARY.title,
              VisitDurationPlan.LONG.title
            ],
            selectedIndex: typeSelected["انواع زمان مشاوره"],
            callback: labelAndListCallback,
          ),
          ALittleVerticalSpace(),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AutoText(
                  "قیمت پایه",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          typeSelected["انواع مشاوره ها"].contains(0) &&
                  typeSelected["نوع ویزیت"].contains(1)
              ? PriceWidget(
                  title: "مشاوره متنی",
                  priceController: textBasePriceController,
                )
              : SizedBox(),
          typeSelected["انواع مشاوره ها"].contains(1) &&
                  typeSelected["نوع ویزیت"].contains(1)
              ? PriceWidget(
                  title: "مشاوره صوتی",
                  priceController: voiceBasePriceController,
                )
              : SizedBox(),
          typeSelected["انواع مشاوره ها"].contains(2) &&
                  typeSelected["نوع ویزیت"].contains(1)
              ? PriceWidget(
                  title: "مشاوره تصویری",
                  priceController: videoBasePriceController,
                )
              : SizedBox(),
          typeSelected["نوع ویزیت"].contains(0)
              ? PriceWidget(
                  title: "مشاوره حضوری",
                  priceController: physicalBasePriceController,
                )
              : SizedBox(),
          ALittleVerticalSpace(),
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
                    padding: EdgeInsets.only(top: 10.0, left: 10, bottom: 10),
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
          WeeklyTimeTable(
            this.daysPlanTable,
            startTableHour: 6,
            endTableHour: 24,
          ),
          ALittleVerticalSpace(),
          ActionButton(
            title: "ثبت اطلاعات برای بررسی",
            color: IColors.themeColor,
            callBack: () => submit(doctorEntity.plan),
          ),
          ALittleVerticalSpace(),
        ]));
  }

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

  // Widget _timeAndDateSelectorWidget() {
  //   if (timeIsSelected) {
  //     return Column(
  //       children: <Widget>[
  //         CircularTimeSelector(
  //             tappedOffset: tappedOffset,
  //             controller: controller,
  //             initTimes: Set.from(typeSelected["ساعت‌های برگزاری"])),
  //         MediumVerticalSpace(),
  //         _helpWidget(context),
  //       ],
  //     );
  //   } else {
  //     return LabelAndListWidget(
  //       smallSize: true,
  //       title: "روزهای برگزاری",
  //       showTitle: false,
  //       items: [
  //         WeekDay.SATURDAY.name,
  //         WeekDay.SUNDAY.name,
  //         WeekDay.MONDAY.name,
  //         WeekDay.TUESDAY.name,
  //         WeekDay.WEDNESDAY.name,
  //         WeekDay.THURSDAY.name,
  //         WeekDay.FRIDAY.name,
  //       ],
  //       selectedIndex: typeSelected["روزهای برگزاری"],
  //       callback: labelAndListCallback,
  //     );
  //   }
  // }

  void submit(DoctorPlan plan) async {
    /// updating plan by table data
    List<DailyWorkTimes> planDaysWorkTimes =
        DoctorPlan.getWeeklyWorkTimesWithTableData(this.daysPlanTable);
    _bloc.updateDoctor(
        widget.doctorId,
        DoctorPlan(
            visitMethod: typeSelected["انواع مشاوره ها"].toList(),
            visitType: typeSelected["نوع ویزیت"].toList(),
            visitDurationPlan: typeSelected["انواع زمان مشاوره"].toList(),
            // availableDays: typeSelected["روزهای برگزاری"].toList(), /// this field has been removed
            weeklyWorkTimes: planDaysWorkTimes,
            enabled: true,
            baseTextPrice: int.parse(textBasePriceController.text),
            baseVideoPrice: int.parse(videoBasePriceController.text),
            basePhysicalVisitPrice: int.parse(physicalBasePriceController.text),
            baseVoicePrice: int.parse(voiceBasePriceController.text)));
  }

  bool repeatableForSelectedDays = false;

  Row _helpWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: ActionButton(
            color: IColors.themeColor,
            title: "راهنما",
            callBack: () => showOneButtonDialog(
                context,
                "زمان هایی که با زدن آنها انتخاب می‌شوند به معنای ساعات امکان پذیر برای ارایه خدمت توسط شما، می باشند. اگر زمان های صبح را هم به بازه می خواهید اضافه کنید به پشتیبانی اطلاع دهید",
                "باشه",
                () {}),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    try {
      controller.close();
    } catch (e) {}
    super.dispose();
  }
}
