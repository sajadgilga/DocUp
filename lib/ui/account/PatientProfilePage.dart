import 'dart:async';
import 'dart:io';

import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/blocs/CreditBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/InputDoneView.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show PlatformException;

class PatientProfilePage extends StatefulWidget {
  final ValueChanged<String> onPush;
  final String defaultCreditForCharge;

  PatientProfilePage(
      {Key key, @required this.onPush, this.defaultCreditForCharge})
      : super(key: key);

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage>
    with WidgetsBindingObserver {
  CreditBloc _creditBloc = CreditBloc();

  AlertDialog _loadingDialog = getLoadingDialog();
  bool _loadingEnable;
  bool _isRequestForPay = false;
  BuildContext loadingContext;

  @override
  void initState() {
    initUniLinks();
    _loadingEnable = false;
    _creditBloc.listen((event) {
      if (!(event is AddCreditLoaded) && _isRequestForPay) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              loadingContext = context;
              return _loadingDialog;
            });
        _loadingEnable = true;
      } else {
        if (_loadingEnable) {
          Navigator.of(loadingContext).pop();
          _loadingEnable = false;
          launchURL("https://pay.ir/pg/${event.result.token}");
        }
      }
    });
    _amountTextController.text = widget.defaultCreditForCharge;
    if (Platform.isIOS) {
      KeyboardVisibilityNotification().addNewListener(onShow: () {
        showOverlay(context);
      }, onHide: () {
        removeOverlay();
      });
    }
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  OverlayEntry overlayEntry;

  showOverlay(BuildContext context) {
    if (overlayEntry != null) return;
    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: InputDoneView());
    });

    overlayState.insert(overlayEntry);
  }

  removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _amountTextController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        DocUpHeader(title: "پروفایل من"),
        SizedBox(height: 10),
        _userInfoLabelWidget(),
        _userInfoWidget(),
        _changePasswordWidget(context),
        _userCreditLabelWidget(),
        _userCreditWidget(),
        SizedBox(height: 20),
        _addCreditWidget(),
        SizedBox(height: 10),
        _supportWidget()
      ],
    ));
  }

  _supportWidget() => GestureDetector(
        onTap: () => launch("tel://09335705997"),
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                      fontFamily: 'iransans',
                      color: Colors.black87,
                      fontSize: 15),
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            "لطفا انتقادات و پیشنهادات خود را با شماره تماس ۰۹۳۳۵۷۰۵۹۹۷ در واتس اپ یا تلگرام با تیم"),
                    TextSpan(
                        text: " داکآپ ",
                        style: TextStyle(
                            color: IColors.themeColor,
                            fontWeight: FontWeight.bold)),
                    TextSpan(text: "در میان بگذارید ")
                  ]),
            )),
      );

  _userCreditWidget() =>
      BlocBuilder<EntityBloc, EntityState>(builder: (context, state) {
        return Center(
          child: Container(
            width: 200,
            height: 64,
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: IColors.darkBlue),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                " ${state is EntityLoaded && state.entity != null && state.entity.mEntity != null ? replaceFarsiNumber(normalizeCredit(state.entity.mEntity.user.credit)) : "0"} تومان ",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        );
      });

  TextEditingController _amountTextController = TextEditingController();

  _addCreditWidget() {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    return Visibility(
      visible: entity.isPatient,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.4,
            child: ActionButton(
                title: "افزایش اعتبار",
                icon: Icon(Icons.add),
                color: IColors.themeColor,
                callBack: () {
                  if (_amountTextController.text.isEmpty) {
                    toast(context, "لطفا مبلغ را وارد کنید");
                  } else {
                    _isRequestForPay = true;
                    _creditBloc.add(AddCredit(
                        mobile: entity.mEntity.user.phoneNumber,
                        amount: int.parse(_amountTextController.text)));
                  }
                }),
          ),
          Row(
            children: <Widget>[
              Text("ریال", style: TextStyle(fontSize: 18)),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextField(
                  controller: _amountTextController,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(20.0),
                        ),
                      ),
                      filled: true,
                      hintStyle:
                          new TextStyle(color: Colors.grey[800], fontSize: 12),
                      hintText: "مبلغ را وارد نمایید",
                      fillColor: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _userCreditLabelWidget() => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text("اعتبار من",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right),
      );

  _changePasswordWidget(BuildContext context) => Visibility(
        visible: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: <Widget>[
              ActionButton(
                color: Colors.grey,
                title: "تغییر رمز عبور",
                callBack: () => showNextVersionDialog(context),
              ),
            ],
          ),
        ),
      );

  _userInfoWidget() => BlocBuilder<EntityBloc, EntityState>(
        builder: (context, state) {
          if (state is EntityLoaded) {
            if (state.entity.mEntity != null) {
              var user = state.entity.mEntity.user;
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                          "${user.firstName == null ? "" : user.firstName} ${user.lastName == null ? "" : user.lastName}",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("${replaceFarsiNumber(user.phoneNumber)}",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(width: 20),
                  Avatar(user: user),
                ],
              );
            } else
              return Container();
          } else
            return Container();
        },
      );

  _userInfoLabelWidget() => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text("اطلاعات کاربری",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right),
      );

  StreamSubscription _sub;

  Future<Null> initUniLinks() async {
    try {
      _sub = getUriLinksStream().listen((Uri link) {
        final query = link.queryParameters;
        if (query["success"] == "false") {
          showOneButtonDialog(
              context, "پرداخت با خطا مواجه شد", "متوجه شدم", () {});
        } else {
          _amountTextController.text = query["credit"];
          showOneButtonDialog(context, "شارژ حساب کاربری با موفقیت انجام شد",
              "متوجه شدم", () {});
        }
      }, onError: (err) {
        print("link error $err");
      });
    } on PlatformException {
      print("link error");
    }
  }
}
