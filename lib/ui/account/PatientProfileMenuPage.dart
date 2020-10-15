import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/DoctorCreditWidget.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/MapWidget.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show PlatformException;

class PatientProfileMenuPage extends StatefulWidget {
  final Function(String, dynamic) onPush;
  final PatientEntity patientEntity;

  PatientProfileMenuPage({Key key, @required this.onPush, this.patientEntity})
      : super(key: key);

  @override
  _PatientProfileMenuPageState createState() => _PatientProfileMenuPageState();
}

class _PatientProfileMenuPageState extends State<PatientProfileMenuPage> {
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    _phoneNumberController.text = widget.patientEntity.user.phoneNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        MediumVerticalSpace(),
        Stack(
          alignment: Alignment.center,
          children: [
            PageTopLeftIcon(
              topLeft: Icon(
                Icons.arrow_back,
                size: 25,
              ),
              onTap: () {
                /// TODO
                widget.onPush(NavigatorRoutes.root, null);
              },
              topRightFlag: false,
              topLeftFlag: Platform.isIOS,
            ),
            DocUpHeader(
              title: "پروفایل من",
              docUpLogo: false,
            ),
          ],
        ),
        MediumVerticalSpace(),
        MediumVerticalSpace(),
        _accountSetting(),
        ALittleVerticalSpace(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text("درباره ما",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
        ALittleVerticalSpace(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text("قوانین و شرایط",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
        ALittleVerticalSpace(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text("ارتباط با ما",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
        ActionButton(
          color: IColors.red,
          title: "خروج از حساب کاربری",
          callBack: logout,
          width: 200,
          height: 60,
        ),
        ALittleVerticalSpace()
      ],
    ));
  }

  Widget _accountSetting() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
              "تنطیمات اکانت",
              softWrap: true,
              overflow: TextOverflow.fade,
              textAlign: TextAlign.end,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 17, color: IColors.black),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            color: Colors.white,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        style: TextStyle(fontSize: 18, color: IColors.darkGrey),
                        textAlign: TextAlign.center,
                        controller: _phoneNumberController,
                        enabled: false,
                        decoration: InputDecoration(border: InputBorder.none),
                      ),
                    ),
                  ),
                  Text(
                    "شماره تلفن",
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: TextStyle(fontSize: 15, color: IColors.darkGrey),
                  )
                ]),
          )
        ],
      ),
    );
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("isPatient");
    exit(0);
  }
}
