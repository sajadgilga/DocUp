import 'dart:ui';

import 'package:Neuronio/blocs/visit_time/visit_time_bloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/AgoraChannelEntity.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/models/VisitResponseEntity.dart';
import 'package:Neuronio/repository/VideoCallRepository.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/panel/PanelAlert.dart';
import 'package:Neuronio/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'call.dart';

class VideoOrVoiceCallPage extends StatefulWidget {
  final Entity entity;
  final Function(String, UserEntity) onPush;
  final bool videoCall;

  VideoOrVoiceCallPage(
      {Key key, this.entity, @required this.onPush, this.videoCall = true})
      : super(key: key);

  @override
  _VideoOrVoiceCallPageState createState() {
    return _VideoOrVoiceCallPageState();
  }
}

class _VideoOrVoiceCallPageState extends State<VideoOrVoiceCallPage> {
  AlertDialog _loadingDialog = getLoadingDialog();

  @override
  void initState() {
    super.initState();
  }

  Widget _VideoOrVoiceCallPage({VisitEntity visitEntity}) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey, blurRadius: 1)]),
      child: Column(
        children: <Widget>[
          PartnerInfo(
            entity: widget.entity,
            onPush: widget.onPush,
          ),
          _videoCallPane(visitEntity: visitEntity)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if ([0, 1].contains(widget.entity.panel.status)) {
      if (widget.entity.isPatient) {
        return Stack(children: <Widget>[
          _VideoOrVoiceCallPage(),
          PanelAlert(
            label: Strings.requestSentLabel,
            buttonLabel: Strings.waitingForApproval,
            btnColor: IColors.disabledButton,
          )
        ]);
      } else {
        return Stack(children: <Widget>[
          _VideoOrVoiceCallPage(),
          PanelAlert(
            label: Strings.requestSentLabelDoctorSide,
            buttonLabel: Strings.waitingForApprovalDoctorSide,
            callback: () {
              widget.onPush(
                  NavigatorRoutes.patientDialogue, widget.entity.partnerEntity);
            },
          )
        ]);
      }
    } else if ([2, 3].contains(widget.entity.panel.status)) {
      return BlocBuilder<VisitTimeBloc, VisitTimeState>(
        builder: (context, _visitTimeState) {
          String _visitTime;
          if (_visitTimeState is VisitTimeLoadedState) {
            _visitTime = replaceFarsiNumber(
                DateTimeService.normalizeDateAndTime(_visitTimeState.visit.visitTime));

            return Stack(children: <Widget>[
              _VideoOrVoiceCallPage(),
              PanelAlert(
                label: 'ویزیت شما '
                    '\n'
                    '${_visitTime != null ? _visitTime : "هنوز فرا نرسیده"}'
                    '\n'
                    'است' /* Strings.notRequestTimeDoctorSide*/,
                buttonLabel: Strings.waitLabel,
                btnColor: IColors.disabledButton,
                size: AlertSize.LG,
              ) //TODO: change to timer
            ]);
          } else if (_visitTimeState is VisitTimeErrorState) {
            return APICallError(() {
              BlocProvider.of<VisitTimeBloc>(context)
                  .add(VisitTimeGet(partnerId: widget.entity.pId));
            });
          } else {
            return DocUpAPICallLoading2();
          }
        },
      );
    } else if ([6, 7].contains(widget.entity.panel.status)) {
      if (widget.entity.isPatient) {
        return Stack(children: <Widget>[
          _VideoOrVoiceCallPage(),
          PanelAlert(
            label: Strings.noAvailableVirtualVisit,
            buttonLabel: Strings.reserveVirtualVisit,
            callback: () {
              widget.onPush(
                  NavigatorRoutes.doctorDialogue, widget.entity.partnerEntity);
            },
          )
        ]);
      } else {
        return Stack(children: <Widget>[
          _VideoOrVoiceCallPage(),
          PanelAlert(
            label: Strings.noAvailableVirtualVisit,
            buttonLabel: Strings.reserveVirtualVisitDoctorSide,
            btnColor: IColors.disabledButton,
          )
        ]);
      }
    } else {
      return BlocBuilder<VisitTimeBloc, VisitTimeState>(
        builder: (context, _visitTimeState) {
          if (_visitTimeState is VisitTimeLoadedState) {
            return _VideoOrVoiceCallPage(visitEntity: _visitTimeState.visit);
          } else if (_visitTimeState is VisitTimeErrorState) {
            return APICallError(() {
              BlocProvider.of<VisitTimeBloc>(context)
                  .add(VisitTimeGet(partnerId: widget.entity.pId));
            });
          } else {
            return DocUpAPICallLoading2();
          }
        },
      );
    }
  }

  _videoCallPane({VisitEntity visitEntity}) {
    bool reservedVisitFlag = !((visitEntity == null) ||
        (widget.videoCall && visitEntity.visitMethod != 2) ||
        (!widget.videoCall && visitEntity.visitMethod != 1));
    return Column(
      children: <Widget>[
        SizedBox(
          height: 80,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: AutoText(
            widget.entity.isPatient
                ? (widget.videoCall
                    ? Strings.videoCallPatientPanelDescription
                    : Strings.voiceCallPatientPanelDescription)
                : (widget.videoCall
                    ? Strings.videoCallDoctorPanelDescription
                    : Strings.voiceCallDoctorPanelDescription),
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        ALittleVerticalSpace(
          height: 20,
        ),
        Visibility(
          visible: !reservedVisitFlag,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: IColors.red),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoText(
                widget.videoCall
                    ? Strings.noReservedVideoCall
                    : Strings.noReservedVoiceCall,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        ALittleVerticalSpace(
          height: 20,
        ),
        Visibility(
          visible: true,
          child: ActionButton(
            color:
                reservedVisitFlag ? IColors.themeColor : IColors.disabledButton,
            icon: Icon(
                widget.videoCall ? Icons.videocam : Icons.record_voice_over),
            title: reservedVisitFlag
                ? (widget.videoCall ? "تماس تصویری" : "تماس صوتی")
                : "ویزیت غیرفعال",
            callBack: () {
              if (reservedVisitFlag) {
                showLoadingDialog();
                onJoin(visitId: visitEntity.id).then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallPage(
                        channelName: value,
                        videoCall: widget.videoCall,
                        user: widget.entity.partnerEntity.user,
                        visit: visitEntity,
                        entity: widget.entity,
                      ),
                    ),
                  );
                });
              }
            },
          ),
        )
      ],
    );
  }

  showLoadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 6), () {
            Navigator.of(context).pop(true);
          });
          return _loadingDialog;
        });
  }

  Future<String> onJoin({int visitId}) async {
//     await for camera and mic permissions before pushing video page
    await _handleCameraAndMic();
//     push video page with given channel name

    AgoraChannel channel = await VideoCallRepository()
        .getChannelName(widget.entity.pId, visitId: visitId);

    return channel.channelName;
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }
}
