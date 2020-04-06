import 'dart:async';
import 'package:docup/blocs/LoginBloc.dart';
import 'package:docup/blocs/UpdatePatientBloc.dart';
import 'package:docup/blocs/VerifyBloc.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/mainPage/MainPage.dart';
import 'package:docup/ui/start/RoleType.dart';
import 'package:docup/blocs/timer/TimerEvent.dart';
import 'package:docup/ui/widgets/InputField.dart';
import 'package:docup/ui/widgets/OptionButton.dart';
import 'package:docup/ui/widgets/Timer.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rxdart/rxdart.dart';

import '../../blocs/timer/TimerBloc.dart';
import '../../blocs/timer/Tricker.dart';

enum StartType { SIGN_UP, LOGIN, REGISTER }

class StartPage extends StatefulWidget {
  StartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TimerBloc _timerBloc = TimerBloc(ticker: Ticker());
  final LoginBloc _loginBloc = LoginBloc();
  final VerifyBloc _verifyBloc = VerifyBloc();
  final UpdatePatientBloc _updatePatientBloc = UpdatePatientBloc();

  StreamController<RoleType> _controller = BehaviorSubject();
  final _usernameController = TextEditingController();
  final _verificationController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();

  RoleType currentRoleType = RoleType.PATIENT;
  StartType startType = StartType.SIGN_UP;
  ProgressDialog progressDialog;

  String currentUserName;

  handle(ProgressDialog pd, Response response) {
    switch (response.status) {
      case Status.LOADING:
        pd.show();
        return false;
      case Status.ERROR:
        pd.dismiss();
        return false;
      default:
        pd.dismiss();
        return true;
    }
  }

  @override
  void initState() {
    switchRole(currentRoleType);
    _loginBloc.dataStream.listen((data) {
      if (handle(progressDialog, data)) {
        currentUserName = _usernameController.text;
        _usernameController.clear();
        setState(() {
          startType = StartType.LOGIN;
        });
        _timerBloc.dispatch(Start(duration: 60));
      }
    });

    _verifyBloc.dataStream.listen((data) {
      if (handle(progressDialog, data)) {
        setState(() {
          startType = StartType.REGISTER;
        });
      }
    });

    _updatePatientBloc.dataStream.listen((data) {
      if (handle(progressDialog, data)) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainPage()));
      }
    });

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
          _loginBloc.login(_usernameController.text);
          break;
        case StartType.LOGIN:
          _verifyBloc.verify(currentUserName, _verificationController.text);
          break;
        case StartType.REGISTER:
          _updatePatientBloc.update(
              _fullNameController.text, _passwordController.text);
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
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.style(message: "لطفا منتظر بمانید");

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

  @override
  void dispose() {
    _usernameController.dispose();
    _verificationController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            ? InputField(
                inputHint: Strings.usernameInputHint,
                controller: _usernameController,
              )
            : Column(
                children: <Widget>[
                  InputField(
                    inputHint: Strings.doctorIdInputHint,
                    /*controller: _inputController*/
                  ),
                  InputField(
                    inputHint: Strings
                        .usernameInputHint, /*controller: _inputController*/
                  )
                ],
              );
      case StartType.LOGIN:
        return InputField(
          inputHint: Strings.verificationHint,
          controller: _verificationController, /*controller: _inputController*/
        );
      case StartType.REGISTER:
        return Column(
          children: <Widget>[
            InputField(
              inputHint: Strings.nameInputHint,
              /*controller: _inputController*/
              controller: _fullNameController,
            ),
            InputField(
              inputHint: Strings.passInputHint,
              /*controller: _inputController*/
              controller: _passwordController, /*controller: _inputController*/
            )
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
