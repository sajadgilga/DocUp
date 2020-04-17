import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/main.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/start/RoleType.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/home/iPartner/ChatBox.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/widgets/DoctorSummary.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IPartnerBody extends StatelessWidget {
  final UserEntity partner;
  final ValueChanged<String> onPush;
  final ValueChanged<String> globalOnPush;
  final Color color;

  IPartnerBody(
      {Key key,
      this.color,
      this.partner,
      @required this.onPush,
      this.globalOnPush})
      : super(key: key);

  void _showDoctorDialogue() {
    globalOnPush(NavigatorRoutes.doctorDialogue);
  }

  String _getSubHeader(context) {
    if (partner == null) return '';
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.type == RoleType.PATIENT)
      return (entity.partnerEntity as DoctorEntity).expert;
    else
      return (entity.partnerEntity as PatientEntity).user.firstName; //TODO
  }

  String _getLocation(context) {
    if (partner == null) return '';
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.type == RoleType.PATIENT)
      return (entity.partnerEntity as DoctorEntity).clinic.clinicName;
    else
      return (entity.partnerEntity as PatientEntity).user.firstName; //TODO
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(child: ChatBox(color: color)),
        SizedBox(
          width: 5,
        ),
        SizedBox(
          height: 60,
          child: VerticalDivider(
            color: Colors.grey,
            thickness: 1.5,
            width: 10,
          ),
        ),
        SizedBox(
          width: 3,
        ),
        GestureDetector(
            onTap: () {
              _showDoctorDialogue();
            },
            child: PartnerSummary(
                  name: (partner != null ? partner.user.name : ''),
                  speciality: _getSubHeader(context),
                  location: _getLocation(context),
                  url: (partner != null ? partner.user.avatar : null)),
            )
      ],
    );
  }
}