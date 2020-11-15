import 'dart:async';

import 'package:docup/blocs/MedicalTestListBloc.dart';
import 'package:docup/blocs/SingleMedicalTestBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/models/NoronioService.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/SnackBar.dart';
import 'package:docup/ui/widgets/SquareBoxNoronioClinic.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendNoronioTestDialog {
  final PatientEntity patient;
  final BuildContext context;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  StateSetter _alertStateSetter;
  BuildContext _dialogContext;
  MedicalTestItem selectedTest;

  int actionButtonStatus = 0;
  String errorText;

  SendNoronioTestDialog(this.patient, this.context, this._scaffoldKey);

  List<NoronioServiceItem> convertToNoronioServiceList(
      List<MedicalTestItem> tests) {
    List<NoronioServiceItem> services = [];

    tests.forEach((element) {
      NoronioServiceItem cognitiveTest = NoronioServiceItem(
          element.name,
          Assets.noronioServiceBrainTest,
          element.imageURL,
          NoronioClinicServiceType.MultipleChoiceTest, () {
        _alertStateSetter(() {
          selectedTest = element;
        });
      }, true);
      services.add(cognitiveTest);
    });

    return services;
  }

  void showSendTestDialog(Function onDone) {
    final MedicalTestListBloc medicalTestListBloc = MedicalTestListBloc();
    medicalTestListBloc.add(GetClinicMedicalTest());

    SingleMedicalTestBloc medicalTestBloc = SingleMedicalTestBloc();
    StreamSubscription streamSubscription =
        medicalTestBloc.apiStream.listen((event) {
      handleResponse(event);
    });

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext alertDialogContext) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            content: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: Color.fromARGB(0, 0, 0, 0)),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: IColors.background,
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: BlocProvider.value(
                      value: medicalTestListBloc,
                      child: StatefulBuilder(builder:
                          (BuildContext dialogContext,
                              StateSetter dialogStateSetter) {
                        _alertStateSetter = dialogStateSetter;
                        _dialogContext = dialogContext;
                        return BlocBuilder<MedicalTestListBloc,
                            MedicalTestListState>(builder: (context, state) {
                          if (state is TestsListLoaded) {
                            return _widget(state.result, medicalTestBloc);
                          } else if (state is TestsListError) {
                            return APICallError(
                              tightenPage: true,
                              onRetryPressed: () {
                                BlocProvider.of<MedicalTestListBloc>(context)
                                    .add(GetClinicMedicalTest());
                              },
                            );
                          }
                          return DocUpAPICallLoading2(
                            height: 200,
                          );
                        });
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).then((value) {
      streamSubscription.cancel();
      medicalTestListBloc.close();
      medicalTestBloc.close();
      onDone();
    });
  }

  void showError(String errorText) {
    this.errorText = errorText;
    _alertStateSetter(() {
      actionButtonStatus = 2;
    });
    Future.delayed(Duration(seconds: 2), () {
      _alertStateSetter(() {
        actionButtonStatus = 0;
      });
    });
  }

  void handleResponse(response) {
    try {
      switch (response.status) {
        case Status.LOADING:
          _alertStateSetter(() {
            actionButtonStatus = 1;
          });
          break;
        case Status.ERROR:
          showError(response.toString());
          break;
        case Status.COMPLETED:
          _alertStateSetter(() {
            actionButtonStatus = 0;
          });
          Navigator.maybePop(_dialogContext);
          showSnackBar(_scaffoldKey, "تست با موفقیت برای بیمار ارسال شد",
              context: context);
          break;
        default:
          break;
      }
    } catch (e) {}
  }

  Widget _widget(
      List<MedicalTestItem> testsList, SingleMedicalTestBloc medicalTestBloc) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _services(convertToNoronioServiceList(testsList), testsList),
        ALittleVerticalSpace(),
        SizedBox(
          height: 20,
          child:
              actionButtonStatus == 2 ? AutoText(errorText ?? "") : SizedBox(),
        ),
        ActionButton(
          title: "ارسال",
          loading: actionButtonStatus == 1,
          borderRadius: 10,
          callBack: () {
            if (selectedTest == null) {
              showError("یکی از تست ها را انتخاب کنید.");
            } else
              medicalTestBloc.addTestToPatient(selectedTest.id, patient.id);
          },
          color: IColors.themeColor,
        )
      ],
    ));
  }

  Widget _services(
      List<NoronioServiceItem> serviceList, List<MedicalTestItem> testsList) {
    List<Widget> serviceRows = [];
    for (int i = 0; i < serviceList.length; i += 2) {
      Widget ch1 = SquareBoxNoronioClinicService(
        serviceList[i],
        boxSize: 100,
        defaultBgColor:
            selectedTest != null && selectedTest.id == testsList[i].id
                ? IColors.darkGrey
                : Colors.white,
      );
      Widget ch2 = (i == serviceList.length - 1)
          ? SquareBoxNoronioClinicService(
              NoronioServiceItem.empty(),
              boxSize: 100,
            )
          : SquareBoxNoronioClinicService(
              serviceList[i + 1],
              boxSize: 100,
              defaultBgColor:
                  selectedTest != null && selectedTest.id == testsList[i + 1].id
                      ? IColors.darkGrey
                      : Colors.white,
            );

      serviceRows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [ch1, ch2],
      ));
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: serviceRows,
        ),
      ),
    );
  }
}
