import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/ChatBubble.dart';
import '../../../constants/colors.dart';

class ChatBox extends StatefulWidget {
  @override
  _ChatBoxState createState() {
    return _ChatBoxState();
  }
}

class _ChatBoxState extends State<ChatBox> {
  Widget _myMessages() => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _myMessagesIcon(),
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

  Widget _myMessagesIcon() =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        SvgPicture.asset(
          'assets/chatBox.svg',
          color: Colors.red,
          width: 17,
          height: 17,
          alignment: Alignment.center,
        )
      ]);

  Widget _chatList() => Container(
        child: ListView(
          reverse:true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            ChatBubble(
              text: 'من من من',
              dateTime: DateTime.now(),
              color: IColors.background,
            ),
            ChatBubble(
              text: 'من من من',
              dateTime: DateTime.now(),
              color: IColors.background,
            ),
            ChatBubble(
              text: 'من من من',
              dateTime: DateTime.now(),
              color: IColors.background,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: _chatList(),
          flex: 2,
        ),
        _myMessages(),
      ],
    );
  }
}
