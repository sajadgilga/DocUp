import 'dart:convert';
import 'dart:io';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/blocs/VisitBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/home/SearchBox.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

import 'MyPartnersResultList.dart';

class MyPartnerDialog extends StatelessWidget {
  final Function(String, UserEntity) onPush;
  final isRequestPage;
  final UserEntity partner;
  TextEditingController _controller = TextEditingController();

//  SearchBloc searchBloc = SearchBloc();

  MyPartnerDialog(
      {@required this.onPush,
      this.isRequestPage = false,
      @required this.partner});

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller?.dispose();
  }

  Widget _image(context) {
    return Container(
        child: Container(
            width: 70,
            child: PolygonAvatar(
              user: partner.user,
            )));
  }

  Widget _nameAndExpertise(context) {
    String utfName;
    try {
      utfName = utf8.decode(partner.user.name.toString().codeUnits);
    } catch (_) {
      utfName = partner.user.name;
    }
    return Container(
      padding: EdgeInsets.only(right: 15),
      child: AutoText(
        utfName,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _info(context) {
    return Expanded(
      flex: 2,
      child: Container(
          margin: EdgeInsets.only(right: 10, left: 15),
          child: _nameAndExpertise(context)),
    );
  }

  Widget _partnerDetail(context) {
    return Padding(
      padding: EdgeInsets.only(top: 30, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[_info(context), _image(context)],
      ),
    );
  }

  Widget _myPartnerItem(Function() onTap, String iconAddress, String header,
      String subHeader, Color headerColor) {
    double iconSize = 43;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: GestureDetector(
        child: Container(
          height: 90,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey, blurRadius: 10, spreadRadius: -1)
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 7),
                      child: AutoText(
                        header,
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.fade,
                        softWrap: true,
                        style: TextStyle(
                            fontSize: 13.5,
                            color: headerColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: AutoText(
                          subHeader,
                          textDirection: TextDirection.rtl,
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          style:
                              TextStyle(fontSize: 12, color: IColors.darkGrey),
                        ))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: iconSize,
                  child: Image.asset(iconAddress, width: iconSize),
                ),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            PageTopLeftIcon(
              topLeft: Icon(
                Icons.arrow_back,
                color: IColors.themeColor,
                size: 20,
              ),
              topLeftFlag: Platform.isIOS,
              topRight: Container(
                  child: Image.asset(Assets.logoTransparent, width: 50)),
              topRightFlag: false,
              onTap: () {
                onPush(NavigatorRoutes.root, null);
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: menuLabel("(کلینیک نورونیو)",
                        fontSize: 12, divider: false),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: menuLabel("پنل کاربری"),
                  ),
                ],
              ),
            ),
            _partnerDetail(context),
            SizedBox(
              height: 35,
            ),
            (partner is DoctorEntity) ? _myDoctorItems(context) : SizedBox(),
            (partner is PatientEntity) ? _myPatientItems(context) : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _myDoctorItems(context) {
    return Column(
      children: [
        _myPartnerItem(() {
          /// navigation
          var _panelSectionBloc = BlocProvider.of<PanelSectionBloc>(context);
          _panelSectionBloc.add(PanelSectionSelect(
              patientSection: PatientPanelSection.DOCTOR_INTERFACE));
          onPush(NavigatorRoutes.panel, partner);

          /// #
        }, Assets.panelDoctorDialogDoctorIcon, "ویزیت پزشک",
            "ویزیت مجازی با پزشک خود را دنبال کنید", IColors.blue),
        _myPartnerItem(() {
          /// navigation
          var _panelSectionBloc = BlocProvider.of<PanelSectionBloc>(context);
          _panelSectionBloc.add(PanelSectionSelect(
              patientSection: PatientPanelSection.HEALTH_FILE));
          onPush(NavigatorRoutes.panel, partner);

          /// #
        }, Assets.panelDoctorDialogPatientIcon, "پرونده سلامت",
            "پرونده سلامت اتان را بررسی کنید", IColors.green),
        _myPartnerItem(() {
          /// navigation

          var _panelSectionBloc = BlocProvider.of<PanelSectionBloc>(context);
          _panelSectionBloc.add(PanelSectionSelect(
              patientSection: PatientPanelSection.HEALTH_CALENDAR));
          onPush(NavigatorRoutes.panel, partner);

          /// #
        }, Assets.panelDoctorDialogAppointmentIcon, "رویداد های سلامت",
            "رویداد های سلامت اتان را پیگیری کنید", IColors.black),
      ],
    );
    ;
  }

  Widget _myPatientItems(context) {
    return Column(
      children: [
        _myPartnerItem(() {
          /// navigation

          var _panelSectionBloc = BlocProvider.of<PanelSectionBloc>(context);
          _panelSectionBloc.add(PanelSectionSelect(
              patientSection: PatientPanelSection.DOCTOR_INTERFACE));
          onPush(NavigatorRoutes.panel, partner);

          /// #
        }, Assets.panelDoctorDialogDoctorIcon, "ویزیت بیمار",
            "ویزیت محازی و حضوری بیمار", IColors.themeColor),
        _myPartnerItem(() {
          /// navigation

          var _panelSectionBloc = BlocProvider.of<PanelSectionBloc>(context);
          _panelSectionBloc.add(
              PanelSectionSelect(patientSection: PatientPanelSection.HEALTH_FILE));
          onPush(NavigatorRoutes.panel, partner);

          /// #
        }, Assets.panelDoctorDialogPatientIcon, "پرونده سلامت",
            "پرونده سلامت اتان را بررسی کنید", IColors.black),
        _myPartnerItem(() {
          /// navigation

          var _panelSectionBloc = BlocProvider.of<PanelSectionBloc>(context);
          _panelSectionBloc.add(PanelSectionSelect(
              patientSection: PatientPanelSection.HEALTH_CALENDAR));
          onPush(NavigatorRoutes.panel, partner);

          /// #
        }, Assets.panelDoctorDialogAppointmentIcon, "رویداد های سلامت",
            "رویداد های سلامت اتان را پیگیری کنید", IColors.red),
      ],
    );
  }
}
