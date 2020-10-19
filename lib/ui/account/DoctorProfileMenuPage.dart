import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/DoctorCreditWidget.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/blocs/CreditBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/MapWidget.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show PlatformException;

class DoctorProfileMenuPage extends StatefulWidget {
  final Function(String, dynamic) onPush;
  final DoctorEntity doctorEntity;

  DoctorProfileMenuPage({Key key, @required this.onPush, this.doctorEntity})
      : super(key: key);

  @override
  _DoctorProfileMenuPageState createState() => _DoctorProfileMenuPageState();
}

class _DoctorProfileMenuPageState extends State<DoctorProfileMenuPage> {
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
                /// TODO
                widget.onPush(NavigatorRoutes.root, null);
              },
              topRightFlag: false,
              topLeftFlag: Platform.isIOS,
            ),
            DocUpHeader(
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AutoText("درباره ما",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
        ALittleVerticalSpace(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AutoText("قوانین و شرایط",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
        ALittleVerticalSpace(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AutoText("ارتباط با ما",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ),
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

  Widget _userCreditCards() {
    List<Widget> creditCards = [];
    widget.doctorEntity.accountNumbers.forEach((element) {
      creditCards.add(_creditCard(element));
    });
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.doctorEntity.accountNumbers.length == 0
                  ? SizedBox()
                  : _addCreditCardPlusIcon(horizontalPadding: 15),
              AutoText(
                "کارت های من (${widget.doctorEntity.accountNumbers.length})",
                softWrap: true,
                textAlign: TextAlign.end,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        MediumVerticalSpace(),
        widget.doctorEntity.accountNumbers.length == 0
            ? _creditCard("", isEmpty: true)
            : Column(
                children: creditCards,
              )
      ],
    );
  }

  Widget _creditCard(String accountNumber, {bool isEmpty = false}) {
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
                  child: AutoText(isEmpty
                      ? "اضافه کردن کارت بانکی"
                      : getCreditCardFourParts(
                          replaceEnglishWithPersianNumber(accountNumber))),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: AutoText("  ...  "),
                )
              ],
            ),
            isEmpty
                ? SizedBox()
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                      Icons.home,
                      size: 60,
                    )),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              isEmpty
                  ? _addCreditCardPlusIcon(buttonSize: 50)
                  : ActionButton(
                      title: "حذف",
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 15,
                      ),
                      color: IColors.red,
                      fontSize: 12,
                      width: 80,
                      height: 40,
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

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            content: Container(
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
                        _creditCardSinglePartTextField(controller),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AutoText("متعلق به ",
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
                                "بانک ",
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
                              title: "اضافه کردن",
                              color: IColors.red,
                              fontSize: 12,
                              width: 110,
                              height: 40,
                              callBack: () {},
                              textColor: Colors.white,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _creditCardSinglePartTextField(TextEditingController controller) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: BoxConstraints.tightFor(),
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: TextField(
          expands: false,
          controller: controller,
          textInputAction: TextInputAction.done,
          keyboardType:
              TextInputType.numberWithOptions(signed: false, decimal: false),
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '----  ----  ----  ----',
          ),
        ));
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("isPatient");
    exit(0);
  }
}
