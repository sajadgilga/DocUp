import 'package:docup/constants/colors.dart';
import 'package:docup/models/ChatMessage.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/widgets/ChatBubble.dart';
import 'package:flutter/material.dart';

import 'DoctorInfo.dart';

class ChatPage extends StatefulWidget {
  final Doctor doctor;

  ChatPage({Key key, this.doctor}) : super(key: key);

  @override
  _ChatPageState createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  Widget _submitButton() => Container(
        width: 50,
        height: 35,
        decoration: BoxDecoration(
            color: IColors.red,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(color: IColors.red, blurRadius: 10, spreadRadius: 1)
            ]),
        padding: EdgeInsets.all(5),
        child: Icon(
          Icons.send,
          color: Colors.white,
          size: 20,
        ),
      );

  Widget _sendBox() => Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.grey, offset: Offset(0, 5), blurRadius: 10)
      ]),
      padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
      child: Row(
        children: <Widget>[
          _submitButton(),
          Expanded(
            flex: 2,
            child: TextField(
              textAlign: TextAlign.end,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(hintText: "اینجا بنویسید ..."),
            ),
          )
        ],
      ));

  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey, blurRadius: 1)]),
      child: Column(
        children: <Widget>[
          DoctorInfo(
            doctor: widget.doctor,
          ),
          _ChatBox(
            doctor: widget.doctor,
          ),
          _sendBox(),
        ],
      ),
    );
  }
}

class _ChatBox extends StatefulWidget {
  final Doctor doctor;

  _ChatBox({Key key, this.doctor}) : super(key: key);

  @override
  _ChatBoxState createState() {
    return _ChatBoxState();
  }
}

class _ChatBoxState extends State<_ChatBox> {
  List<ChatMessage> _messages = [];

  @override
  Widget build(BuildContext context) {
    var doctorMsg = ChatMessage.fromDoctor(
        text: 'من من من',
        sentDate: DateTime.now(),
        doctor: widget.doctor,
        patient: null);
    var patientMsg = ChatMessage.fromPatient(
        text: 'من من من',
        sentDate: DateTime.now(),
        doctor: widget.doctor,
        patient: null);
    _messages.add(doctorMsg);
    _messages.add(patientMsg);
    var messages = <Widget>[];
    for (var message in _messages) {
      messages.add(ChatBubble(
        message: message,
        isHomePageChat: false,
      ));
    }
    return Expanded(
      flex: 2,
      child: Container(
        child: ListView(
          children: messages,
        ),
      ),
    );
  }
}
