import 'package:Neuronio/models/ChatMessage.dart';
import 'package:Neuronio/services/VibrateAndSoundService.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/CrossPlatformSvg.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  /// image
  CachedNetworkImage cachedImage;
  ImageProvider imageProvider;

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

  Widget textBody() {
    return AutoText(
      widget.message.message,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: TextStyle(
          fontSize: 12,
          color: (widget.isMe ? IColors.selfChatText : IColors.doctorChatText)),
    );
  }

  Widget imageBody() {
    double xSize = MediaQuery.of(context).size.width;
    Widget getDownloadImageIcon() {
      return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.cloud_download, size: 30),
        ),
        onTap: () {
          setState(() {
            cachedImage = CachedNetworkImage(
              errorWidget: (context, url, error) {
                return Text("خظا در دانلود فایل");
              },
              imageBuilder: (context, imageProvider) {
                this.imageProvider = imageProvider;
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return getButtonLoadingProgress(
                    value: downloadProgress.progress, r: 30, stroke: 2);
              },
              fadeInDuration: Duration(milliseconds: 500),
              imageUrl: CrossPlatformDeviceDetection.isWeb
                  ? ""
                  : widget.message.fileLink,
            );
          });
        },
      );
    }

    if (CrossPlatformDeviceDetection.isWeb) {
      imageProvider = NetworkImage(widget.message.fileLink);
    }

    return GestureDetector(
      onTap: () {
        if (cachedImage != null) {
          launchURL(widget.message.fileLink);
        }
      },
      onLongPress: () {
        Clipboard.setData(new ClipboardData(text: widget.message.fileLink));
        toast(context, "لینک فایل کپی شد.");
        VibrateAndRingtoneService.vibrate(miliSecDuration: 200);
      },
      child: Container(
        constraints: BoxConstraints(
            minWidth: 200,
            maxWidth: 200 + xSize * (12 / 100),
            maxHeight: 300,
            minHeight: 150),
//        height: MediaQuery.of(context).size.width * (45 / 100),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: cachedImage == null
            ? getDownloadImageIcon()
            : CrossPlatformDeviceDetection.isWeb
                ? Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fill,
                            alignment: Alignment.center)),
                  )
                : cachedImage,
      ),
    );
  }

  Widget chatBody() {
    if (widget.message.messageType == MessageType.Text) {
      return textBody();
    } else if (widget.message.messageType == MessageType.Image) {
      return imageBody();
    } else {
      return GestureDetector(
          onTap: () {
            launchURL(widget.message.fileLink);
          },
          onLongPress: () {
            Clipboard.setData(new ClipboardData(text: widget.message.fileLink));
            VibrateAndRingtoneService.vibrate(miliSecDuration: 200);
            toast(context, "لینک فایل کپی شد.");
          },
          child: widget.message.fileIcon);
    }
  }

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
        child: chatBody(),
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
