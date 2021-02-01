import 'dart:convert';

import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/Avatar.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/material.dart';

class PartnerInfo extends StatelessWidget {
  final UserEntity entity;
  final Function(String, UserEntity) onPush;
  final Color bgColor;
  final EdgeInsets padding;

  PartnerInfo(
      {Key key, this.entity, @required this.onPush, this.bgColor, this.padding})
      : super(key: key);

  Widget _isOnline() => Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5)),
      );

  void _showDoctorDialogue(context) {
//    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
//    if (entity.isPatient)
//      onPush(NavigatorRoutes.doctorDialogue, entity.partnerEntity);
//    else if (entity.isDoctor)
//      onPush(NavigatorRoutes.patientDialogue, entity.partnerEntity);
  }

  Widget _image(context) => GestureDetector(
      onTap: () => _showDoctorDialogue(context),
      child: Container(
          width: 80,
          height: 70,
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Container(
                  width: 70,
                  child: PolygonAvatar(
                    user: entity.user,
                  )),
              Align(
                  alignment: Alignment(-.75, 1),
                  child: ((entity.user.online ?? 0) > 0
                      ? _isOnline()
                      : Container()))
            ],
          )));

  Widget _info() {
    String name = "";
    try {
      name = utf8.decode(entity.user.name.codeUnits);
    } catch (e) {
      try {
        name = entity.user.name;
      } catch (e) {}
    }
    String expertise = "";
    try {
      if (this.entity is DoctorEntity) {
        expertise = utf8IfPossible((entity as DoctorEntity).expert);
      }
    } catch (e) {}

    return Column(
      children: <Widget>[
        AutoText(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        AutoText(
          expertise,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        )
      ],
    );
  }

  Widget _location() => Row(
        children: <Widget>[
          AutoText(
            "",
            style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal),
            textDirection: TextDirection.rtl,
          ),
          Icon(
            Icons.add_location,
            size: 15,
            color: Colors.grey,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 10),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      color: bgColor ?? Colors.white70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _location(),
          _info(),
          _image(context),
        ],
      ),
    );
  }
}
