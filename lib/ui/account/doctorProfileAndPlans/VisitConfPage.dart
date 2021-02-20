import 'dart:developer';

import 'package:Neuronio/blocs/DoctorInfoBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/DoctorPlan.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/account/doctorProfileAndPlans/EditableEventTable.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/visit/VisitUtils.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/LabelAndListWidget.dart';
import 'package:Neuronio/ui/widgets/PriceWidget.dart';
import 'package:Neuronio/ui/widgets/TimeSelectorHeaderWidget.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/FlutterDateTimePickerCustom/flutter_datetime_picker.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/FlutterDateTimePickerCustom/src/datetime_picker_theme.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/FlutterDateTimePickerCustom/src/i18n_model.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

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
          VirtualVisitMethod.TEXT.title,
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
  final Function(String, List<int>, DoctorPlan, Function()) onPush;
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

  bool _toolTipVisitTime = false;

  DoctorPlan plan;

  bool timeIsSelected = true;

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
    super.initState();
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
    }
    isLoaded = true;
    return SingleChildScrollView(
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
            child: (typeSelected[TypeSelect.virtualVisitMethod.title].length !=
                            0 &&
                        typeSelected[TypeSelect.visitType.title].contains(1)) ||
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
            child:
                typeSelected[TypeSelect.virtualVisitMethod.title].contains(1) &&
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
            child:
                typeSelected[TypeSelect.virtualVisitMethod.title].contains(2) &&
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
        ]));
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
                GestureDetector(
                  onTap: () {
                    widget.onPush(
                        NavigatorRoutes.doctorTimeTable,
                        typeSelected[TypeSelect.visitType.title].toList(),
                        plan, () {
                      setState(() {});
                    });
                  },
                  child: Container(
                      height: 350,
                      color: Color.fromARGB(0, 0, 0, 0),
                      child: EditableDoctorPlanEventTable(
                        plan,
                        [],
                        showEventTitle: false,
                        smallPreviewFlag: true,
                      )),
                ),
              ],
            )
          : SizedBox(),
    );
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
        daysWorkTimes: plan.virtualVisitType?.daysWorkTimes??[]);
  }

  VisitType getPhysicalVisitTypeDetail() {
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
        daysWorkTimes: plan.physicalVisitType?.daysWorkTimes??[]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
