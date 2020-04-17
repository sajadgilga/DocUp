import 'dart:async';

import 'package:docup/blocs/ChatMessageBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/ChatMessage.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/widgets/ChatBubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'PartnerInfo.dart';

class ChatPage extends StatefulWidget {
  final Entity entity;
  final ValueChanged<String> onPush;

  ChatPage({Key key, this.entity, @required this.onPush}) : super(key: key);

  @override
  _ChatPageState createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _controller = TextEditingController();

  void _submitMsg() {
    var _chatMessageBloc = BlocProvider.of<ChatMessageBloc>(context);
    var _entity = BlocProvider.of<EntityBloc>(context).state.entity;
    _chatMessageBloc.add(ChatMessageSend(
        msg: ChatMessage(
            message: _controller.text,
            direction: (_entity.isPatient ? 0 : 1),
            type: 0),
        panelId: _entity.iPanelId));
    _controller.text = '';
    FocusScope.of(context).unfocus();
  }

  Widget _submitButton() => GestureDetector(
      onTap: () {
        _submitMsg();
      },
      child: Container(
        width: 50,
        height: 35,
        decoration: BoxDecoration(
            color: IColors.themeColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  color: IColors.themeColor, blurRadius: 10, spreadRadius: 1)
            ]),
        padding: EdgeInsets.all(5),
        child: Icon(
          Icons.send,
          color: Colors.white,
          size: 20,
        ),
      ));

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
              controller: _controller,
              onSubmitted: (text) {
                _submitMsg();
              },
              textAlign: TextAlign.end,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(hintText: "اینجا بنویسید ..."),
            ),
          )
        ],
      ));

  Widget _chatBox() {
    return BlocBuilder<ChatMessageBloc, ChatMessageState>(
        builder: (context, state) {
      if (state is ChatMessageLoaded || state is ChatMessageLoading)
        return _ChatBox(
          entity: widget.entity,
        );
      else if (state is ChatMessageEmpty)
        return Expanded(
          flex: 2,
          child: Container(),
        );
      return Expanded(
        flex: 2,
        child: Container(),
      );
    });
  }

  void _startTimer() {
    var _chatMessageBloc = BlocProvider.of<ChatMessageBloc>(context);
    Timer.periodic(Duration(seconds: 5), (timer) {
      _chatMessageBloc.add(ChatMessageGet(
          panelId: widget.entity.iPanelId,
          size: 20,
          isPatient: widget.entity.isPatient));
    });
  }

  Widget build(BuildContext context) {
    _startTimer();
    return Container(
      margin: EdgeInsets.only(top: 20),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey, blurRadius: 1)]),
      child: Column(
        children: <Widget>[
          PartnerInfo(
            entity: widget.entity,
            onPush: widget.onPush,
          ),
          _chatBox(),
          _sendBox(),
        ],
      ),
    );
  }
}

class _ChatBox extends StatefulWidget {
  final Entity entity;

  _ChatBox({Key key, this.entity}) : super(key: key);

  @override
  _ChatBoxState createState() {
    return _ChatBoxState();
  }
}

class _ChatBoxState extends State<_ChatBox> {
  List<ChatMessage> _messages = [];

  @override
  Widget build(BuildContext context) {
    if (BlocProvider.of<ChatMessageBloc>(context).state is ChatMessageLoaded)
      _messages =
          (BlocProvider.of<ChatMessageBloc>(context).state as ChatMessageLoaded)
              .chatMessages;
//    _messages.add(ChatMessage.fromPatient(
//      text: "آخ آخ. یادم رفت. همین الان میفرستم",
//      sentDate: DateTime.now(),
//      doctor: widget.entity.doctor,
//      patient: widget.entity.patient,
//    ));
//    _messages.add(ChatMessage.fromDoctor(
//      text: "جواب آزمایش‌هاتون رو فرستادین برام؟",
//      sentDate: DateTime.now(),
//      doctor: widget.entity.doctor,
//      patient: widget.entity.patient,
//    ));
//    _messages.add(ChatMessage.fromPatient(
//      text: "سلام. ممنون دکتر. امیدوارم شماهم خوب باشید",
//      sentDate: DateTime.now(),
//      doctor: widget.entity.doctor,
//      patient: widget.entity.patient,
//    ));
//    _messages.add(ChatMessage.fromDoctor(
//      text: "سلام دوست عزیز. خوب هستی شما؟",
//      sentDate: DateTime.now(),
//      doctor: widget.entity.doctor,
//      patient: widget.entity.patient,
//    ));

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
            child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(
                    message: _messages[index],
                    isHomePageChat: false,
                  );
                })
//          ListView(
//            reverse: true,
//            children: messages,
//          ),
            ));
  }
}
