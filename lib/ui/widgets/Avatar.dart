import 'package:docup/constants/colors.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class PolygonAvatar extends StatelessWidget {
  final User user;

  const PolygonAvatar({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width * 0.25,
        child: ClipPolygon(
          sides: 6,
          rotate: 90,
          boxShadows: [
            PolygonBoxShadow(color: Colors.black, elevation: 1.0),
            PolygonBoxShadow(color: Colors.grey, elevation: 5.0)
          ],
          child: user.avatar != null
              ? Image.network(user.avatar)
              : Image.asset("assets/avatar.png"),
        ),
      ),
      Visibility(
        visible: user.online == 1,
        child: Positioned(
          bottom: 0,
          left: 16,
          child: Icon(
            Icons.brightness_1,
            color: IColors.blue,
            size: 16,
          ),
        ),
      ),
    ]);
  }
}

class CircularAvatar extends StatelessWidget {
  final User user;
  final Function onTap;

  const CircularAvatar({Key key, this.user, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width * 0.25,
        child: user.avatar != null
            ? Image.network(user.avatar)
            : Image.asset("assets/avatar.png"),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)]),
      ),
      GestureDetector(
        onTap: onTap == null ? () {} : onTap(),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          height: MediaQuery.of(context).size.width * 0.25,
          child: Container(
            child: Icon(
              Icons.camera_alt,
              size: 35,
              color: Colors.white,
            ),
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(80, 0, 0, 20),
          ),
        ),
      ),
      Visibility(
        /// TODO
        visible: user.online == 1,
        child: Positioned(
          bottom: 0,
          left: 16,
          child: Icon(
            Icons.brightness_1,
            color: IColors.blue,
            size: 16,
          ),
        ),
      ),
    ]);
  }
}
