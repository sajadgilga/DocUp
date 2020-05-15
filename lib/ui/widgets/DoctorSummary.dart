import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class PartnerSummary extends StatelessWidget {
  final String name;
  final String speciality;
  final String location;
  final String url;

  PartnerSummary({this.name, this.speciality, this.location, this.url});

  Widget _doctorImage() => Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      child: Container(
        width: 50,
        child: ClipPolygon(
          sides: 6,
          rotate: 90,
          boxShadows: [
            PolygonBoxShadow(color: Colors.black, elevation: 1.0),
            PolygonBoxShadow(color: Colors.grey, elevation: 2.0)
          ],
          child: Image(
            image: (url != null
                ? NetworkImage(url)
                : AssetImage('assets/avatar.png')),
          ),
        ),
      ));

  Widget _description(context) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 5),
//              constraints: BoxConstraints(
//                  maxWidth: MediaQuery.of(context).size.width * .3),
              child: Text(
                (name != null? name: ''),
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
          Text(
            (speciality != null? speciality: ''),
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                (location != null? location: ''),
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
        Expanded(flex: 2, child: _description(context)),
        _doctorImage(),
      ],
    );
  }
}
