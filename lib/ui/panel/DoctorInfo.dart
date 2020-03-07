import 'package:docup/models/Doctor.dart';
import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class DoctorInfo extends StatelessWidget {
  final Doctor doctor;

  DoctorInfo({Key key, this.doctor}) : super(key: key);

  Widget _isOnline() => Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5)),
      );

  Widget _image() => Container(
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
                child: Image(
                  image: AssetImage('assets/lion.jpg'),
                ),
              )),
          Align(alignment: Alignment(-.75, 1), child: _isOnline())
        ],
      ));

  Widget _info() => Column(
        children: <Widget>[
          Text(
            doctor.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          Text(
            doctor.speciality,
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
            doctor.location,
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
      padding: EdgeInsets.all(30),
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
