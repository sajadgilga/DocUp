import 'dart:async';

import 'package:docup/ui/main_page/MainPage.dart';
import 'package:docup/ui/notification/NotificationPage.dart';
import 'package:docup/ui/start/RoleType.dart';
import 'package:docup/bloc/TimerEvent.dart';
import 'package:docup/ui/widgets/InputField.dart';
import 'package:docup/ui/widgets/OptionButton.dart';
import 'package:docup/ui/widgets/Timer.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
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
    super.initState();
  }

  void switchRole(RoleType roleType) {
    _controller.add(roleType);
    setState(() {
      currentRoleType = roleType;
    });
  }

  void submit() {
    setState(() {
      switch (startType) {
        case StartType.SIGN_UP:
          startType = StartType.LOGIN;
          _timerBloc.dispatch(Start(duration: 60));
          break;
        case StartType.LOGIN:
          startType = StartType.REGISTER;
          break;
        case StartType.REGISTER:
          Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
          break;
      }
    });
  }

  void back() {
    setState(() {
      startType = StartType.SIGN_UP;
    });
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
            SizedBox(height: 10),
            _timerWidget(),
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
          padding: EdgeInsets.only(right: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              BlocProvider(bloc: _timerBloc, child: Timer()),
              Text(" : ارسال مجدد کد ", style: TextStyle(color: Colors.red)),
            ],
          ),
        )
      : SizedBox.shrink();

  _actionWidget() {
    switch (startType) {
      case StartType.SIGN_UP:
        return _signUpActionWidget();
      case StartType.LOGIN:
        return _loginActionWidget();
      case StartType.REGISTER:
        return _registerActionWidget();
    }
  }

  _loginActionWidget() => Padding(
      padding: EdgeInsets.only(left: 40.0, right: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ActionButton(
            color: Colors.grey,
            title: Strings.continueAction,
            callBack: submit,
          ),
          ActionButton(
            color: currentRoleType.color,
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
            callBack: back,
          ),
        ],
      ));

  _signUpActionWidget() => ActionButton(
        color: currentRoleType.color,
        title: Strings.verifyAction,
        icon: Icon(
          Icons.arrow_back_ios,
          size: 18,
        ),
        rtl: false,
        callBack: submit,
      );

  _registerActionWidget() => ActionButton(
        color: currentRoleType.color,
        title: Strings.registerAction,
        icon: Icon(
          Icons.arrow_back_ios,
          size: 18,
        ),
        rtl: false,
        callBack: submit,
      );

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
        visible: startType != StartType.LOGIN,
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
      child: Container(child: _inputFieldsInnerWidget()));

  _inputFieldsInnerWidget() {
    switch (startType) {
      case StartType.SIGN_UP:
        return currentRoleType == RoleType.PATIENT
            ? InputField(Strings.emailInputHint)
            : Column(
                children: <Widget>[
                  InputField(Strings.doctorIdInputHint),
                  InputField(Strings.emailInputHint)
                ],
              );
      case StartType.LOGIN:
        return InputField(Strings.verificationHint);
      case StartType.REGISTER:
        return Column(
          children: <Widget>[
            InputField(Strings.nameInputHint),
            InputField(Strings.passInputHint)
          ],
        );
    }
  }

  getTitleText() {
    switch (startType) {
      case StartType.SIGN_UP:
        return currentRoleType == RoleType.PATIENT
            ? Strings.yourDoctorMessage
            : Strings.yourPatientMessage;
      default:
        return Strings.welcome;
    }
  }

  getMessageText() {
    switch (startType) {
      case StartType.SIGN_UP:
        return currentRoleType == RoleType.PATIENT
            ? Strings.patientRegisterMessage
            : Strings.doctorRegisterMessage;
      case StartType.LOGIN:
        return Strings.verificationCodeMessage;
      case StartType.REGISTER:
        return currentRoleType == RoleType.PATIENT
            ? Strings.oneStepToDoctorMessage
            : Strings.oneStepToOfficeMessage;
    }
  }
}
