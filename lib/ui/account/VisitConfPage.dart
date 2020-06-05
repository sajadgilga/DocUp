import 'dart:async';
import 'dart:typed_data';

import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/visit/VisitUtils.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/blocs/CreditBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/MapWidget.dart';
import 'package:docup/ui/widgets/PriceWidget.dart';
import 'package:docup/ui/widgets/TimeSelectorHeaderWidget.dart';
import 'package:docup/ui/widgets/TimeSelectorWidget.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/ui/widgets/LabelAndListWidget.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show PlatformException;

class VisitConfPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final Function(String, dynamic) onPush;

  VisitConfPage({Key key, @required this.onPush, this.doctorEntity})
      : super(key: key);

  @override
  _VisitConfPageState createState() => _VisitConfPageState();
}

class _VisitConfPageState extends State<VisitConfPage> {
  Map<String, int> typeSelected = {
    VISIT_METHOD: VisitMethod.TEXT.index,
    VISIT_DURATION_PLAN: VisitDurationPlan.BASE.index
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            callback: (title, index) {
              setState(() {
                typeSelected[title] = index;
              });
            },
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
            callback: (title, index) {
              setState(() {
                typeSelected[title] = index;
              });
            },
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
            price: "300,000",
          ),
          PriceWidget(
            title: "مشاوره متنی",
            price: "100,000",
          ),
          ALittleVerticalSpace(),
          LabelAndListWidget(
            smallSize: true,
            title: "وقت ویزیت",
            items: ["مجازی", "مجازی"],
            selectedIndex: typeSelected["وقت ویزیت"],
            callback: (title, index) {
              setState(() {
                typeSelected[title] = index;
              });
            },
          ),
          ALittleVerticalSpace(),
          TimeSelectorHeaderWidget(callback: (timeIsSelected) {
            setState(() {
              this.timeIsSelected = timeIsSelected;
            });
          }),
          _timeAndDateSelectorWidget(),
          MediumVerticalSpace(),
//          _repeatableForSelectedDaysWidget(),
          ALittleVerticalSpace(),
          ActionButton(
            title: "ثبت اطلاعات برای بررسی",
            color: IColors.themeColor,
            callBack: submit,
          )
        ]));
  }

  bool timeIsSelected = true;

  Widget _timeAndDateSelectorWidget() {
    if (timeIsSelected) {
      return Column(
        children: <Widget>[
          TimeSelectorWidget(),
          MediumVerticalSpace(),
          _helpWidget(context),
        ],
      );
    } else {
      return LabelAndListWidget(
        smallSize: true,
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
        callback: (title, index) {
          setState(() {
            typeSelected[title] = index;
          });
        },
      );
    }
  }

  void submit() {}

  Row _repeatableForSelectedDaysWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text("تکرار برای بقیه روز های انتخاب شده"),
        Checkbox(
          value: repeatableForSelectedDays,
          onChanged: (value) {
            setState(() {
              repeatableForSelectedDays = value;
            });
          },
        ),
      ],
    );
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
}
