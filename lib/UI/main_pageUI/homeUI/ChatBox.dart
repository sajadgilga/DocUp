import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatBox extends StatefulWidget {
  @override
  _ChatBoxState createState() {
    return _ChatBoxState();
  }
}

class _ChatBoxState extends State<ChatBox> {
  Widget _myMessages() =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        SvgPicture.asset(
          'assets/chatBox.svg',
          color: Colors.red,
          width: 17,
          height: 17,
          alignment: Alignment.center,
        )
      ]);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      _myMessages(),
      SizedBox(
        height: 5,
      ),
      Text(
        'پیام‌های اخیر',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      )
    ]);
  }
}
