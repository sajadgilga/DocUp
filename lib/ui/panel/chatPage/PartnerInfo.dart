import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/assets.dart';
 import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class PartnerInfo extends StatelessWidget {
  final Entity entity;
  final Function(String, UserEntity) onPush;

  PartnerInfo({Key key, this.entity, @required this.onPush}) : super(key: key);

  Widget _isOnline() => Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5)),
      );

  void _showDoctorDialogue(context) {
//    showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(
//            title: Text(
//              "منتظر ما باشید",
//              textAlign: TextAlign.center,
//              style: TextStyle(
//                  fontSize: 16, fontWeight: FontWeight.bold),
//            ),
//            content: Text("این امکان در نسخه‌های بعدی اضافه خواهد شد",
//                textAlign: TextAlign.right,
//                style: TextStyle(fontSize: 12)),
//          );
//        });

    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isPatient)
      onPush(NavigatorRoutes.doctorDialogue, entity.partnerEntity);
    else if (entity.isDoctor)
      onPush(NavigatorRoutes.patientDialogue, entity.partnerEntity);
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
                  child: ClipPolygon(
                    sides: 6,
                    rotate: 90,
                    child: (entity.partnerEntity.user.avatar != null
                        ? Image.network(entity.partnerEntity.user.avatar)
                        : Image.asset(Assets.emptyAvatar)),
                  )),
              Align(
                  alignment: Alignment(-.75, 1),
                  child: (entity.partnerEntity.user.online > 0
                      ? _isOnline()
                      : Container()))
            ],
          )));

  Widget _info() => Column(
        children: <Widget>[
          Text(
            entity.partnerEntity.user.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          Text(
            entity.pExpert,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          )
        ],
      );

  Widget _location() => Row(
        children: <Widget>[
          Text(
            entity.pClinicName,
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
      padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 10),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
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
