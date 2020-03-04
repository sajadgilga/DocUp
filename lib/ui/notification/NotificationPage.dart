import 'package:docup/constants/colors.dart';
import 'package:docup/ui/notification/DrawerPainter.dart';
import 'package:flutter/material.dart';
import 'package:icon_shadow/icon_shadow.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Widget _notificationCountCircle() {
    return Container(
        alignment: Alignment.centerRight,
        child: Wrap(children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Text('۱۵',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              decoration: BoxDecoration(
                  color: IColors.red,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                        color: IColors.red,
                        offset: Offset(1, 3),
                        blurRadius: 10)
                  ])),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
        child: CustomPaint(
            painter: MyPainter(),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.25,
                  top: MediaQuery.of(context).size.height * 0.15 - 17.5,
                  child: Icon(
                    Icons.notifications,
                    size: 35,
                    color: IColors.red,
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.6,
                  top: MediaQuery.of(context).size.height * 0.3,
                  child: Text(
                    "اعلانات",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Positioned(
                    left: MediaQuery.of(context).size.width * 0.55,
                    top: MediaQuery.of(context).size.height * 0.29,
                    child: _notificationCountCircle()),
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.15,
                  top: MediaQuery.of(context).size.height * 0.4,
                  child: NotificationItem(),
                )
              ],
            )));
  }
}

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Material(
          color: IColors.grey,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text(
                    " ۱۸ آذر | ساعت ۱۸:۰۰",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  textDirection: TextDirection.rtl,
                  children: <Widget>[
                    IconShadowWidget(
                        Icon(
                          Icons.brightness_1,
                          size: 16,
                          color: IColors.red,
                        ),
                        showShadow: true,
                        shadowColor: IColors.red),
                    SizedBox(width: 5),
                    Text(
                      "مراجعه به دکتر",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: IColors.red, fontSize: 16),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "غزل کاظمی، متخصص پوست",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: IColors.darkGrey),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Row(
                    children: <Widget>[
                      Text("اقدسیه", style: TextStyle(color: IColors.darkGrey),),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: IColors.darkGrey,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
