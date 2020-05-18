import 'dart:async';
import 'dart:convert';

import 'package:docup/blocs/ChatMessageBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/ChatMessage.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/panel/PanelAlert.dart';
import 'package:docup/ui/widgets/ChatBubble.dart';
import 'package:docup/utils/Utils.dart';
import 'package:docup/utils/WebsocketHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'PartnerInfo.dart';

class ChatPage extends StatefulWidget {
  final Entity entity;
  final Function(String, UserEntity) onPush;

  ChatPage({Key key, this.entity, @required this.onPush}) : super(key: key);

  @override
  _ChatPageState createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _controller = TextEditingController();

  void _submitMsg() {
//    var _chatMessageBloc = BlocProvider.of<ChatMessageBloc>(context);
    if (_controller.text == '') {
      return;
    }
    var _entity = BlocProvider.of<EntityBloc>(context).state.entity;
//    _chatMessageBloc.add(ChatMessageSend(
//        msg: ChatMessage(
//            message: _controller.text,
//            direction: (_entity.isPatient ? 0 : 1),
//            type: 0),
//        panelId: _entity.iPanelId));
    SocketHelper().sendMessage(
        type: 0, panelId: _entity.iPanelId, message: _controller.text);

    _controller.text = '';
    FocusScope.of(context).unfocus();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
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
//              textDirection: TextDirection.rtl,
              decoration: InputDecoration(hintText: "...اینجا بنویسید"),
            ),
          )
        ],
      ));

  Widget _chatBox() {
    List<ChatMessage> _messages = [];
    var _state = BlocProvider.of<ChatMessageBloc>(context).state;
    if (_state is ChatMessageLoaded)
      _messages =
          (BlocProvider.of<ChatMessageBloc>(context).state as ChatMessageLoaded)
              .chatMessages;
    if (_state is ChatMessageLoading)
      _messages = (BlocProvider.of<ChatMessageBloc>(context).state
              as ChatMessageLoading)
          .chatMessages;

    return _ChatBox(
      entity: widget.entity,
      messages: _messages,
    );
  }

  Widget _ChatPage() {
    var _chatMessageBloc = BlocProvider.of<ChatMessageBloc>(context);
    _chatMessageBloc.add(ChatMessageGet(
        panelId: widget.entity.iPanelId,
        size: 50,
        isPatient: widget.entity.isPatient));
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

  Widget build(BuildContext context) {
//    _startTimer();
    return BlocBuilder<EntityBloc, EntityState>(
      builder: (context, state) {
        if (state is EntityLoaded) {
          if (state.entity.panel.status == 0 ||
              state.entity.panel.status == 1) if (state.entity.isPatient)
            return Stack(children: <Widget>[
              _ChatPage(),
              PanelAlert(
                label: Strings.requestSentLabel,
                buttonLabel: Strings.waitingForApproval,
              )
            ]);
          else
            return Stack(children: <Widget>[
              _ChatPage(),
              PanelAlert(
                label: Strings.requestSentLabelDoctorSide,
                buttonLabel: Strings.waitingForApprovalDoctorSide,
              )
            ]);
          else if (state.entity.panel.status == 3) if (state.entity.isPatient)
              _ChatPage();
          else
            return Stack(children: <Widget>[
              _ChatPage(),
              PanelAlert(
                label: Strings.notRequestTimeDoctorSide,
                buttonLabel: Strings.waitLabel,
              )
            ]);
          else if (state.entity.panel.status == 6 ||
              state.entity.panel.status == 7 ||
              state.entity.panel.status == 4 ||
              state.entity.panel.status == 2) if (state.entity.isPatient)
            return Stack(children: <Widget>[
              _ChatPage(),
              PanelAlert(
                label: Strings.noAvailableVirtualVisit,
                buttonLabel: Strings.reserveVirtualVisit,
              )
            ]);
          else
            return Stack(children: <Widget>[
              _ChatPage(),
              PanelAlert(
                label: Strings.noAvailableVirtualVisit,
                buttonLabel: Strings.reserveVirtualVisitDoctorSide,
              )
            ]);
          else
            return _ChatPage();
        }
        return Container(
            constraints:
                BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            child: Waiting());
      },
    );
  }
}

class _ChatBox extends StatefulWidget {
  final Entity entity;
  final List<ChatMessage> messages;

  _ChatBox({Key key, this.entity, this.messages}) : super(key: key);

  @override
  _ChatBoxState createState() {
    return _ChatBoxState();
  }
}

class _ChatBoxState extends State<_ChatBox> {
  List<ChatMessage> _messages = [];

  Widget _msgList() {
    return StreamBuilder(
      stream: SocketHelper().channel.stream,
      builder: (context, snapshot) {
        var data = json.decode(snapshot.toString());
        if (data['request_type'] == 'NEW_MESSAGE') {
          setState(() {
            _messages
                .add(ChatMessage.fromSocket(data, widget.entity.isPatient));
          });
        }
        return Container(
            child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(
                    message: _messages[index],
                    isHomePageChat: false,
                  );
                }));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _messages = widget.messages;
    return Expanded(
        flex: 2,
        child: BlocBuilder<ChatMessageBloc, ChatMessageState>(
            builder: (context, state) {
          if (state is ChatMessageLoaded) {
            if (_messages.length > 0)
              return _msgList();
            else
              return Center(
                child: Text(
                  Strings.emptyChatPage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: IColors.darkGrey),
                ),
              );
          }
          if (state is ChatMessageLoading) {
            if (state.chatMessages != null) {
              if (_messages.length > 0)
                return _msgList();
              else
                return Center(
                  child: Text(
                    Strings.emptyChatPage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: IColors.darkGrey),
                  ),
                );
            } else
              return Waiting();
          }
          if (state is ChatMessageEmpty) return Waiting();
          return Waiting();
        }));
  }
}
