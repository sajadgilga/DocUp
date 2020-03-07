import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class ChatBubble extends StatefulWidget {
  final Color color;
  final String text;
  final DateTime dateTime;

  final bool isSelfChat;
  final bool isHomePageChat;

  ChatBubble(
      {Key key,
      this.text,
      this.dateTime,
      this.color,
      this.isSelfChat = false,
      this.isHomePageChat = true})
      : super(key: key);

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  List<BoxShadow> _shadow() => <BoxShadow>[
        BoxShadow(
            color: Color.fromRGBO(20, 20, 20, .7),
            offset: Offset(1, 1),
            blurRadius: 5)
      ];

  BorderRadius _borderRadius() => BorderRadius.only(
      bottomRight: Radius.circular(5), topRight: Radius.circular(5));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5, right: 5, left: 25),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(-1, 0),
            child: CustomPaint(
              painter: ChatTriangle(widget.isSelfChat, widget.isHomePageChat),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: widget.color,
                borderRadius: _borderRadius(),
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(3, 3),
                      color: Color.fromRGBO(20, 20, 20, .3),
                      blurRadius: 2)
                ]),
            child: Text(
              'من من من',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
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
    var paint = Paint()..color = IColors.background;
    var path = Path();
    var shadowPath = Path();
    shadowPath.lineTo(-12, 20);
    shadowPath.lineTo(0, 41);
    path.lineTo(-10, 20);
    path.lineTo(0, 40);
    canvas.drawShadow(shadowPath, Colors.black, 5, false);
    canvas.drawPath(path, paint);
  }
}
