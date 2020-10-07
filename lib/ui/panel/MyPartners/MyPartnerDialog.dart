import 'dart:convert';
import 'dart:io';

import 'package:docup/blocs/EntityBloc.dart';
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
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

import 'MyPartnersResultList.dart';

class MyPartnerDialog extends StatelessWidget {
  final Function(String, UserEntity) onPush;
  final isRequestPage;
  final DoctorEntity doctor;
  TextEditingController _controller = TextEditingController();

//  SearchBloc searchBloc = SearchBloc();

  MyPartnerDialog(
      {@required this.onPush,
      this.isRequestPage = false,
      @required this.doctor});

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller?.dispose();
  }

  Widget _image(context) {
    return Container(
        child: Container(
            width: 70,
            child: ClipPolygon(
              sides: 6,
              rotate: 90,
              child: Image.network(
                  (doctor.user.avatar != null ? doctor.user.avatar : '')),
            )));
  }

  Widget _nameAndExpertise(context) {
    String utfName;
    try {
      utfName = utf8.decode(doctor.user.name.toString().codeUnits);
    } catch (_) {
      utfName = doctor.user.name;
    }
    return Container(
      padding: EdgeInsets.only(right: 15),
      child: Text(
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

  Widget _doctorDetail(context) {
    return Padding(
      padding: EdgeInsets.only(top: 30, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[_info(context), _image(context)],
      ),
    );
  }

  Widget _myDoctorItem(Function() onTap, String iconAddress, String header,
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
                      child: Text(
                        header,
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.fade,
                        softWrap: true,
                        style: TextStyle(fontSize: 13.5, color: headerColor),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
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
              topRightFlag: true,
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
            _doctorDetail(context),
            SizedBox(
              height: 35,
            ),
            _myDoctorItem(
                () {},
                Assets.panelDoctorDialogDoctorIcon,
                "ویزیت پزشک",
                "ویزیت مجازی با پزشک خود را دنبال کنید",
                IColors.blue),
            _myDoctorItem(
                () {},
                Assets.panelDoctorDialogPatientIcon,
                "پرونده سلامت",
                "پرونده سلامت اتان را بررسی کنید",
                IColors.green),
            _myDoctorItem(
                () {},
                Assets.panelDoctorDialogAppointmentIcon,
                "رویداد های سلامت",
                "رویداد های سلامت اتان را پیگیری کنید",
                IColors.black),
          ],
        ),
      ),
    );
  }
}
