import 'dart:async';

import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/DoctorPlan.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/visit/VisitUtils.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/PriceWidget.dart';
import 'package:docup/ui/widgets/TimeSelectorHeaderWidget.dart';
import 'package:docup/ui/widgets/TimeSelectorWidget.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/ui/widgets/LabelAndListWidget.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class VisitConfPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final Function(String, dynamic) onPush;

  VisitConfPage({Key key, @required this.onPush, this.doctorEntity})
      : super(key: key);

  @override
  _VisitConfPageState createState() => _VisitConfPageState();
}

class _VisitConfPageState extends State<VisitConfPage> {
  Map<String, Set<int>> typeSelected = {
    "انواع مشاوره ها": Set.identity(),
    "انواع زمان مشاوره": Set.identity(),
    "وقت ویزیت": Set.identity(),
    "روزهای برگزاری": Set.identity(),
    "ساعت‌های برگزاری": Set.identity()
  };

  Offset tappedOffset;
  DoctorInfoBloc _bloc = DoctorInfoBloc();

  @override
  void initState() {
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
    for (WorkTimes workTime in plan.workTimes) {
      final startHour = int.parse(workTime.startTime.split(":")[0]);
      final endHour = int.parse(workTime.endTime.split(":")[0]);
      for (int i = startHour; i <= endHour; i++) {
        visitTimes.add(i);
      }
    }
    return visitTimes.toList();
  }

  _getWorkTimes() {
    List<WorkTimes> workTimes = [];
    final hours = typeSelected["ساعت‌های برگزاری"].toList();
    hours.sort();
    for (int hour in hours) {
      workTimes.add(WorkTimes(
        startTime: "$hour:00:00",
        endTime: "$hour:59:59",
      ));
    }
    return workTimes;
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      _bloc.getDoctor(widget.doctorEntity.id, true);
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _bloc.getDoctor(widget.doctorEntity.id, true),
        child: StreamBuilder<Response<DoctorEntity>>(
          stream: _bloc.doctorInfoStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return APICallLoading();
                  break;
                case Status.COMPLETED:
                  return Center(child: _rootWidget(snapshot.data.data));
                  break;
                case Status.ERROR:
                  return APICallError(
                    errorMessage: snapshot.data.error.toString(),
                    onRetryPressed: () =>
                        _bloc.getDoctor(widget.doctorEntity.id, true),
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

  bool isLoaded = false;

  GestureDetector _rootWidget(DoctorEntity doctorEntity) {
    if (!isLoaded) {
      print("--->>>>>> ${doctorEntity.plan.workTimes}");
      typeSelected["انواع مشاوره ها"].addAll(doctorEntity.plan.visitMethod);
      typeSelected["انواع زمان مشاوره"]
          .addAll(doctorEntity.plan.visitDurationPlan);
      if (doctorEntity.plan.workTimes != null &&
          doctorEntity.plan.workTimes.isNotEmpty) {
        print("set times from root ${_getVisitTimes(doctorEntity.plan)}");
        typeSelected["ساعت‌های برگزاری"]
            .addAll(_getVisitTimes(doctorEntity.plan));
      }
      typeSelected["روزهای برگزاری"].addAll(doctorEntity.plan.availableDays);
      typeSelected["وقت ویزیت"].addAll(doctorEntity.plan.visitType);
    }
    isLoaded = true;

    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          tappedOffset = details.globalPosition;
        });
      },
      child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            DocUpHeader(),
            ALittleVerticalSpace(),
            LabelAndListWidget(
              smallSize: true,
              title: "انواع مشاوره ها",
              items: [
                VisitMethod.TEXT.title,
                VisitMethod.VOICE.title,
                VisitMethod.VIDEO.title
              ],
              selectedIndex: typeSelected["انواع مشاوره ها"],
              callback: labelAndListCallback,
            ),
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
                  Text(
                    "قیمت پایه",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            ALittleVerticalSpace(),
            PriceWidget(
              title: "مشاوره تصویری",
              price: replaceFarsiNumber("${doctorEntity.plan.baseVideoPrice}"),
            ),
            PriceWidget(
              title: "مشاوره متنی",
              price: replaceFarsiNumber("${doctorEntity.plan.baseTextPrice}"),
            ),
            ALittleVerticalSpace(),
            LabelAndListWidget(
              smallSize: true,
              title: "وقت ویزیت",
              items: ["حضوری", "مجازی"],
              selectedIndex: typeSelected["وقت ویزیت"],
              callback: labelAndListCallback,
            ),
            ALittleVerticalSpace(),
            TimeSelectorHeaderWidget(callback: (timeIsSelected) {
              setState(() {
                this.timeIsSelected = timeIsSelected;
              });
            }),
            _timeAndDateSelectorWidget(),
            MediumVerticalSpace(),
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

  labelAndListCallback(title, index) {
    setState(() {
      if (typeSelected[title].contains(index)) {
        typeSelected[title].remove(index);
      } else {
        typeSelected[title].add(index);
      }
    });
  }

  bool timeIsSelected = true;
  StreamController<Set<int>> controller = BehaviorSubject();

  Widget _timeAndDateSelectorWidget() {
    if (timeIsSelected) {
      return Column(
        children: <Widget>[
          TimeSelectorWidget(
              tappedOffset: tappedOffset,
              controller: controller,
              initTimes: Set.from(typeSelected["ساعت‌های برگزاری"])),
          MediumVerticalSpace(),
          _helpWidget(context),
        ],
      );
    } else {
      return LabelAndListWidget(
        smallSize: true,
        title: "روزهای برگزاری",
        showTitle: false,
        items: [
          WeekDay.SATURDAY.name,
          WeekDay.SUNDAY.name,
          WeekDay.MONDAY.name,
          WeekDay.TUESDAY.name,
          WeekDay.WEDNESDAY.name,
          WeekDay.THURSDAY.name,
          WeekDay.FRIDAY.name,
        ],
        selectedIndex: typeSelected["روزهای برگزاری"],
        callback: labelAndListCallback,
      );
    }
  }

  void submit(DoctorPlan plan) {
    _bloc.updateDoctor(
        widget.doctorEntity.id,
        DoctorPlan(
            visitMethod: typeSelected["انواع مشاوره ها"].toList(),
            visitType: typeSelected["وقت ویزیت"].toList(),
            visitDurationPlan: typeSelected["انواع زمان مشاوره"].toList(),
            availableDays: typeSelected["روزهای برگزاری"].toList(),
            workTimes: _getWorkTimes(),
            enabled: true,
            baseTextPrice: plan.baseTextPrice,
            baseVideoPrice: plan.baseVideoPrice,
            basePhysicalVisitPrice: plan.basePhysicalVisitPrice,
            baseVoicePrice: plan.baseVoicePrice));
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
                "زمان هایی که با زدن آنها به رنگ سبز در آمده اند به معنای ساعات امکان پذیر برای ارایه خدمت توسط شما، می باشند.",
                "باشه",
                () {}),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }
}
