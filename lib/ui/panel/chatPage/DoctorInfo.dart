import 'package:docup/models/Doctor.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class DoctorInfo extends StatelessWidget {
  final DoctorEntity doctor;
  final ValueChanged<String> onPush;

  DoctorInfo({Key key, this.doctor, @required this.onPush}) : super(key: key);

  Widget _isOnline() => Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5)),
      );

  void _showDoctorDialogue() {
    onPush(NavigatorRoutes.doctorDialogue);
  }

  Widget _image() => GestureDetector(
      onTap: _showDoctorDialogue,
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
                    child: Image.network(doctor.user.avatar),
                  )),
              Align(
                  alignment: Alignment(-.75, 1),
                  child: (doctor.user.online > 0 ? _isOnline() : Container()))
            ],
          )));

  Widget _info() => Column(
        children: <Widget>[
          Text(
            doctor.user.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          Text(
            doctor.expert,
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
            doctor.clinic.clinicName,
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
          _image(),
        ],
      ),
    );
  }
}
