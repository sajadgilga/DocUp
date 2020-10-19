import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/home/iPartner/IPartnerBody.dart';
import 'package:docup/ui/widgets/DoctorSummary.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IPartner extends StatelessWidget {
  final UserEntity partner;
  final Function(String, dynamic) onPush;
  final Function(int) selectPage;
  final Function(String, UserEntity) globalOnPush;
  final Color color;
  final String label;
  final bool isEmpty;

  IPartner(
      {Key key,
      this.partner,
      @required this.onPush,
      this.globalOnPush,
      this.color,
      this.selectPage,
      this.label,
      this.isEmpty = false})
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
              child: AutoText(
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

  void _chatPage() {
    selectPage(0);
  }

  Widget _body(context) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (isEmpty)
      return Expanded(
        child: Center(
          child: AutoText(
            (entity.isPatient
                ? Strings.emptyDoctorLabel
                : Strings.emptyPatientLabel),
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      );
    return Expanded(
        child: GestureDetector(
      onTap: () {
        _chatPage();
      },
      child: IPartnerBody(
          selectPage: selectPage,
          partner: partner,
          onPush: onPush,
          globalOnPush: globalOnPush,
          color: color),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
      decoration: _IDoctorDecoration(),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width, maxHeight: 160),
      child: Column(
        children: <Widget>[_IDoctorLabel(), _body(context)],
      ),
    );
  }
}
