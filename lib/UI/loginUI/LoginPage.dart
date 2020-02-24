import 'dart:async';

import 'package:docup/UI/loginUI/RoleType.dart';
import 'package:docup/UI/widgets/OptionButton.dart';
import 'package:docup/UI/widgets/RegisterActionButton.dart';
import 'package:docup/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rxdart/rxdart.dart';

import '../../constants/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      theme: ThemeData(
        fontFamily: 'iransans',
        primarySwatch: MaterialColor(0xFF880E4F, swatch),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  StreamController<RoleType> _controller = BehaviorSubject();

  void switchRole(RoleType roleType) {
    _controller.add(roleType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                Strings.yourDoctorMessage,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                Strings.registerMessage,
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.only(left: 40.0, right: 40.0),
                child: TextFormField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                      hintText: Strings.registerInputHint,
                      hintStyle: TextStyle(color: Colors.black, fontSize: 16.0),
                      labelStyle: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(height: 80.0),
              RegisterActionButton(),
              SizedBox(height: 20.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(Strings.enterAction,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                            decoration: TextDecoration.underline)),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(Strings.accountQuestion,
                        style: TextStyle(fontSize: 13)),
                  ])
            ],
          ),
        ],
      ),
    );
  }
}
