import 'dart:async';

import 'package:docup/UI/loginUI/RoleType.dart';
import 'package:docup/UI/widgets/InputField.dart';
import 'package:docup/UI/widgets/OptionButton.dart';
import 'package:docup/UI/widgets/RegisterActionButton.dart';
import 'package:docup/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rxdart/rxdart.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  StreamController<RoleType> _controller = BehaviorSubject();
  RoleType currentRoleType = RoleType.PATIENT;

  @override
  void initState() {
    switchRole(currentRoleType);
    super.initState();
  }

  void switchRole(RoleType roleType) {
    _controller.add(roleType);
    setState(() {
      currentRoleType = roleType;
    });
  }

  _inputFields() => Container(
      child: currentRoleType == RoleType.PATIENT
          ? InputField(Strings.emailInputHint)
          : Column(
              children: <Widget>[
                InputField(Strings.doctorIdInputHint),
                InputField(Strings.emailInputHint)
              ],
            ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 80),
            Text(
              Strings.registerHeaderMessage,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => switchRole(RoleType.DOCTOR),
                      child: OptionButton(RoleType.DOCTOR,
                          stream: _controller.stream),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => switchRole(RoleType.PATIENT),
                      child: OptionButton(RoleType.PATIENT,
                          stream: _controller.stream),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            Text(
              currentRoleType == RoleType.PATIENT
                  ? Strings.yourDoctorMessage
                  : Strings.yourPatientMessage,
              style: TextStyle(
                  color: currentRoleType.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              currentRoleType == RoleType.PATIENT
                  ? Strings.patientRegisterMessage
                  : Strings.doctorRegisterMessage,
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.only(left: 40.0, right: 40.0),
              child: _inputFields(),
            ),
            SizedBox(height: 80.0),
            RegisterActionButton(currentRoleType.color),
            SizedBox(height: 20.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(Strings.enterAction,
                  style: TextStyle(
                      fontSize: 13,
                      color: currentRoleType.color,
                      decoration: TextDecoration.underline)),
              SizedBox(
                width: 10.0,
              ),
              Text(Strings.accountQuestion, style: TextStyle(fontSize: 13)),
            ])
          ],
        ),
      ),
    );
  }
}
