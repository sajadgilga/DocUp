import 'package:flutter/material.dart';

import 'notification.dart';

class Header extends StatelessWidget {
  Widget _docUpIcon() {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Image(image: AssetImage('assets/DocUpHome.png'), width: 100, height: 100,),
      alignment: Alignment.centerRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        HomeNotification(),
        _docUpIcon(),
      ],
    ), padding: EdgeInsets.only(left: 20, right: 10),);
  }
}
