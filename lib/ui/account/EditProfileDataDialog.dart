import 'dart:async';

import 'package:docup/blocs/DoctorBloc.dart';
import 'package:docup/blocs/PatientBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProfileDataDialog {
  Entity entity;
  BuildContext dialogContext;
  BuildContext context;
  StateSetter alertStateSetter;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nationalCodeController = TextEditingController();
  final TextEditingController _expertiseCodeController =
      TextEditingController();

  final Function() onDone;

  int actionButtonStatus = 0;

  ///0 for done,1 for loading, 2 for error

  EditProfileDataDialog(this.context, this.entity, this.onDone) {
    _firstNameController.text = entity.mEntity.user.firstName ?? "";
    _lastNameController.text = entity.mEntity.user.lastName ?? "";
    _nationalCodeController.text =
        replacePersianWithEnglishNumber(entity.mEntity.user.nationalId ?? "");
    if (entity.isDoctor) {
      _expertiseCodeController.text = (entity.mEntity as DoctorEntity).expert;
    }
  }

  void showEditableDataDialog() {
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
                              "ویرایش اطلاعات",
                              color: IColors.black,
                              fontSize: 19,
                            ),
                            ALittleVerticalSpace(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _firstNameController,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                decoration: InputDecoration(hintText: "نام"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _lastNameController,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                decoration:
                                    InputDecoration(hintText: "نام خانوادگی"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _nationalCodeController,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                decoration: InputDecoration(hintText: "کد ملی"),
                              ),
                            ),
                            entity.isDoctor
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      controller: _expertiseCodeController,
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.text,
                                      maxLines: 1,
                                      decoration:
                                          InputDecoration(hintText: "تخصص"),
                                    ),
                                  )
                                : SizedBox(),
                            ActionButton(
                              title: "ویرایش",
                              color: actionButtonStatus == 2
                                  ? IColors.red
                                  : IColors.themeColor,
                              loading: actionButtonStatus == 1,
                              height: 45,
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
          entity.mEntity.user.firstName = _firstNameController.text;
          entity.mEntity.user.lastName = _lastNameController.text;
          entity.mEntity.user.nationalId = _nationalCodeController.text;
          if (entity.isDoctor) {
            (entity.mEntity as DoctorEntity).expert =
                _expertiseCodeController.text;
          }
          try {
            onDone();
          } catch (e) {}
          break;
        default:
          break;
      }
    } catch (e) {}
  }

  void editData(dataBloc) {
    if (_nationalCodeController.text == null ||
        _nationalCodeController.text == "" ||
        _nationalCodeController.text.length != 10) {
      showError();
    } else {
      if (entity.isPatient) {
        (dataBloc as PatientBloc).updateProfile(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            nationalCode: _nationalCodeController.text);
      } else if (entity.isDoctor) {
        if (_expertiseCodeController.text == null ||
            _expertiseCodeController.text == "") {
          showError();
        } else {
          (dataBloc as DoctorBloc).updateProfile(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              nationalCode: _nationalCodeController.text,
              expertise: _expertiseCodeController.text);
        }
      }
    }
  }
}
