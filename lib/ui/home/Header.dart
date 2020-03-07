import 'package:docup/ui/home/notification/NotificationPage.dart';
import 'package:flutter/material.dart';

import 'notification/Notification.dart';

class Header extends StatelessWidget {
  Widget _docUpIcon() {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Image(
        image: AssetImage('assets/DocUpHome.png'),
        width: 100,
        height: 100,
      ),
      alignment: Alignment.centerRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationPage()));
              },
              child: HomeNotification()),
          _docUpIcon(),
        ],
      ),
      padding: EdgeInsets.only(left: 20, right: 10),
    );
  }
}
