import 'dart:async';
import 'dart:convert';

import 'package:docup/blocs/DoctorBloc.dart';
import 'package:docup/blocs/PatientBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/Picture.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileAvatarDialog {
  Entity entity;
  BuildContext dialogContext;
  BuildContext context;
  StateSetter alertStateSetter;
  PictureEntity picture =
      PictureEntity(picture: null, title: '', description: '');

  final Function() onDone;

  int actionButtonStatus = 0;

  ///0 for done,1 for loading, 2 for error

  EditProfileAvatarDialog(this.context, this.entity, this.onDone) {}

  void showEditableAvatarDialog() {
    StreamSubscription streamSubscription;
    var dataBloc;
    if (entity.isPatient) {
      dataBloc = PatientBloc();
      streamSubscription = dataBloc.dataStream.listen((event) {
        handleResponse(event);
      });
    } else if (entity.isDoctor) {
      dataBloc = DoctorBloc();
      streamSubscription = dataBloc.doctorStream.listen((event) {
        handleResponse(event);
      });
    }
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
                                child: EditingCircularAvatar(
                                  user: entity.mEntity.user,
                                  radius: 140,
                                )),
                            ALittleVerticalSpace(
                              height: 100,
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
                                editData(dataBloc);
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

  void editData(dataBloc) {}

  Future _getImage(StateSetter stateSetter) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var newPicture = PictureEntity(
        picture: Image.file(
          image,
          fit: BoxFit.cover,
        ),
        description: '',
        title: picture.description,
        base64: base64Encode(image.readAsBytesSync()),
        imagePath: image.path);
    stateSetter(() {
      picture = newPicture;
    });
  }
}
