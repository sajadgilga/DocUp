import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class DoctorSummary extends StatelessWidget {
  final String name;
  final String speciality;
  final String location;

  DoctorSummary(this.name, this.speciality, this.location);

  Widget _doctorImage() => Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      child: Container(
        width: 50,
        child: Hero(
            tag: 'doctorImage$name',
            transitionOnUserGestures: true,
            child: ClipPolygon(
              sides: 6,
              rotate: 90,
              boxShadows: [
                PolygonBoxShadow(color: Colors.black, elevation: 1.0),
                PolygonBoxShadow(color: Colors.grey, elevation: 2.0)
              ],
              child: Image(
                image: AssetImage('assets/lion.jpg'),
              ),
            )),
      ));

  Widget _description() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            name,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            speciality,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                location,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                Icons.add_location,
                size: 15,
              ),
            ],
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _description(),
        _doctorImage(),
      ],
    );
  }
}
