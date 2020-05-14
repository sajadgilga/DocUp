import 'dart:async';
import 'package:docup/blocs/AuthBloc.dart';
import 'package:docup/blocs/DoctorBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PatientBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/BasePage.dart';
import 'package:docup/ui/mainPage/MainPage.dart';
import 'package:docup/ui/start/RoleType.dart';
import 'package:docup/blocs/timer/TimerEvent.dart';
import 'package:docup/ui/widgets/InputField.dart';
import 'package:docup/ui/widgets/OptionButton.dart';
import 'package:docup/ui/widgets/Timer.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/timer/TimerBloc.dart';
import '../../blocs/timer/Tricker.dart';

enum StartType { SIGN_UP, LOGIN, REGISTER, SIGN_IN }

class StartPage extends StatefulWidget {
  StartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TimerBloc _timerBloc = TimerBloc(ticker: Ticker());
  final AuthBloc _authBloc = AuthBloc();
  final PatientBloc _patientBloc = PatientBloc();
  final DoctorBloc _doctorBloc = DoctorBloc();

  StreamController<RoleType> _controller = BehaviorSubject();
  final _usernameController = TextEditingController();
  final _doctorIdController = TextEditingController();
  final _verificationController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();

  RoleType currentRoleType = RoleType.PATIENT;
  StartType startType = StartType.SIGN_UP;
  AlertDialog _loadingDialog = getLoadingDialog();
  bool _loadingEnable;

  String currentUserName;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  handle(Response response) {
    switch (response.status) {
      case Status.LOADING:
        showDialog(
            context: context,
            builder: (BuildContext context) => _loadingDialog);
        _loadingEnable = true;
        return false;
      case Status.ERROR:
        if (_loadingEnable) {
          Navigator.of(context).pop();
          _loadingEnable = false;
        }
        showErrorSnackBar(response.message);
        return false;
      default:
        if (_loadingEnable) {
          Navigator.of(context).pop();
          _loadingEnable = false;
        }
        return true;
    }
  }

  showErrorSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    ));
  }

  Future<void> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("token")) {
      bool isPatient = prefs.getBool("isPatient");
      switchRole(isPatient ? RoleType.PATIENT : RoleType.DOCTOR);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BasePage()));
    }
  }

  @override
  void initState() {
    switchRole(currentRoleType);
    checkToken();
    _authBloc.signUpStream.listen((data) {
      if (handle(data)) {
        currentUserName = _usernameController.text;
        _usernameController.clear();
        setState(() {
          startType = StartType.LOGIN;
        });
        _timerBloc.add(Start(duration: 60));
      }
    });

    _authBloc.verifyStream.listen((data) {
      if (handle(data)) {
        setState(() {
          startType = StartType.REGISTER;
        });
      }
    });

    _authBloc.signInStream.listen((data) {
      if (handle(data)) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BasePage()));
      }
    });

    _patientBloc.dataStream.listen((data) {
      if (handle(data)) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BasePage()));
      }
    });

    _doctorBloc.doctorStream.listen((data) {
      if (handle(data)) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BasePage()));
      }
    });
    super.initState();
  }

  void switchRole(RoleType roleType) {
    _controller.add(roleType);
    BlocProvider.of<EntityBloc>(context).add(EntityChangeType(type: roleType));
    setState(() {
      currentRoleType = roleType;
    });
  }

  void submit() {
    if (_formKey.currentState.validate()) {
      setState(() {
        switch (startType) {
          case StartType.SIGN_UP:
            _authBloc.signUp(_usernameController.text, currentRoleType);
            break;
          case StartType.LOGIN:
            _authBloc.verify(currentUserName, _verificationController.text,
                currentRoleType == RoleType.PATIENT);
            break;
          case StartType.REGISTER:
            if (currentRoleType == RoleType.PATIENT) {
              _patientBloc.update(
                  _fullNameController.text, _passwordController.text);
            } else if (currentRoleType == RoleType.DOCTOR) {
              _doctorBloc.update(
                  _fullNameController.text, _passwordController.text);
            }
            break;
          case StartType.SIGN_IN:
            _authBloc.signIn(_usernameController.text, _passwordController.text,
                currentRoleType == RoleType.PATIENT);
            break;
        }
      });
    }
  }

  void back() {
    _verificationController.text = "";
    setState(() {
      startType = StartType.SIGN_UP;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (startType == StartType.LOGIN || startType == StartType.SIGN_IN) {
          setState(() {
            startType = StartType.SIGN_UP;
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                SizedBox(height: 50),
                _actionWidget(),
                SizedBox(height: 20),
                _enterWidget(),
                SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    _usernameController.dispose();
    _doctorIdController.dispose();
    _verificationController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _authBloc.dispose();
    _patientBloc.dispose();
    _doctorBloc.dispose();
    super.dispose();
  }

  _timerWidget() => startType == StartType.LOGIN
      ? Padding(
          padding: EdgeInsets.only(right: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              BlocProvider(create: (context) => _timerBloc, child: Timer()),
              Text(" : ارسال مجدد کد ",
                  style: TextStyle(
                      color: IColors.themeColor, fontWeight: FontWeight.bold)),
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
      case StartType.SIGN_IN:
        return _signInActionWidget();
        break;
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
          GestureDetector(
            onTap: back,
            child: Container(
                decoration: BoxDecoration(
                    color: IColors.themeColor,
                    borderRadius: BorderRadius.all(Radius.circular(30.0))),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Icon(Icons.arrow_forward_ios,
                      size: 18, color: Colors.white),
                )),
          ),
        ],
      ));

  _signUpActionWidget() => ActionButton(
        color: IColors.themeColor,
        title: Strings.verifyAction,
        icon: Icon(
          Icons.arrow_back_ios,
          size: 18,
        ),
        rtl: false,
        callBack: submit,
      );

  _registerActionWidget() => ActionButton(
        color: IColors.themeColor,
        title: Strings.registerAction,
        icon: Icon(
          Icons.arrow_back_ios,
          size: 18,
        ),
        rtl: false,
        callBack: submit,
      );

  _signInActionWidget() => ActionButton(
        color: IColors.themeColor,
        title: Strings.enterAction,
        icon: Icon(
          Icons.arrow_back_ios,
          size: 18,
        ),
        rtl: false,
        callBack: submit,
      );

  _headerWidget() => Text(
        startType == StartType.SIGN_IN
            ? Strings.signInHeaderMessage
            : Strings.registerHeaderMessage,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );

  _optionsWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
              visible: currentRoleType == RoleType.DOCTOR ||
                  startType == StartType.SIGN_UP,
              child: GestureDetector(
                onTap: () => switchRole(RoleType.DOCTOR),
                child:
                    OptionButton(RoleType.DOCTOR, stream: _controller.stream),
              )),
          SizedBox(width: 10),
          Visibility(
            visible: currentRoleType == RoleType.PATIENT ||
                startType == StartType.SIGN_UP,
            child: GestureDetector(
              onTap: () => switchRole(RoleType.PATIENT),
              child: OptionButton(RoleType.PATIENT, stream: _controller.stream),
            ),
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
              color: IColors.themeColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      );

  _enterWidget() => Visibility(
        visible: startType == StartType.SIGN_UP,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                startType = StartType.SIGN_IN;
              });
            },
            child: Text(Strings.enterAction,
                style: TextStyle(
                    fontSize: 13,
                    color: IColors.themeColor,
                    decoration: TextDecoration.underline)),
          ),
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
                textInputType: TextInputType.phone,
                validationCallback: (text) => validatePhoneNumber(text),
                errorMessage: "شماره همراه معتبر نیست",
              )
            : Column(
                children: <Widget>[
                  InputField(
                    inputHint: Strings.doctorIdInputHint,
                    textInputType: TextInputType.number,
                    needToHideKeyboard: false,
                    validationCallback: (text) => text.length >= 4,
                    errorMessage: "شماره نظام پزشکی معتبر نیست",
                    controller: _doctorIdController,
                  ),
                  InputField(
                    inputHint: Strings.usernameInputHint,
                    textInputType: TextInputType.phone,
                    validationCallback: (text) => validatePhoneNumber(text),
                    controller: _usernameController,
                    errorMessage: "شماره همراه معتبر نیست",
                  )
                ],
              );
      case StartType.LOGIN:
        return InputField(
          inputHint: Strings.verificationHint,
          controller: _verificationController,
          textInputType: TextInputType.number,
          validationCallback: (text) => text.length == 6,
          errorMessage: "کدفعالسازی ۶رقمی است",
        );
      case StartType.REGISTER:
        return Column(
          children: <Widget>[
            InputField(
              inputHint: Strings.nameInputHint,
              controller: _fullNameController,
              validationCallback: (text) => true,
              needToHideKeyboard: false,
            ),
            InputField(
              inputHint: Strings.passInputHint,
              validationCallback: (text) => text.length >= 4,
              errorMessage: "رمز عبور بایستی حداقل ۴ کاراکتری باشد",
              obscureText: true,
              needToHideKeyboard: false,
              controller: _passwordController,
            )
          ],
        );
      case StartType.SIGN_IN:
        return Column(
          children: <Widget>[
            InputField(
              inputHint: Strings.usernameInputHint,
              textInputType: TextInputType.phone,
              validationCallback: (text) => validatePhoneNumber(text),
              controller: _usernameController,
              errorMessage: "شماره همراه معتبر نیست",
            ),
            InputField(
              inputHint: Strings.passInputHint,
              validationCallback: (text) => text.length >= 4,
              errorMessage: "رمز عبور بایستی حداقل ۴ کاراکتری باشد",
              obscureText: true,
              needToHideKeyboard: false,
              controller: _passwordController,
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
      default:
        return "";
    }
  }
}
