import 'dart:async';

import 'package:Neuronio/blocs/DoctorBloc.dart';
import 'package:Neuronio/blocs/PatientBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoCompleteTextField.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/DateTimeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class EditProfileDataDialog {
  Entity entity;
  BuildContext dialogContext;
  BuildContext context;
  StateSetter alertStateSetter;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nationalCodeController = TextEditingController();
  final TextEditingController _expertiseCodeController =
      TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _genderController = TextEditingController();

  /// city controller
  final TextEditingController _birthCity = TextEditingController();
  final TextEditingController _currentCity = TextEditingController();

  final TextEditingController _jalaliBirthDate = TextEditingController();

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
    } else if (entity.isPatient) {
      _weightController.text =
          ((entity.mEntity as PatientEntity).weight ?? 0).toString();
      _heightController.text =
          ((entity.mEntity as PatientEntity).height ?? 0).toString();
      _genderController.text = (entity.patient.genderNumber ?? 0).toString();
      _currentCity.text = entity.patient.city;
      _birthCity.text = entity.patient.birthLocation;
      _jalaliBirthDate.text =
          DateTimeService.getJalaliStringFormGeorgianDateTimeString(
              entity.patient.birthDate);
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
                child: SingleChildScrollView(
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
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Form(
                              key: _formKey,
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
                                    child: Container(
                                      height: 70,
                                      child: TextField(
                                        controller: _firstNameController,
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 16),
                                        decoration: InputDecoration(
                                          labelText: "نام",
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: new BorderSide(
                                                  color: IColors.darkGrey,
                                                  width: 1)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 70,
                                      child: TextField(
                                        controller: _lastNameController,
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 16),
                                        decoration: InputDecoration(
                                          labelText: "نام خانوادگی",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: new BorderSide(
                                                  color: IColors.darkGrey,
                                                  width: 1)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 50,
                                      child: TextField(
                                        controller: _nationalCodeController,
                                        textDirection: TextDirection.ltr,
                                        textAlign: TextAlign.center,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                signed: false, decimal: false),
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 16),
                                        decoration: InputDecoration(
                                          labelText: "کد ملی",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: new BorderSide(
                                                  color: IColors.darkGrey,
                                                  width: 1)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  entity.isDoctor
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 70,
                                            child: TextField(
                                              controller:
                                                  _expertiseCodeController,
                                              textDirection: TextDirection.ltr,
                                              textAlign: TextAlign.center,
                                              keyboardType: TextInputType.text,
                                              maxLines: 2,
                                              style: TextStyle(fontSize: 16),
                                              decoration: InputDecoration(
                                                labelText: "تخصص",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    borderSide: new BorderSide(
                                                        color: IColors.darkGrey,
                                                        width: 1)),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                  entity.isPatient
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 50,
                                            child: TextField(
                                              controller: _weightController,
                                              textDirection: TextDirection.ltr,
                                              textAlign: TextAlign.center,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: false,
                                                      decimal: true),
                                              maxLines: 1,
                                              style: TextStyle(fontSize: 16),
                                              decoration: InputDecoration(
                                                labelText: "وزن به کیلوگرم",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    borderSide: new BorderSide(
                                                        color: IColors.darkGrey,
                                                        width: 1)),
                                              ),
                                            ),
                                          ))
                                      : SizedBox(),
                                  entity.isPatient
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 50,
                                            child: TextField(
                                              controller: _heightController,
                                              textDirection: TextDirection.ltr,
                                              textAlign: TextAlign.center,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: false,
                                                      decimal: true),
                                              maxLines: 1,
                                              style: TextStyle(fontSize: 16),
                                              decoration: InputDecoration(
                                                labelText: "قد به متر",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    borderSide: new BorderSide(
                                                        color: IColors.darkGrey,
                                                        width: 1)),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                  entity.isPatient
                                      ? Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 50,
                                                child: TextFormField(
                                                  controller: _jalaliBirthDate,
                                                  onTap: () {
                                                    showDatePickerDialog(
                                                        context,
                                                        [],
                                                        _jalaliBirthDate,
                                                        restrictMinDate: false);
                                                  },
                                                  validator: (value) {
                                                    if (value.isEmpty)
                                                      return null;
                                                    var jalali = DateTimeService
                                                        .getJalalyDateFromJalilyString(
                                                            value);
                                                    if (jalali == null) {
                                                      return "تاریخ نامعتبر";
                                                    } else {
                                                      return null;
                                                    }
                                                  },
                                                  textDirection:
                                                      TextDirection.ltr,
                                                  textAlign: TextAlign.center,
                                                  keyboardType:
                                                      TextInputType.datetime,
                                                  maxLines: 1,
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                  decoration: InputDecoration(
                                                    labelText: "تاریخ تولد",
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        borderSide:
                                                            new BorderSide(
                                                                color: IColors
                                                                    .darkGrey,
                                                                width: 1)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 50,
                                                child: AutoCompleteTextField(
                                                  hintText: 'شهر تولد',
                                                  controller: _birthCity,
                                                  emptyFieldError:
                                                      'لظفا شهری را وارد کنید',
                                                  notFoundError:
                                                      "شهر موردنظر یافت نشد",
                                                  items: InAppStrings
                                                      .cities.keys
                                                      .toList(),
                                                  forced: false,
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      borderSide:
                                                          new BorderSide(
                                                              color: IColors
                                                                  .darkGrey,
                                                              width: 1)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 50,
                                                child: AutoCompleteTextField(
                                                  emptyFieldError:
                                                      'لظفا شهری را وارد کنید',
                                                  notFoundError:
                                                      "شهر موردنظر یافت نشد",
                                                  items: InAppStrings
                                                      .cities.keys
                                                      .toList(),
                                                  forced: false,
                                                  hintText: 'شهر زندگی',
                                                  controller: _currentCity,
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      borderSide:
                                                          new BorderSide(
                                                              color: IColors
                                                                  .darkGrey,
                                                              width: 1)),
                                                ),
                                              ),
                                            ),
                                            ToggleSwitch(
                                              minWidth: 90.0,
                                              initialLabelIndex: intPossible(
                                                      _genderController.text) ??
                                                  0,
                                              cornerRadius: 20.0,
                                              activeFgColor: Colors.white,
                                              inactiveBgColor: Colors.grey,
                                              inactiveFgColor: Colors.white,
                                              labels: InAppStrings.genders,
                                              activeBgColors: [
                                                for (var i
                                                    in InAppStrings.genders)
                                                  IColors.themeColor
                                              ],
                                              onToggle: (index) {
                                                _genderController.text =
                                                    index.toString();
                                              },
                                            )
                                          ],
                                        )
                                      : SizedBox(),
                                  ALittleVerticalSpace(),
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
                        ),
                      ),
                    ],
                  ),
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
          } else if (entity.isPatient) {
            (entity.mEntity as PatientEntity).weight =
                double.parse(_weightController.text);
            (entity.mEntity as PatientEntity).height =
                double.parse(_heightController.text);
            entity.patient.city = _currentCity.text;
            entity.patient.birthLocation = _birthCity.text;
            entity.patient.genderNumber = intPossible(_genderController.text);
            entity.patient.birthDate =
                DateTimeService.getDateStringFormDateTime(
                    DateTimeService.getJalalyDateFromJalilyString(
                            _jalaliBirthDate.text)
                        ?.toDateTime());
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
    if (_formKey.currentState.validate()) {
      if (_nationalCodeController.text == null ||
          _nationalCodeController.text == "" ||
          _nationalCodeController.text.length != 10) {
        showError();
      } else {
        if (entity.isPatient) {
          if (!isNumeric(_weightController.text) ||
              !isNumeric(_heightController.text)) {
            showError();
          } else {
            String birthDate = DateTimeService.getDateStringFormDateTime(
                DateTimeService.getJalalyDateFromJalilyString(
                        _jalaliBirthDate.text)
                    ?.toDateTime());
            (dataBloc as PatientBloc).updateProfile(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                birthCity: _birthCity.text,
                currentCity: _currentCity.text,
                nationalCode: _nationalCodeController.text,
                genderNumber: intPossible(_genderController.text),
                weight: double.parse(_weightController.text),
                height: double.parse(_heightController.text),
                birthDate: birthDate);
          }
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
    } else {
      showError();
    }
  }
}
