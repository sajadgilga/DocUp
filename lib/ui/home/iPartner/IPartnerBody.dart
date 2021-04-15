import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/Panel.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/repository/TextPlanRepository.dart';
import 'package:Neuronio/ui/home/iPartner/ChatBox.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/DoctorSummary.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IPartnerBody extends StatelessWidget {
  final UserEntity partner;
  final Function(String, dynamic, dynamic, dynamic, Function) onPush;
  final Function(int) selectPage;
  final Function(String, UserEntity) globalOnPush;
  final Color color;

  IPartnerBody(
      {Key key,
      this.color,
      this.partner,
      @required this.onPush,
      this.selectPage,
      this.globalOnPush})
      : super(key: key);

  String _getSubHeader(context) {
    if (partner == null) return '';
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isPatient)
      return (entity.partnerEntity as DoctorEntity).expert;
    else
      return entity.panel
          .statusDescription; //TODO: check if it is working properly and change to customer journey changing
  }

  String _getLocation(context) {
    if (partner == null) return '';
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isPatient) {
      final clinic = (entity.partnerEntity as DoctorEntity).clinic;
      if (clinic != null)
        return clinic.clinicName;
      else
        return '';
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        GestureDetector(
            onTap: () {
              // var _state = BlocProvider.of<EntityBloc>(context).state;
              // this.onPush(NavigatorRoutes.panel, _state.entity.partnerEntity);
              // selectPage(1);
              var _state = BlocProvider.of<EntityBloc>(context).state;
              navigateToPanelByChatMessage(_state.entity.panelByPartnerId.id,
                  _state.entity.partnerEntity, context);
            },
            child: Container(
              color: Color.fromARGB(0, 0, 0, 0),
              child: ChatBox(
                selectPage: selectPage,
                color: color,
                onPush: (string, entity) {
                  onPush(string, entity, null, null, null);
                },
              ),
            )),
        SizedBox(
          height: 60,
          child: VerticalDivider(
            color: Colors.grey,
            thickness: 1.5,
            width: 5,
          ),
        ),
        SizedBox(
          width: 3,
        ),
        Expanded(
//            child: GestureDetector(
//          onTap: () {
//            _showDoctorDialogue(context);
//            selectPage(0);
//          },
          child: GestureDetector(
            onTap: () {
              // var _state = BlocProvider.of<EntityBloc>(context).state;
              // onPush(NavigatorRoutes.myPartnerDialog, _state.entity.partnerEntity);

              var _state = BlocProvider.of<EntityBloc>(context).state;
              navigateToPanelByChatMessage(_state.entity.panelByPartnerId.id,
                  _state.entity.partnerEntity, context);
              // this.onPush(NavigatorRoutes.panel, _state.entity.partnerEntity);
              // selectPage(1);
            },
            child: Container(
              color: Color.fromARGB(0, 0, 0, 0),
              child: PartnerSummary(
                  name: (partner != null ? partner.user.name : ''),
                  speciality: _getSubHeader(context),
                  location: _getLocation(context),
                  url: (partner != null ? partner.user.avatar : null)),
            ),
          ),
        )
      ],
    );
  }

  Future<void> navigateToPanelByChatMessage(
      int panelId, UserEntity partner, BuildContext context) {
    Entity entity = BlocProvider.of<EntityBloc>(context).state?.entity;
    bool isDoctor = entity?.isDoctor;

    Future<PatientTextPlan> getPatientTextPlan() async {
      PatientTextPlan patientTextPlan;
      Panel panel = entity.getPanelByPanelId(panelId);
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
    getPatientTextPlan().then((textPlan) {
      loadingAlertDialog.disposeDialog();
      onPush(NavigatorRoutes.panel, partner, textPlan, null, null);
    });
  }
}
