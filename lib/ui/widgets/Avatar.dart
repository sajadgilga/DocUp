import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class PolygonAvatar extends StatelessWidget {
  final User user;
  double imageSize;
  final Image defaultImage;

  PolygonAvatar({Key key, this.user, this.imageSize, this.defaultImage})
      : super(key: key);

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
      user != null
          ? Visibility(
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
            )
          : SizedBox(),
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

    if (user != null && user.avatar != null && user.avatar != "") {
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
      if (this.defaultImage == null)
        return defaultImage();
      else
        return this.defaultImage;
    }
  }
}

class EditingCircularAvatar extends StatelessWidget {
  final User user;
  final double radius;
  final bool editableFlag;
  final Image defaultImage;

  const EditingCircularAvatar(
      {Key key,
      this.user,
      this.radius = 120,
      this.editableFlag = true,
      this.defaultImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: <Widget>[
      Container(
        width: radius + 2,
        height: radius + 2,
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 2,
          )
        ]),
      ),
      CircleAvatar(
        radius: radius / 2,
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        backgroundImage: user != null && user.avatar != null
            ? NetworkImage(user.avatar)
            : (defaultImage != null
                ? defaultImage.image
                : AssetImage("assets/avatar.png")),
      ),
      editableFlag
          ? Container(
              width: radius,
              height: radius,
              child: Container(
                alignment: Alignment.bottomLeft,
                child: Icon(
                  Icons.camera_alt,
                  size: 35,
                  color: Colors.white,
                ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(0, 0, 0, 0),
              ),
            )
          : SizedBox(),
      !editableFlag
          ? Visibility(
              visible: user.online >= 1,
              child: Positioned(
                bottom: 0,
                left: 16,
                child: Icon(
                  Icons.brightness_1,
                  color: IColors.blue,
                  size: 16,
                ),
              ),
            )
          : SizedBox(),
    ]);
  }
}
