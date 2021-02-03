import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/home/iPartner/ChatBox.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/DoctorSummary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IPartnerBody extends StatelessWidget {
  final UserEntity partner;
  final Function(String, dynamic) onPush;
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

  void _showDoctorDialogue(context) {
//    globalOnPush(NavigatorRoutes.doctorDialogue);
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isPatient)
      onPush(NavigatorRoutes.doctorDialogue, entity.partnerEntity);
//      globalOnPush(NavigatorRoutes.doctorDialogue, entity.partnerEntity);
    else if (entity.isDoctor)
      onPush(NavigatorRoutes.patientDialogue, entity.partnerEntity);
//      globalOnPush(NavigatorRoutes.patientDialogue, entity.partnerEntity);
  }

  String _getSubHeader(context) {
    if (partner == null) return '';
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isPatient)
      return (entity.partnerEntity as DoctorEntity).expert;
    else
      return entity.panel.statusDescription; //TODO
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
      return ""; //TODO
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
              selectPage(1);
            },
            child: Container(
              color: Color.fromARGB(0, 0, 0, 0),
              child: ChatBox(
                selectPage: selectPage,
                color: color,
                onPush: this.onPush,
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
              selectPage(1);
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
}
