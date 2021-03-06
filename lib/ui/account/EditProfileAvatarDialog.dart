import 'dart:async';
import 'dart:convert';

import 'package:Neuronio/blocs/AuthBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/Avatar.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/CrossPlatformFilePicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProfileAvatarDialog {
  Entity entity;
  BuildContext dialogContext;
  BuildContext context;
  StateSetter accountStateSetter;
  StateSetter alertStateSetter;
  CustomFile customImageFile;
  bool emptyFlag = false;
  final Function() onDone;

  int actionButtonStatus = 0;

  ///0 for done,1 for loading, 2 for error

  EditProfileAvatarDialog(
      this.context, this.entity, this.onDone, this.accountStateSetter);

  void showEditableAvatarDialog() {
    StreamSubscription streamSubscription;
    AuthBloc authBloc = AuthBloc();
    streamSubscription = authBloc.uploadAvatarStream.listen((event) {
      handleResponse(event);
    });
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter dialogStateSetter) {
              alertStateSetter = dialogStateSetter;
              dialogContext = context;
              return Container(
                constraints: BoxConstraints.tightFor(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        constraints: BoxConstraints.tightFor(
                            width: MediaQuery.of(context).size.width * 0.8),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ALittleVerticalSpace(),
                            AutoText(
                              "ویرایش پروفایل",
                              color: IColors.black,
                              fontSize: 19,
                            ),
                            ALittleVerticalSpace(),
                            GestureDetector(
                                onTap: () {
                                  _getImage(dialogStateSetter);
                                },
                                child: emptyFlag
                                    ? PolygonAvatar(
                                        imageSize: 140,
                                      )
                                    : (customImageFile == null
                                        ? PolygonAvatar(
                                            user: entity.mEntity.user,
                                            imageSize: 140,
                                          )
                                        : PolygonAvatar(
                                            imageSize: 140,
                                            defaultImage: Image.memory(
                                                customImageFile.fileBits,
                                                fit: BoxFit.cover),
                                          ))),
                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 20),
                              child: GestureDetector(
                                onTap: () {
                                  alertStateSetter(() {
                                    emptyFlag = true;
                                    customImageFile = null;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 1, color: IColors.darkGrey)),
                                  child: Icon(
                                    Icons.delete,
                                    color: IColors.themeColor,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            ActionButton(
                              title: "ذخیره",
                              color: actionButtonStatus == 2
                                  ? IColors.red
                                  : IColors.themeColor,
                              loading: actionButtonStatus == 1,
                              height: 45,
                              borderRadius: 10,
                              callBack: () {
                                updateAvatarImage(authBloc);
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        }).then((value) {
      streamSubscription.cancel();
    });
  }

  void showError() {
    alertStateSetter(() {
      actionButtonStatus = 2;
    });
    Future.delayed(Duration(seconds: 1), () {
      alertStateSetter(() {
        actionButtonStatus = 0;
      });
    });
  }

  void handleResponse(response) {
    try {
      switch (response.status) {
        case Status.LOADING:
          alertStateSetter(() {
            actionButtonStatus = 1;
          });
          break;
        case Status.ERROR:
          showError();
          break;
        case Status.COMPLETED:
          alertStateSetter(() {
            actionButtonStatus = 0;
          });
          accountStateSetter(() {
            entity.mEntity.user.avatar = response.data.avatar;
          });
          Navigator.maybePop(dialogContext);
          try {
            onDone();
          } catch (e) {}
          break;
        default:
          break;
      }
    } catch (e) {}
  }

  void updateAvatarImage(AuthBloc authBloc) async {
    if (customImageFile == null) {
      authBloc.deleteAvatar(entity.mEntity.id);
    } else {
      authBloc.uploadAvatar(
          base64Encode(customImageFile.fileBits), entity.mEntity.id);
    }
  }

  Future _getImage(StateSetter stateSetter) async {
    var croppedFile =
        await CrossPlatformFilePicker.pickCustomImageFile(imageCropper: true);
    print(croppedFile);
    if (croppedFile != null) {
      stateSetter(() {
        emptyFlag = false;
        customImageFile = croppedFile;
      });
    }
  }
}
