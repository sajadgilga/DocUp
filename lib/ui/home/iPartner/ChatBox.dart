import 'package:docup/models/ChatMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:docup/ui/widgets/ChatBubble.dart';
import 'package:docup/constants/colors.dart';

class ChatBox extends StatefulWidget {
  final Function(int) selectPage;
  Color color;

  ChatBox({Key key, this.color, this.selectPage}) : super(key: key);

  @override
  _ChatBoxState createState() {
    return _ChatBoxState();
  }
}

class _ChatBoxState extends State<ChatBox> {

  Widget _myMessages() => Container(
          margin: EdgeInsets.only(left: 20, right: 40),
          child: Column(
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
              ]));

  Widget _myMessagesIcon() =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        SvgPicture.asset(
          'assets/chatBox.svg',
          color: widget.color,
          width: 17,
          height: 17,
          alignment: Alignment.center,
        )
      ]);

  Widget _chatList() {
    var message = ChatMessage(
      message: 'سلام دکتر',
      fromMe: false,
      createdDate: DateTime.now(),
    );
    return Container(
      child: ListView(
        reverse: true,
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ChatBubble(
            message: message,
          ),
          ChatBubble(
            message: message,
          ),
          ChatBubble(
            message: message,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
//        Expanded(
//          child: _chatList(),
//          flex: 2,
//        ),
        _myMessages(),
      ],
    );
  }
}
