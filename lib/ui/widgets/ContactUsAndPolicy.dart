import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ActionButton.dart';
import 'AutoText.dart';
import 'VerticalSpace.dart';

suggestionsAndCriticism() {
  double iconsSize = 60;
  double telegramIconScale = (210 / 156);
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () =>
              launch("http://telegram.me/" + Strings.supportTelegramId),
          child: Container(
              padding: EdgeInsets.all(5),
              width: iconsSize * telegramIconScale,
              child: Image.asset(
                Assets.accountTelegramIcon,
                width: iconsSize * telegramIconScale,
              )),
        ),
        GestureDetector(
          onTap: () => launch(
              "whatsapp://send?phone=" + Strings.supportWhatsAppPhoneNumber),
          child: Container(
              padding: EdgeInsets.all(5),
              width: iconsSize,
              child: Image.asset(
                Assets.accountWhatsAppIcon,
                width: iconsSize,
              )),
        ),
        AutoText(
          "انتقادات و پیشنهادات",
          style: TextStyle(fontSize: 17),
        ),
      ],
    ),
  );
}

Widget aboutUsButton(BuildContext context) {
  return ActionButton(
    title: "درباره ما",
    color: IColors.themeColor,
    fontWeight: FontWeight.bold,
    callBack: () {
      launchURL("https://docup.ir");
    },
  );
  // return GestureDetector(
  //   onTap: () {
  //     showOneButtonDialog(context, Strings.privacyAndPolicy, "باشه", () {});
  //   },
  //   child: Container(
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         border: Border.all(),
  //         borderRadius: BorderRadius.all(Radius.circular(15))),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         children: <Widget>[
  //           AutoText("درباره ما",
  //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
  //         ],
  //       ),
  //     ),
  //   ),
  // );
}

Widget paymentDescription(BuildContext context) {
  return ActionButton(
    title: "روش های پرداخت",
    color: IColors.themeColor,
    fontWeight: FontWeight.bold,
    callBack: () {
      var _state = BlocProvider.of<EntityBloc>(context).state;
      if (_state.entity?.isDoctor == true) {
        showDescriptionAlertDialog(context,
            title: Strings.paymentDescriptionTitle,
            description: Strings.paymentDescriptionDoctor,
            buttonTitle: "باشه",
            action: () {});
      } else {
        showDescriptionAlertDialog(context,
            title: Strings.paymentDescriptionTitle,
            description: Strings.paymentDescriptionPatient,
            buttonTitle: "باشه",
            action: () {});
      }
    },
  );
}

Widget policyAndConditions(BuildContext context) {
  return ActionButton(
    title: "قوانین و شرایط",
    color: IColors.themeColor,
    fontWeight: FontWeight.bold,
    callBack: () {
      showDescriptionAlertDialog(context,
          title: Strings.privacyAndPolicy,
          description: Strings.policyDescription,
          buttonTitle: "باشه",
          action: () {});
    },
  );
  // return GestureDetector(
  //   onTap: () {
  //     showOneButtonDialog(context, Strings.privacyAndPolicy, "باشه", () {});
  //   },
  //   child: Container(
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         border: Border.all(),
  //         borderRadius: BorderRadius.all(Radius.circular(15))),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: <Widget>[
  //           AutoText(,
  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
  //       ],
  //     ),
  //   ),
  // ),);
}

Widget contactUsButton() {
  return suggestionsAndCriticism();
}

void showDescriptionAlertDialog(BuildContext context,
    {String title = "",
    String description = "",
    String buttonTitle = "تایید",
    Function action}) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(0, 0, 0, 0),
          content: Container(
            constraints: BoxConstraints.tightFor(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 2 / 3),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AutoText(
                    title,
                    color: IColors.black,
                    fontSize: 18,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(
                          color: IColors.background,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: SingleChildScrollView(
                        child: AutoText(
                          description,
                          color: IColors.darkGrey,
                          fontSize: 16,
                          // maxLines: 20,
                        ),
                      ),
                    ),
                  ),
                  ALittleVerticalSpace(),
                  ActionButton(
                    title: buttonTitle,
                    color: IColors.green,
                    callBack: () {
                      try {
                        action();
                      } catch (e) {}
                      Navigator.maybePop(context);
                    },
                  )
                ],
              ),
            ),
          ),
        );
      });
}
