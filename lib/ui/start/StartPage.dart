import 'dart:async';

import 'package:docup/ui/start/RoleType.dart';
import 'package:docup/bloc/TimerEvent.dart';
import 'package:docup/UI/widgets/InputField.dart';
import 'package:docup/UI/widgets/OptionButton.dart';
import 'package:docup/UI/widgets/ActionButton.dart';
import 'package:docup/UI/widgets/Timer.dart';
import 'package:docup/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../bloc/TimerBloc.dart';
import '../../bloc/Tricker.dart';

enum StartType { SIGN_UP, LOGIN, REGISTER }

class StartPage extends StatefulWidget {
  StartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TimerBloc _timerBloc = TimerBloc(ticker: Ticker());
  StreamController<RoleType> _controller = BehaviorSubject();
  RoleType currentRoleType = RoleType.PATIENT;
  StartType startType = StartType.SIGN_UP;

  @override
  void initState() {
    switchRole(currentRoleType);
    _timerBloc.dispatch(Start(duration: 60));
    super.initState();
  }

  void switchRole(RoleType roleType) {
    _controller.add(roleType);
    setState(() {
      currentRoleType = roleType;
    });
  }

  void submit() {
    if (startType == StartType.SIGN_UP) {
      setState(() {
        startType = StartType.LOGIN;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 80),
            _headerWidget(),
            SizedBox(height: 20),
            _optionsWidget(),
            SizedBox(height: 40),
            _titleWidget(),
            SizedBox(height: 5),
            _messageWidget(),
            SizedBox(height: 50),
            _inputFieldsWidget(),
            _timerWidget(),
            BlocProvider(
              bloc: _timerBloc,
              child: Timer()
            ),
            SizedBox(height: 80),
            _actionWidget(),
            SizedBox(height: 20),
            _enterWidget()
          ],
        ),
      ),
    );
  }

  _timerWidget() => startType == StartType.LOGIN
      ? Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text("ارسال مجدد کد", style: TextStyle(color: Colors.red)),
        )
      : SizedBox.shrink();

  _actionWidget() => ActionButton(
      currentRoleType.color,
      Strings.registerAction,
      Icon(
        Icons.arrow_back_ios,
        size: 18.0,
      ),
      false,
      submit);

  _headerWidget() => Text(
        Strings.registerHeaderMessage,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );

  _optionsWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () => switchRole(RoleType.DOCTOR),
            child: OptionButton(RoleType.DOCTOR, stream: _controller.stream),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () => switchRole(RoleType.PATIENT),
            child: OptionButton(RoleType.PATIENT, stream: _controller.stream),
          )
        ],
      );

  _messageWidget() => Text(
        getMessageText(),
        style: TextStyle(fontSize: 13),
        textAlign: TextAlign.center,
      );

  _titleWidget() => Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: startType == StartType.SIGN_UP,
        child: Text(
          getTitleText(),
          style: TextStyle(
              color: currentRoleType.color,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      );

  _enterWidget() => Visibility(
        visible: startType == StartType.SIGN_UP,
        child:
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
        ]),
      );

  _inputFieldsWidget() => Padding(
      padding: EdgeInsets.only(left: 40.0, right: 40.0),
      child: Container(
          child: startType == StartType.LOGIN
              ? InputField(Strings.verificationHint)
              : currentRoleType == RoleType.PATIENT
                  ? InputField(Strings.emailInputHint)
                  : Column(
                      children: <Widget>[
                        InputField(Strings.doctorIdInputHint),
                        InputField(Strings.emailInputHint)
                      ],
                    )));

  getTitleText() {
    return currentRoleType == RoleType.PATIENT
        ? Strings.yourDoctorMessage
        : Strings.yourPatientMessage;
  }

  getMessageText() {
    return startType == StartType.LOGIN
        ? Strings.verificationCodeMessage
        : currentRoleType == RoleType.PATIENT
            ? Strings.patientRegisterMessage
            : Strings.doctorRegisterMessage;
  }
}
