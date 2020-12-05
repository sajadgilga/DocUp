import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/MedicalTestListBloc.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/models/NewestNotificationResponse.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/repository/DoctorRepository.dart';
import 'package:docup/repository/PatientRepository.dart';
import 'package:docup/ui/panel/partnerContact/videoOrVoiceCallPage/call.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'NavigatorView.dart';

class NotificationNavigationRepo {
  static bool isCallStarted = false;
  static int lastVisitIdPage;
  static int lastTestIdPage;
  final Function onPush;

  NotificationNavigationRepo(this.onPush);

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  Future<void> joinVideoOrVoiceCall(
      context, String channelName, int visitType, User user) async {
    if (isCallStarted) return;
    isCallStarted = true;
    await _handleCameraAndMic();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          channelName: channelName,
          videoCall: visitType == 1 ? false : (visitType == 2 ? true : null),
          user: user,
        ),
      ),
    );
  }

  Future<void> navigateToPanel(NewestVisit visit, BuildContext context) {
    bool isDoctor =
        BlocProvider.of<EntityBloc>(context).state?.entity?.isDoctor;
    Future<UserEntity> getPartnerEntity() async {
      UserEntity uEntity;
      if (!isDoctor) {
        uEntity = await DoctorRepository().getDoctor(visit.doctor);
      } else {
        uEntity = await PatientRepository().getPatient(visit.patient);
      }
      return uEntity;
    }

    /// TODO maybe it is better to delete true
    if (isDoctor != null && lastVisitIdPage != visit.id || true) {
      LoadingAlertDialog loadingAlertDialog = LoadingAlertDialog(context);
      loadingAlertDialog.showLoading();
      getPartnerEntity().then((partner) {
        loadingAlertDialog.disposeDialog();
        partner.vid = visit.id;
        lastVisitIdPage = visit.id;
        onPush(NavigatorRoutes.panel, partner);
      });
    }
  }

  Future<void> navigateToTestPage(
      NewestMedicalTest test, BuildContext context) async {
    /// TODO maybe it is better to delete true
    if (NotificationNavigationRepo.lastTestIdPage != test.testId || true) {
      MedicalTestItem medicalTestItem =
          MedicalTestItem(test.testId, "تست", description: "", done: false);
      PatientEntity uEntity;
      bool isDoctor =
          BlocProvider.of<EntityBloc>(context).state?.entity?.isDoctor;
      if (isDoctor) {
        LoadingAlertDialog loadingAlertDialog = LoadingAlertDialog(context);
        loadingAlertDialog.showLoading();
        uEntity = await PatientRepository().getPatient(test.patient_id);
        loadingAlertDialog.disposeDialog();
      }

      MedicalTestPageData medicalTestPageData = MedicalTestPageData(
          editableFlag: true,
          medicalTestItem: medicalTestItem,
          patientEntity: uEntity,
          panelId: test.panelId,
          onDone: () {
            BlocProvider.of<MedicalTestListBloc>(context)
                .add(GetPanelMedicalTest(panelId: test.panelId));
          });
      onPush(NavigatorRoutes.cognitiveTest, medicalTestPageData);
      NotificationNavigationRepo.lastTestIdPage = test.testId;
    }
  }
}
