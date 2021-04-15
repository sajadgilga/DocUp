import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/home/iPartner/IPartnerBody.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/Waiting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IPartner extends StatelessWidget {
  final UserEntity partner;
  final Function(String, dynamic, dynamic, dynamic, Function) onPush;
  final Function(int) selectPage;
  final Function(String, UserEntity) globalOnPush;
  final Color color;
  final String label;
  final BlocState partnerState;

  IPartner(
      {Key key,
      this.partner,
      @required this.onPush,
      this.globalOnPush,
      this.color,
      this.selectPage,
      this.label,
      this.partnerState = BlocState.Loaded})
      : super(key: key);

  Widget _iDoctorLabel() => Container(
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

  BoxDecoration _iDoctorDecoration() => BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Color.fromRGBO(255, 255, 255, .8));

  // void _chatPage() {
  //   selectPage(0);
  // }

  Widget _body(context) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (partnerState == BlocState.Empty) {
      return Expanded(
        child: Center(
          child: AutoText(
            (entity.isPatient
                ? InAppStrings.emptyDoctorLabel
                : InAppStrings.emptyPatientLabel),
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (partnerState == BlocState.Loaded) {
      return Expanded(
          child: IPartnerBody(
              selectPage: selectPage,
              partner: partner,
              onPush: onPush,
              globalOnPush: globalOnPush,
              color: color));
    } else {
      // (partnerState == BlocState.Loading)
      return Expanded(
        child: Center(
          child: Waiting(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
      decoration: _iDoctorDecoration(),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width, maxHeight: 160),
      child: Column(
        children: <Widget>[_iDoctorLabel(), _body(context)],
      ),
    );
  }
}
