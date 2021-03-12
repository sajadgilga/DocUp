import 'dart:async';

import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/MedicalTestListBloc.dart';
import 'package:Neuronio/models/MedicalTest.dart';
import 'package:Neuronio/models/NewestNotificationResponse.dart';
import 'package:Neuronio/models/Panel.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/repository/DoctorRepository.dart';
import 'package:Neuronio/repository/PatientRepository.dart';
import 'package:Neuronio/repository/TextPlanRepository.dart';
import 'package:Neuronio/ui/panel/partnerContact/videoOrVoiceCallPage/call.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/entityUpdater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'NavigatorView.dart';

class NotificationNavigationRepo {
  static bool isCallStarted = false;
  static int lastVisitIdPage;
  static int lastTestIdPage;
  final Function(String, dynamic, dynamic, dynamic, Function) onPush;

  NotificationNavigationRepo(this.onPush);

  void navigate(BuildContext context, NewestNotif newestNotifs) {
    EntityAndPanelUpdater.processOnEntityLoad((entity) {
      navigation(entity, newestNotifs, context);
    });
  }

  void navigation(
      Entity entity, NewestNotif newestNotifs, BuildContext context) {
    print("Navigating to determined page");
    int type = newestNotifs.notifType;
    if (type == 1) {
      /// voice or video call
      joinVideoOrVoiceCall(
          context, newestNotifs as NewestVideoVoiceCallNotif, entity);
    } else if ([2, 3].contains(type)) {
      /// test send and response
      navigateToTestPage(newestNotifs as NewestMedicalTestNotif, context);
    } else if ([5, 6].contains(type)) {
      /// visit
      if (entity.isDoctor) {
        navigateToPatientRequestPage(newestNotifs as NewestVisitNotif, context);
      } else if (entity.isPatient) {
        navigateToPanelByVisitNotification(
            newestNotifs as NewestVisitNotif, context);
      }
    } else if (type == 7) {
      /// visit request reminder
      navigateToPanelByVisitNotification(
          newestNotifs as NewestVisitNotif, context);
    } else if (type == 8) {
      /// visit reminder
      navigateToPanelByVisitNotification(
          newestNotifs as NewestVisitNotif, context);
    } else if (type == 9) {
      /// do nothing for now
    } else if (type == 10) {
      navigateToPanelByChatMessage(
        newestNotifs as NewestChatMessage,
        context,
      );
    }
  }

  Future<void> _handleCameraAndMic() async {
    if (CrossPlatformDeviceDetection.isWeb) {
      /// TODO web
    } else {
      await PermissionHandler().requestPermissions(
        [PermissionGroup.camera, PermissionGroup.microphone],
      );
    }
  }

