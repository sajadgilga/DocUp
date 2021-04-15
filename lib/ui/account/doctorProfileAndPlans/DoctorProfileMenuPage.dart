import 'dart:async';
import 'dart:math';

import 'package:Neuronio/blocs/DoctorBloc.dart';
import 'package:Neuronio/blocs/UtilBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/BankData.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/ContactUsAndPolicy.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/WebsocketHelper.dart';
import 'package:Neuronio/utils/entityUpdater.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorProfileMenuPage extends StatefulWidget {
  final Function(String, dynamic) onPush;
  final DoctorEntity doctorEntity;

  DoctorProfileMenuPage({Key key, @required this.onPush, this.doctorEntity})
      : super(key: key);

  @override
  _DoctorProfileMenuPageState createState() => _DoctorProfileMenuPageState();
}

class _DoctorProfileMenuPageState extends State<DoctorProfileMenuPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _appVersionController = TextEditingController();

  @override
  void initState() {
    _phoneNumberController.text = widget.doctorEntity.user.phoneNumber;
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        _appVersionController.text = value.version;
      });
    });
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
                widget.onPush(NavigatorRoutes.root, null);
              },
              topRightFlag: false,
              topLeftFlag: CrossPlatformDeviceDetection.isIOS,
            ),
            NeuronioHeader(
              title: "پروفایل من",
              docUpLogo: false,
            ),
          ],
        ),
        ALittleVerticalSpace(
          height: 20,
        ),
        _userCreditCards(),
        ALittleVerticalSpace(),
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
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: AutoText(
              "اطلاعات",
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
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: TextField(
                        style: TextStyle(fontSize: 18, color: IColors.darkGrey),
                        textAlign: TextAlign.left,
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
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: TextField(
                        style: TextStyle(fontSize: 18, color: IColors.darkGrey),
                        textAlign: TextAlign.left,
                        controller: _appVersionController,
                        enabled: false,
                        decoration: InputDecoration(border: InputBorder.none),
                      ),
                    ),
                  ),
                  AutoText(
                    "ورژن کنونی اپلیکیشن",
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

  Widget _userCreditCards() {
    List<Widget> creditCards = [];
    (widget.doctorEntity?.accountNumbers ?? []).forEach((element) {
      creditCards.add(CreditCard(
        doctorEntity: widget.doctorEntity,
      ));
    });
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              AutoText(
                "کارت بانکی من",
                softWrap: true,
                textAlign: TextAlign.end,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        MediumVerticalSpace(),
        CreditCard(
          doctorEntity: widget.doctorEntity,
        )
      ],
    );
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Phoenix.rebirth(context);
    EntityAndPanelUpdater.end();
    SocketHelper().dispose();
  }
}

class CreditCard extends StatefulWidget {
  // final Function(String, dynamic) onPush;
  final DoctorEntity doctorEntity;

  CreditCard(
      {Key key,
      // @required this.onPush,
      this.doctorEntity})
      : super(key: key);

  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  DoctorBloc _doctorBloc = DoctorBloc();
  UtilBloc _utilBloc = UtilBloc();
  int addOrUpdatingCardStatus = 0;
  StateSetter dialogStateSetter;
  BuildContext dialogContext;
  String logoLink;
  int linkStatus = 0;

  ///0 for loading 1 for complated -1 for error
  bool _isEmpty() {
    if (widget.doctorEntity.accountNumbers == null ||
        widget.doctorEntity.accountNumbers.length == 0 ||
        widget.doctorEntity.accountNumbers[0] == null) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    _doctorBloc.doctorStream.listen((response) {
      switch (response.status) {
        case Status.LOADING:
          setLoading();
          return;
        case Status.COMPLETED:
          setComplete(response);
          return;
        case Status.ERROR:
          setError();
          return;
        default:
          return;
      }
    });

    _utilBloc.bankStream.listen((response) {
      switch (response.status) {
        case Status.LOADING:
          setState(() {
            linkStatus = 0;
            logoLink = null;
          });
          return;
        case Status.COMPLETED:
          setState(() {
            linkStatus = 1;

            logoLink = (response.data as BankData).logo;
          });
          return;
        case Status.ERROR:
          setState(() {
            linkStatus = -1;

            logoLink = null;
          });
          return;
        default:
          return;
      }
    });
    fetchBankData();

    super.initState();
  }

  void setLoading() {
    try {
      dialogStateSetter(() {
        addOrUpdatingCardStatus = 1;
      });
    } catch (e) {}
    setState(() {
      addOrUpdatingCardStatus = 1;
    });
  }

  void setComplete(response) {
    widget.doctorEntity.accountNumbers =
        (response.data as DoctorEntity).accountNumbers;
    try {
      dialogStateSetter(() {
        addOrUpdatingCardStatus = 0;
      });
    } catch (e) {}
    setState(() {
      addOrUpdatingCardStatus = 0;
    });
    try {
      Navigator.of(this.dialogContext).pop('dialog');
    } catch (e) {}
    fetchBankData();
  }

  void setError() {
    try {
      dialogStateSetter(() {
        addOrUpdatingCardStatus = 3;
      });
    } catch (e) {}
    setState(() {
      addOrUpdatingCardStatus = 3;
    });
    Timer(Duration(seconds: 3), () {
      try {
        dialogStateSetter(() {
          addOrUpdatingCardStatus = 0;
        });
      } catch (e) {}
      setState(() {
        addOrUpdatingCardStatus = 0;
      });
    });
  }

