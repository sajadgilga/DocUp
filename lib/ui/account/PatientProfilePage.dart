import 'dart:async';
import 'dart:io';

import 'package:docup/blocs/CreditBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/account/EditProfileDataDialog.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/ContactUsAndPolicy.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/ui/widgets/InputDoneView.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'EditProfileAvatarDialog.dart';

class PatientProfilePage extends StatefulWidget {
  final Function(String, dynamic) onPush;
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
  bool _creditDescriptionTooltipToggle = false;
  bool _creditErrorTooltipToggle = false;

  AlertDialog _loadingDialog = getLoadingDialog();
  bool _loadingEnable;
  bool _isRequestForPay = false;
  BuildContext loadingContext;

  @override
  void initState() {
    checkPatientBillingDescription();
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

  //
  Future<void> checkPatientBillingDescription(
      {bool changeTooltip = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShown = false;
    if (prefs.containsKey("patientBillingDescription")) {
      hasShown = prefs.getBool("patientBillingDescription");
    }
    prefs.setBool("patientBillingDescription", true);
    if (changeTooltip) {
      _creditDescriptionTooltipToggle = !hasShown;
    }
  }

  @override
  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
      _sub.cancel();
    } catch (e) {}
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _amountTextController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EntityBloc, EntityState>(builder: (context, state) {
        if ((state is EntityLoaded || state.entity.mEntity != null) &&
            !(state is EntityError)) {
          return _widget(state);
        } else if (state is EntityError) {
          return APICallError(() {
            EntityBloc entityBloc = BlocProvider.of<EntityBloc>(context);
            entityBloc.add(EntityGet());
          });
        } else {
          return Waiting();
        }
      });

  _widget(EntityState state) {
    PatientEntity patientEntity = state.entity.mEntity as PatientEntity;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: [
              PageTopLeftIcon(
                topLeft: Icon(
                  Icons.menu,
                  size: 25,
                ),
                onTap: () {
                  /// TODO
                  widget.onPush(
                      NavigatorRoutes.patientProfileMenuPage, patientEntity);
                },
                topRightFlag: false,
                topLeftFlag: true,
              ),
              DocUpHeader(
                title: "پروفایل من",
                docUpLogo: false,
              ),
            ],
          ),
          SizedBox(height: 10),
          _userInfoLabelWidget(),
          _userInfoWidget(state.entity),
          _changePasswordWidget(context),
          SizedBox(height: 10),
          _userCreditLabelWidget(),
          GestureDetector(
            onTap: () {
              checkPatientBillingDescription(changeTooltip: false);

              setState(() {
                _creditDescriptionTooltipToggle = true;
              });

              /// TODO
              Timer(Duration(seconds: 10), () {
                _creditDescriptionTooltipToggle = false;
              });
            },
            child: SimpleTooltip(
                hideOnTooltipTap: true,
                show: _creditDescriptionTooltipToggle,
                animationDuration: Duration(milliseconds: 460),
                tooltipDirection: TooltipDirection.down,
                backgroundColor: IColors.whiteTransparent,
                borderColor: IColors.themeColor,
                tooltipTap: () {
                  checkPatientBillingDescription();
                },
                content: AutoText(
                  Strings.patientBillingDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
                child: _userCreditWidget()),
          ),
          SizedBox(height: 30),
          _addCreditWidget(),
          SizedBox(height: 10),
          // suggestionsAndCriticism()
        ],
      ),
    );
  }

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AutoText(
                    " ${state is EntityLoaded && state.entity != null && state.entity.mEntity != null ? replaceFarsiNumber(normalizeCredit(state.entity.mEntity.user.credit)) : "0"}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textDirection: TextDirection.rtl,
                  ),
                  AutoText(
                    "تومان",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textDirection: TextDirection.rtl,
                  ),
                ],
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
                rtl: true,
                color: IColors.themeColor,
                callBack: () {
                  String amountText = _amountTextController.text;
                  if (amountText.isEmpty || amountText == null) {
                    toast(context, "لطفا مبلغ را وارد کنید");
                  } else if (!isNumeric(amountText)) {
                    toast(context, "لطفا مبلغ عددی را وارد کنید");
                  } else {
                    int amountToman = int.parse(amountText);
                    if (amountToman < 2000) {
                      setState(() {
                        _creditErrorTooltipToggle = true;
                      });
                    } else {
                      _isRequestForPay = true;
                      _creditBloc.add(AddCredit(
                          mobile: entity.mEntity.user.phoneNumber,
                          amount: amountToman * 10));
                    }
                  }
                }),
          ),
          Row(
            children: <Widget>[
              AutoText("تومان", style: TextStyle(fontSize: 18)),
              SizedBox(
                width: 10,
              ),
              SimpleTooltip(
                hideOnTooltipTap: true,
                show: _creditErrorTooltipToggle,
                animationDuration: Duration(milliseconds: 460),
                tooltipDirection: TooltipDirection.down,
                backgroundColor: IColors.whiteTransparent,
                borderColor: IColors.themeColor,
                tooltipTap: () {
                  setState(() {
                    _creditErrorTooltipToggle = !_creditErrorTooltipToggle;
                  });
                },
                content: AutoText(
                  Strings.minimumRequestedCredit,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextField(
                    controller: _amountTextController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: false, decimal: false),
                    decoration: new InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(20.0),
                          ),
                        ),
                        filled: true,
                        hintStyle: new TextStyle(
                            color: Colors.grey[800], fontSize: 12),
                        hintText: "مبلغ را وارد نمایید",
                        fillColor: Colors.white70),
                  ),
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
        child: AutoText("اعتبار من",
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

  _userInfoWidget(Entity entity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            AutoText(
              "${entity.mEntity?.user?.firstName == null ? "" : entity.mEntity.user.firstName} ${entity.mEntity?.user?.lastName == null ? "" : entity.mEntity.user.lastName}",
              fontSize: 16,
            ),
            SizedBox(height: 10),
            ActionButton(
              title: "اطلاعات",
              color: IColors.themeColor,
              callBack: () {
                EditProfileDataDialog editProfileData =
                    EditProfileDataDialog(context, entity, () {
                  EntityBloc entityBloc = BlocProvider.of<EntityBloc>(context);
                  entityBloc.add(EntityGet());
                });
                editProfileData.showEditableDataDialog();
              },
            )
          ],
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            EditProfileAvatarDialog dialog =
                EditProfileAvatarDialog(context, entity, () {}, setState);
            dialog.showEditableAvatarDialog();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: EditingCircularAvatar(
              user: entity.mEntity?.user,
            ),
          ),
        ),
      ],
    );
  }

  _userInfoLabelWidget() => Padding(
        padding: const EdgeInsets.all(12.0),
        child: AutoText("اطلاعات کاربری",
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
          var _state = BlocProvider.of<EntityBloc>(context).state.entity;
          setState(() {
            _state.mEntity.user.credit = query["credit"];
            _amountTextController.text = query["credit"];
          });

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
