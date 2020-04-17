import 'package:docup/constants/colors.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/home/iPartner/IPartnerBody.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/widgets/DoctorSummary.dart';

class IPartner extends StatelessWidget {
  final UserEntity partner;
  final ValueChanged<String> onPush;
  final ValueChanged<String> globalOnPush;
  final Color color;
  final String label;

  IPartner(
      {Key key,
      this.partner,
      @required this.onPush,
      this.globalOnPush,
      this.color,
      this.label})
      : super(key: key);

  Widget _IDoctorLabel() => Container(
        constraints: BoxConstraints(maxHeight: 35),
        child: Align(
          alignment: Alignment.topRight,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)),
            child: Container(
              alignment: Alignment.center,
              color: color,
              width: 60,
              height: 30,
              child: Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

  BoxDecoration _IDoctorDecoration() => BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Color.fromRGBO(255, 255, 255, .8));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
      decoration: _IDoctorDecoration(),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width, maxHeight: 150),
      child: Column(
        children: <Widget>[
          _IDoctorLabel(),
          Expanded(
            child: IPartnerBody(
                partner: partner,
                onPush: onPush,
                globalOnPush: globalOnPush,
                color: color),
          ),
        ],
      ),
    );
  }
}
