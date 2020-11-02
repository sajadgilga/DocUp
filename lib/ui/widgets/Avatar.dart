import 'package:docup/constants/colors.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class PolygonAvatar extends StatelessWidget {
  final User user;
  double imageSize;

  PolygonAvatar({Key key, this.user, this.imageSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageSize == null) {
      imageSize = MediaQuery.of(context).size.width * 0.25;
    }
    return Stack(children: <Widget>[
      Container(
        width: imageSize,
        child: ClipPolygon(
          sides: 6,
          rotate: 90,
          boxShadows: [
            PolygonBoxShadow(color: Colors.black, elevation: 1.0),
            PolygonBoxShadow(color: Colors.grey, elevation: 5.0)
          ],
          child: imageHandler(),
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

  Widget imageHandler() {
    Widget defaultImage() {
      return Image.asset(
        "assets/avatar.png",
        width: imageSize,
        height: imageSize,
      );
    }

    if (user.avatar != null && user.avatar != "") {
      Widget image;
      try {
        image = Image.network(
          user.avatar,
          errorBuilder: (context, error, stackTrace) {
            return defaultImage();
          },
        );
      } catch (e) {
        image = defaultImage();
      }
      return image;
    } else {
      return defaultImage();
    }
  }
}

class EditingCircularAvatar extends StatelessWidget {
  final User user;
  final double radius;

  const EditingCircularAvatar({Key key, this.user,this.radius=120}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: <Widget>[
      Container(
        width: radius,
        child: user.avatar != null
            ? Image.network(user.avatar)
            : Image.asset("assets/avatar.png"),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)]),
      ),
      Container(
        width: radius,
        height: radius,
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