  Future<void> joinVideoOrVoiceCall(context,
      NewestVideoVoiceCallNotif videoVoiceCallNotif, Entity entity) async {
    /// TODO need to provide visit to call page later
    // if (isCallStarted) return;
    isCallStarted = true;
    await _handleCameraAndMic();
    // showLoadingDialog(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          channelName: videoVoiceCallNotif.channelName,
          videoCall: videoVoiceCallNotif.visit.visitMethod == 1
              ? false
              : (videoVoiceCallNotif.visit.visitMethod == 2 ? true : null),
          user: videoVoiceCallNotif.user,
          entity: entity,
          visit: videoVoiceCallNotif.visit,
        ),
      ),
    );
  }

  // showLoadingDialog(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         Future.delayed(Duration(seconds: 6), () {
  //           Navigator.of(context).pop(true);
  //         });
  //       });
  // }

  Future<void> navigateToPanelByVisitNotification(
      NewestVisitNotif visit, BuildContext context) {
    bool isDoctor =
        BlocProvider.of<EntityBloc>(context).state?.entity?.isDoctor;
    Future<UserEntity> getPartnerEntity() async {
      UserEntity uEntity;
      if (!isDoctor) {
        uEntity = await DoctorRepository().getDoctor(visit.doctorId);
      } else {
        uEntity = await PatientRepository().getPatient(visit.patientId);
      }
      return uEntity;
    }

    Future<PatientTextPlan> getPatientTextPlan() async {
      PatientTextPlan patientTextPlan;
      if (!isDoctor) {
        patientTextPlan =
            await TextPlanRepository().getTextPlan(visit.doctorId);
      } else {
        patientTextPlan =
            await TextPlanRepository().getTextPlan(visit.patientId);
      }
      return patientTextPlan;
    }

    /// TODO maybe it is better to delete true
    if (isDoctor != null && lastVisitIdPage != visit.visitId || true) {
      LoadingAlertDialog loadingAlertDialog = LoadingAlertDialog(context);
      loadingAlertDialog.showLoading();
      getPartnerEntity().then((partner) {
        getPatientTextPlan().then((textPlan) {
          loadingAlertDialog.disposeDialog();
          partner.vid = visit.visitId;
          lastVisitIdPage = visit.visitId;
          onPush(NavigatorRoutes.panel, partner, textPlan, null , null);
        });
      });
    }
  }

  Future<void> navigateToPanelByChatMessage(
      NewestChatMessage chatMessageNotif, BuildContext context) {
    Entity entity = BlocProvider.of<EntityBloc>(context).state?.entity;
    bool isDoctor = entity?.isDoctor;
    Future<UserEntity> getPartnerEntity() async {
      UserEntity uEntity;
      Panel panel = entity.getPanelByPanelId(chatMessageNotif.panelId);
      if (!isDoctor) {
        uEntity = await DoctorRepository().getDoctor(panel.doctorId);
      } else {
        uEntity = await PatientRepository().getPatient(panel.patientId);
      }
      return uEntity;
    }

    Future<PatientTextPlan> getPatientTextPlan() async {
      PatientTextPlan patientTextPlan;
      Panel panel = entity.getPanelByPanelId(chatMessageNotif.panelId);
      if (!isDoctor) {
        patientTextPlan =
            await TextPlanRepository().getTextPlan(panel.doctorId);
      } else {
        patientTextPlan =
            await TextPlanRepository().getTextPlan(panel.patientId);
      }
      return patientTextPlan;
    }

    LoadingAlertDialog loadingAlertDialog = LoadingAlertDialog(context);
    loadingAlertDialog.showLoading();
    getPartnerEntity().then((partner) {
      getPatientTextPlan().then((textPlan) {
        loadingAlertDialog.disposeDialog();
        onPush(NavigatorRoutes.panel, partner, textPlan, null, null);
      });
    });
  }

  Future<void> navigateToPatientRequestPage(
      NewestVisitNotif visit, BuildContext context) {
    bool isDoctor =
        BlocProvider.of<EntityBloc>(context).state?.entity?.isDoctor;
    Future<UserEntity> getPartnerEntity() async {
      UserEntity uEntity;
      if (!isDoctor) {
        uEntity = await DoctorRepository().getDoctor(visit.doctorId);
      } else {
        uEntity = await PatientRepository().getPatient(visit.patientId);
      }
      return uEntity;
    }

    /// TODO maybe it is better to delete true
    if (isDoctor != null && lastVisitIdPage != visit.visitId || true) {
      LoadingAlertDialog loadingAlertDialog = LoadingAlertDialog(context);
      loadingAlertDialog.showLoading();
      getPartnerEntity().then((partner) {
        loadingAlertDialog.disposeDialog();
        partner.vid = visit.visitId;
        lastVisitIdPage = visit.visitId;
        onPush(NavigatorRoutes.patientDialogue, partner, null, null, null);
      });
    }
  }

  Future<void> navigateToTestPage(
      NewestMedicalTestNotif test, BuildContext context) async {
    /// TODO maybe it is better to delete true
    if (NotificationNavigationRepo.lastTestIdPage != test.testId || true) {
      PanelMedicalTestItem medicalTestItem = PanelMedicalTestItem(
        id: test.panelCognitiveTestId,
        testId: test.testId,
        name: test.testTitle,
        description: "",
        done: false,
        panelId: test.panelId,
      );
      PatientEntity uEntity;
      bool isDoctor =
          BlocProvider.of<EntityBloc>(context).state?.entity?.isDoctor;
      if (isDoctor) {
        LoadingAlertDialog loadingAlertDialog = LoadingAlertDialog(context);
        loadingAlertDialog.showLoading();
        uEntity = await PatientRepository().getPatient(test.patientId);
        loadingAlertDialog.disposeDialog();
      }

      if (medicalTestItem.isGoogleDocTest) {
        if (isDoctor) {
          /// TODO
        } else {
          launchURL(medicalTestItem.testLink);
        }
      } else if (medicalTestItem.isInAppTest) {
        MedicalTestPageData medicalTestPageData = MedicalTestPageData(
            MedicalPageDataType.Panel,
            editableFlag: true,
            sendableFlag: false,
            medicalTestItem: medicalTestItem,
            patientEntity: uEntity,
            panelId: test.panelId, onDone: () {
          BlocProvider.of<MedicalTestListBloc>(context)
              .add(GetPanelMedicalTest(panelId: test.panelId));
        });
        onPush(NavigatorRoutes.cognitiveTest, medicalTestPageData, null, null,
            null);
        NotificationNavigationRepo.lastTestIdPage = test.testId;
      }
    }
  }
}
