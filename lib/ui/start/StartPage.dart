import 'dart:async';

import 'package:docup/blocs/AuthBloc.dart';
import 'package:docup/blocs/DoctorBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PatientBloc.dart';
import 'package:docup/blocs/timer/TimerEvent.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/networking/CustomException.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/BasePage.dart';
import 'package:docup/ui/start/RoleType.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/ContactUsAndPolicy.dart';
import 'package:docup/ui/widgets/InputField.dart';
import 'package:docup/ui/widgets/OptionButton.dart';
import 'package:docup/ui/widgets/SnackBar.dart';
import 'package:docup/ui/widgets/Timer.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  TimerBloc _timerBloc = TimerBloc(ticker: Ticker());
  final AuthBloc _authBloc = AuthBloc();
  final PatientBloc _patientBloc = PatientBloc();
  final DoctorBloc _doctorBloc = DoctorBloc();

  StreamController<RoleType> _controller = BehaviorSubject();
  final _usernameController = TextEditingController();
  final _doctorIdController = TextEditingController();
  final _verificationController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nationalCodeController = TextEditingController();
  final _expertiseCodeController = TextEditingController();

  RoleType currentRoleType = RoleType.PATIENT;
  StartType startType = StartType.SIGN_UP;
  AlertDialog _loadingDialog = getLoadingDialog();
  bool _loadingEnable;
  bool validationFormError = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  handle(Response response) {
    switch (response.status) {
      case Status.LOADING:
        showDialog(
            context: context,
            builder: (BuildContext context) => _loadingDialog,
            barrierDismissible: false);
        _loadingEnable = true;
        return false;
      case Status.ERROR:
        if (_loadingEnable) {
          Navigator.of(context).pop();
          _loadingEnable = false;
        }
        if (((response.error.runtimeType) == ApiException)) {
          if ((response.error as ApiException).getCode() == 615) {
            showSnackBar(_scaffoldKey, Strings.errorCode_615, secs: 10);
          } else if ((response.error as ApiException).getCode() == 616) {
            /// TODO amir:
            showSnackBar(_scaffoldKey, Strings.errorCode_616, secs: 10);
          } else {
            showSnackBar(
              _scaffoldKey,
              response.error.toString(),
            );
          }
        } else
          showSnackBar(
            _scaffoldKey,
            response.error.toString(),
          );
        return false;
      case Status.COMPLETED:
        if (_loadingEnable) {
          Navigator.of(context).pop();
          _loadingEnable = false;
        }
        if (response.data.runtimeType == VerifyResponseEntity) {
          try {
            String firstName =
                (utf8IfPossible(response.data.firstName) ?? "").trim();
            _firstNameController.text = firstName;
            String lastName =
                (utf8IfPossible(response.data.lastName) ?? "").trim();
            _lastNameController.text = lastName;
            String nationalCode =
                (utf8IfPossible(response.data.nationalCode) ?? "").trim();
            _nationalCodeController.text = nationalCode;
            if (firstName + lastName + nationalCode == "") {
              showDescriptionAlertDialog(context,
                  title: Strings.privacyAndPolicy,
                  description: Strings.policyDescription);
            }
          } catch (e) {}
        }
        return true;
      default:
        if (_loadingEnable) {
          Navigator.of(context).pop();
          _loadingEnable = false;
        }
        return true;
    }
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

  Future<void> checkPrivacyAndPolicyFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShown = false;
    if (prefs.containsKey("privacyAndPolicy")) {
      hasShown = prefs.getBool("privacyAndPolicy");
    }
    if (!hasShown) {
      showDescriptionAlertDialog(context,
          title: Strings.privacyAndPolicy,
          description: Strings.policyDescription);
    }
    prefs.setBool("privacyAndPolicy", true);
  }

  bool resendCodeEnabled = false;

  void resetTimer() {
    _timerBloc = TimerBloc(ticker: Ticker());
    _timerBloc.add(Start(duration: 60));
    listenToTime();
  }

  @override
  void initState() {
    switchRole(currentRoleType);
    checkToken();
    listenToTime();
    _authBloc.loginStream.listen((data) {
      if (handle(data)) {
        setState(() {
          startType = StartType.LOGIN;
        });
        _timerBloc.add(Start(duration: 60));
      }
    });

    _authBloc.verifyStream.listen((data) {
      if (handle(data)) {
        if (_firstNameController.text +
                _lastNameController.text +
                _nationalCodeController.text !=
            "") {
          /// user has been registered before
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BasePage()));
        } else {
          setState(() {
            startType = StartType.REGISTER;
          });
        }
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

  void listenToTime() {
    _timerBloc.listen((time) {
      setState(() {
        resendCodeEnabled = time.duration == 0;
      });
    });
  }

  void switchRole(RoleType roleType) {
    _controller.add(roleType);
    BlocProvider.of<EntityBloc>(context).add(EntityChangeType(type: roleType));
    setState(() {
      currentRoleType = roleType;
    });
  }

  void submit({bool resend}) {
    if (_formKey.currentState.validate() &&
        !(_loadingEnable != null && _loadingEnable)) {
      setState(() {
        switch (startType) {
          case StartType.SIGN_UP:
            _authBloc.loginWithUserName(
                _usernameController.text, currentRoleType);
            break;
          case StartType.LOGIN:
            if (resend != null && resend) {
              _authBloc.login(currentRoleType);
              resetTimer();
            } else {
              _authBloc.verify(_verificationController.text,
                  currentRoleType == RoleType.PATIENT);
            }
            break;
          case StartType.REGISTER:
            if (currentRoleType == RoleType.PATIENT) {
              _patientBloc.updateProfile(
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  nationalCode: _nationalCodeController.text);
            } else if (currentRoleType == RoleType.DOCTOR) {
              _doctorBloc.updateProfile(
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  nationalCode: _nationalCodeController.text,
                  expertise: _expertiseCodeController.text);
            }
            break;
        }
      });
    }
  }

  void showValidationFormError() {
    setState(() {
      validationFormError = true;
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        validationFormError = false;
      });
    });
  }

  void back() {
    _verificationController.text = "";
    setState(() {
      startType = StartType.SIGN_UP;
    });
    resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    checkPrivacyAndPolicyFlag();
    return WillPopScope(
      onWillPop: () async {
        if (startType == StartType.LOGIN) {
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
                GestureDetector(
                  child: _titleWidget(),
                  onTap: () {
                    showDescriptionAlertDialog(context,
                        title: Strings.privacyAndPolicy,
                        description: Strings.policyDescription);
                  },
                ),
                SizedBox(height: 5),
                _messageWidget(),
                SizedBox(height: 50),
                _inputFieldsWidget(),
                SizedBox(height: 10),
                _timerWidget(),
                SizedBox(height: 50),
                _actionWidget(),
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
    try {
      _controller.close();
      _usernameController.dispose();
      _doctorIdController.dispose();
      _verificationController.dispose();
      _firstNameController.dispose();
      _authBloc.dispose();
      _patientBloc.dispose();
      _doctorBloc.dispose();
    } catch (e) {}
    super.dispose();
  }

  _timerWidget() => startType == StartType.LOGIN
      ? Padding(
          padding: EdgeInsets.only(right: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Visibility(
                  visible: !resendCodeEnabled,
                  child: BlocProvider(
                      create: (context) => _timerBloc, child: Timer())),
              GestureDetector(
                onTap: () => submit(resend: true),
                child: AutoText(" ارسال مجدد کد",
                    style: TextStyle(
                        color: IColors.themeColor,
                        fontWeight: FontWeight.bold,
                        decoration: resendCodeEnabled
                            ? TextDecoration.underline
                            : TextDecoration.none)),
              ),
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
          GestureDetector(
            onTap: back,
            child: Container(
                decoration: BoxDecoration(
                    color: IColors.themeColor,
                    borderRadius: BorderRadius.all(Radius.circular(30.0))),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child:
                      Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
                )),
          ),
          ActionButton(
            color: isContinueEnable ? IColors.themeColor : Colors.grey,
            title: Strings.continueAction,
            callBack: submit,
          ),
        ],
      ));

  _signUpActionWidget() => ActionButton(
        color: IColors.themeColor,
        title: Strings.verifyAction,
        width: 130,
        rightIcon: Icon(
          Icons.arrow_forward_ios,
          size: 15,
        ),
        rtl: false,
        callBack: submit,
      );

  _registerActionWidget() => ActionButton(
        color: validationFormError ? IColors.red : IColors.themeColor,
        title: Strings.registerAction,
        icon: Icon(
          Icons.arrow_back_ios,
          size: 18,
        ),
        rtl: false,
        callBack: submit,
      );

  _headerWidget() {
    String header = "";
    if (startType == StartType.LOGIN) {
      if (currentRoleType == RoleType.DOCTOR) {
        header = Strings.registerAsDoctorMessage;
      } else {
        header = Strings.registerAsPatientMessage;
      }
    } else {
      header = Strings.registerHeaderMessage;
    }
    return AutoText(
      header,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  _optionsWidget() {
    if (startType == StartType.LOGIN) {
      return Visibility(
        child: GestureDetector(
          child: Image.asset(
            currentRoleType == RoleType.DOCTOR
                ? Assets.waitForCodeDoctor
                : Assets.waitFroCodePatient,
            scale: 0.8,
          ),
        ),
      );
    } else {
      return Row(
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
    }
  }

  _messageWidget() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: AutoText(
          getMessageText(),
          style: TextStyle(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );

  _titleWidget() => Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: startType != StartType.LOGIN,
        child: AutoText(
          getTitleText(),
          style: TextStyle(
              color: IColors.themeColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      );

  _inputFieldsWidget() => Padding(
      padding: EdgeInsets.only(left: 40.0, right: 40.0),
      child: Container(child: _inputFieldsInnerWidget()));

  _isVerificationCodeValid(String validationCode) => validationCode.length == 6;

  bool isContinueEnable = false;

  _inputFieldsInnerWidget() {
    switch (startType) {
      case StartType.SIGN_UP:
        return InputField(
          inputHint: Strings.usernameInputHint,
          controller: _usernameController,
          textInputType: TextInputType.phone,
          validationCallback: (text) => validatePhoneNumber(text),
          errorMessage: "شماره همراه معتبر نیست",
        );
      case StartType.LOGIN:
        return InputField(
            inputHint: Strings.verificationHint,
            controller: _verificationController,
            textInputType: TextInputType.number,
            validationCallback: (text) =>
                _isVerificationCodeValid(text) || resendCodeEnabled,
            errorMessage: "کدفعالسازی ۶رقمی است",
            onChanged: (text) {
              setState(() {
                isContinueEnable = _isVerificationCodeValid(text);
              });
            });
      case StartType.REGISTER:
        return Column(
          children: <Widget>[
            InputField(
              inputHint: Strings.firstNameInputHint,
              controller: _firstNameController,
              validationCallback: (text) => text.isNotEmpty,
              errorMessage: 'نام خود را وارد کنید',
              needToHideKeyboard: false,
            ),
            ALittleVerticalSpace(),
            InputField(
              inputHint: Strings.lastNameInputHint,
              controller: _lastNameController,
              validationCallback: (text) => text.isNotEmpty,
              errorMessage: 'نام خانوادگی خود را وارد کنید',
              needToHideKeyboard: false,
            ),
            ALittleVerticalSpace(),
            InputField(
              inputHint: Strings.nationalCodeInputHint,
              controller: _nationalCodeController,
              validationCallback: (text) =>
                  (text.isNotEmpty && text.length == 10),
              errorMessage: 'کدملی معتبری را وارد کنید',
              needToHideKeyboard: false,
              textInputType: TextInputType.number,
            ),
            ALittleVerticalSpace(),
            currentRoleType == RoleType.DOCTOR
                ? InputField(
                    inputHint: Strings.expertiseInputHint,
                    controller: _expertiseCodeController,
                    validationCallback: (text) => text.isNotEmpty,
                    errorMessage: 'تخصص خود را وارد کنید',
                    needToHideKeyboard: false,
                    textInputType: TextInputType.text,
                  )
                : SizedBox()
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
