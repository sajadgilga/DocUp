import 'package:docup/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ActionButton.dart';
import 'AutoText.dart';
import 'VerticalSpace.dart';

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
