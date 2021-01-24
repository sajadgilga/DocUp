import 'package:docup/models/ChatMessage.dart';
import 'package:docup/utils/CrossPlatformSvg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/colors.dart';
import 'AutoText.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  final bool isHomePageChat;

  bool get isMe {
    return message.fromMe;
  }

  ChatBubble({Key key, this.message, this.isHomePageChat = true})
      : super(key: key);

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  List<BoxShadow> _shadow() => (widget.isHomePageChat
      ? [
          BoxShadow(
              offset: Offset(3, 3),
              color: Color.fromRGBO(20, 20, 20, .3),
              blurRadius: 2)
        ]
      : []);

  BorderRadius _borderRadius() => (widget.isMe
      ? BorderRadius.only(
          bottomLeft: Radius.circular(5), topLeft: Radius.circular(5))
      : BorderRadius.only(
          bottomRight: Radius.circular(5), topRight: Radius.circular(5)));

  Widget _triangle() => Align(
        alignment: (widget.isMe ? Alignment(1, 0) : Alignment(-1, 0)),
        child: CustomPaint(
          painter: ChatTriangle(widget.isMe, widget.isHomePageChat),
        ),
      );

  EdgeInsets _margin() => (widget.isMe
      ? EdgeInsets.only(top: 5, bottom: 5, right: 25, left: 5)
      : EdgeInsets.only(top: 5, bottom: 5, right: 5, left: 25));

  Widget _chatBubble(width) => Container(
        constraints: BoxConstraints(maxWidth: width * .7, minWidth: 40),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: (widget.isMe
                ? IColors.selfChatBubble
                : IColors.doctorChatBubble),
            borderRadius: _borderRadius(),
            shape: BoxShape.rectangle,
            boxShadow: _shadow()),
        child: AutoText(
          widget.message.message,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
              fontSize: 12,
              color: (widget.isMe
                  ? IColors.selfChatText
                  : IColors.doctorChatText)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _margin(),
      child: Stack(
        children: <Widget>[
          _triangle(),
          Container(
              alignment:
                  (widget.isMe ? Alignment.centerRight : Alignment.centerLeft),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: (widget.isMe
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end),
                  children: <Widget>[
                    _chatBubble(MediaQuery.of(context).size.width),
                    _dateAndStatus()
                  ],
                ),
              ))
        ],
      ),
    );
  }

  _dateAndStatus() {
    var dateAndStatus = <Widget>[
      Container(
          padding: EdgeInsets.only(top: 5),
          child: AutoText(
            '${widget.message.createdDate.hour}:${widget.message.createdDate.minute}', //TODO
            style: TextStyle(fontSize: 8),
          )),
    ];
    if (widget.isMe) {
      if (widget.message.isRead)
        dateAndStatus.add(Container(
            padding: EdgeInsets.only(left: 5, top: 5),
            child: CrossPlatformSvg.asset(
              'assets/whatsapp.svg',
              color: Colors.green,
              width: 10,
              height: 10,
            )));
      else
        dateAndStatus.add(Container(
            padding: EdgeInsets.only(left: 5, top: 5),
            child: CrossPlatformSvg.asset(
              'assets/whatsapp.svg',
              color: Colors.green,
              width: 10,
              height: 10,
            )));

    }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: dateAndStatus,
      ),
    );
  }
}

class ChatTriangle extends CustomPainter {
  final bool isSelfChat;
  final bool isHomePageChat;

  ChatTriangle(
    this.isSelfChat,
    this.isHomePageChat,
  );

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (isHomePageChat) {
      var paint = Paint()..color = IColors.doctorChatBubble;
      var path = Path();
      var shadowPath = Path();
      shadowPath.lineTo(-12, 20);
      shadowPath.lineTo(0, 41);
      path.lineTo(-10, 20);
      path.lineTo(0, 40);
      canvas.drawShadow(shadowPath, Colors.black, 5, false);
      canvas.drawPath(path, paint);
    } else {
      var paint = Paint()
        ..color =
            (isSelfChat ? IColors.selfChatBubble : IColors.doctorChatBubble);
      var path = Path();
      if (isSelfChat) {
        path.lineTo(10, 20);
        path.lineTo(0, 40);
      } else {
        path.lineTo(-10, 20);
        path.lineTo(0, 40);
      }
      canvas.drawPath(path, paint);
    }
  }
}
