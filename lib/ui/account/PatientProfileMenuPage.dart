import 'dart:io';

import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/ContactUsAndPolicy.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        aboutUsButton(context),
        ALittleVerticalSpace(),
        policyAndConditions(context),
        ALittleVerticalSpace(),
        paymentDescription(context),
        ALittleVerticalSpace(),
        contactUsButton(),
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
            child: AutoText(
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
                  AutoText(
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
