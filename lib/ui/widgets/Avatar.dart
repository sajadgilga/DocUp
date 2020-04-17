import 'package:docup/models/DoctorEntity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class Avatar extends StatelessWidget {
  final String avatar;

  const Avatar({
    Key key, this.avatar
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: ClipPolygon(
        sides: 6,
        rotate: 90,
        boxShadows: [
          PolygonBoxShadow(color: Colors.black, elevation: 1.0),
          PolygonBoxShadow(color: Colors.grey, elevation: 5.0)
        ],
        child: avatar != null
            ? Image.network(avatar)
            : Image.asset("assets/avatar.png"),
      ),
    );
  }
}