  /// 0 as undefined 1 as waiting 2 as completed, 3 as error
  @override
  Widget build(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width * 0.2;
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8, minWidth: 300),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: Column(
        children: <Widget>[
          ALittleVerticalSpace(),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: AutoText(
                    _isEmpty()
                        ? "اضافه کردن کارت بانکی"
                        : getCreditCardFourParts(
                            replaceEnglishWithPersianNumber(
                                (widget.doctorEntity.accountNumbers ??
                                        [""])[0] ??
                                    ""),
                          ),
                    textDirection:
                        _isEmpty() ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: AutoText("  ...  "),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: _isEmpty()
                  ? SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: Icon(
                        Icons.credit_card,
                        size: imageSize / 2,
                        color: IColors.darkGrey,
                      ),
                    )
                  : logoLink == null
                      ? SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: DocUpAPICallLoading2(
                            textFlag: false,
                            width: 60,
                          ),
                        )
                      : SizedBox(
                          child: Image.network(
                            logoLink,
                            width: imageSize,
                            height: imageSize,
                          ),
                        ),
            )
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _isEmpty()
                  ? _addCreditCardPlusIcon(buttonSize: 50)
                  : ActionButton(
                      title: addOrUpdatingCardStatus == 3 ? "خطا" : "حذف",
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 15,
                      ),
                      color: IColors.red,
                      fontSize: 12,
                      loading: addOrUpdatingCardStatus == 1,
                      height: 45,
                      callBack: () {
                        addOrDeleteCardNumber(null, setState, deleteFlag: true);
                      },
                      textColor: Colors.white,
                    )
            ],
          ),
        ],
      ),
    );
  }

  Widget _addCreditCardPlusIcon(
      {double buttonSize = 40,
      double verticalPadding = 5,
      double horizontalPadding = 10}) {
    return GestureDetector(
      onTap: () => showAddCardDialog(),
      child: Container(
          width: buttonSize,
          height: buttonSize,
          margin: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(
            color: IColors.themeColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(
              Radius.circular(15.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(buttonSize * (0.3 / 2)),
            child: Icon(Icons.add, size: buttonSize * 0.7, color: Colors.white),
          )),
    );
  }

  void showAddCardDialog() {
    MaskedTextController controller =
        MaskedTextController(mask: '0000  0000  0000  0000');
    String bankName = "بانک -";

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter dialogStateSetter) {
              this.dialogStateSetter = dialogStateSetter;
              this.dialogContext = context;
              return Container(
                constraints: BoxConstraints.tightFor(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints.tightFor(
                          width: MediaQuery.of(context).size.width * 0.8),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ALittleVerticalSpace(),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              constraints: BoxConstraints.tightFor(),
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: TextField(
                                expands: false,
                                controller: controller,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.numberWithOptions(
                                    signed: false, decimal: false),
                                textAlign: TextAlign.left,
                                onChanged: (value) {
                                  String sixDigits = value.replaceAll(" ", "");
                                  if (sixDigits.length == 6) {
                                    dialogStateSetter(() {
                                      bankName =
                                          InAppStrings.bankCodes[sixDigits] ??
                                              'بانک -';
                                    });
                                  }
                                },
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '----  ----  ----  ----',
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AutoText("متعلق به -",
                                    color: IColors.darkGrey, fontSize: 14)
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AutoText(
                                  bankName,
                                  color: IColors.darkGrey,
                                  fontSize: 14,
                                )
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              ActionButton(
                                title: addOrUpdatingCardStatus == 3
                                    ? "خطا"
                                    : "تایید",
                                color:
                                    [0, 1, 2].contains(addOrUpdatingCardStatus)
                                        ? IColors.themeColor
                                        : IColors.red,
                                fontSize: 12,
                                width: 110,
                                height: 40,
                                loading: addOrUpdatingCardStatus == 1,
                                callBack: () {
                                  addOrDeleteCardNumber(
                                      controller.text, dialogStateSetter);
                                },
                                textColor: Colors.white,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  void addOrDeleteCardNumber(String cardNumber, StateSetter dialogStateSetter,
      {bool deleteFlag = false}) {
    bool isNumeric(String s) {
      if (s == null) {
        return false;
      }
      return double.parse(s, (e) => null) != null;
    }

    bool addingCard = (!deleteFlag &&
        cardNumber.replaceAll(" ", "").length == 16 &&
        isNumeric(cardNumber.replaceAll(" ", "")));
    bool deletingCard = (deleteFlag && cardNumber == null);

    if (addingCard || deletingCard) {
      _doctorBloc.addOrUpdateAccountNumber(
          cardNumber == null ? cardNumber : cardNumber.replaceAll("  ", ""));
    } else {
      setError();
    }
  }

  void fetchBankData() {
    if (!_isEmpty()) {
      String cardNumber =
          widget.doctorEntity.accountNumbers[0].replaceAll("  ", "");
      cardNumber = cardNumber.substring(0, min(6, cardNumber.length));
      _utilBloc.getBankData(cardNumber);
    }
  }

  @override
  void dispose() {
    try {
      _doctorBloc.dispose();
    } catch (e) {}
    super.dispose();
  }
}
