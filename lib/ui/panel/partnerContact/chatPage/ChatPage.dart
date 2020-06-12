import 'dart:async';
import 'dart:convert';

import 'package:docup/blocs/ChatMessageBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/visit_time/visit_time_bloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/ChatMessage.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/PanelAlert.dart';
import 'package:docup/ui/widgets/ChatBubble.dart';
import 'package:docup/ui/widgets/Waiting.dart';
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
    SocketHelper()
        .sendMessage(panelId: _entity.iPanelId, message: _controller.text);

    _controller.text = '';
//    FocusScope.of(context).unfocus();
//    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
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
              maxLines: 4,
              minLines: 1,
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
//    return
//      StreamBuilder(
//        stream: SocketHelper().stream,
//        builder: (context, snapshot) {
//          var data = json.decode(snapshot.data.toString());
//          ChatMessage msg = null;
//          if (data != null) if (data['request_type'] == 'NEW_MESSAGE') {
//            msg = ChatMessage.fromSocket(data, widget.entity.isPatient);
//            var _chatMessageBloc = BlocProvider.of<ChatMessageBloc>(context);
//            _chatMessageBloc.add(ChatMessageAddToList(msg: msg));
//          }
    return _ChatBox(entity: widget.entity);
//        });
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
        try {
          if (state.entity.panel.status == 0 ||
              state.entity.panel.status == 1) {
            if (state.entity.isPatient)
              return Stack(children: <Widget>[
                _ChatPage(),
                PanelAlert(
                  label: Strings.requestSentLabel,
                  buttonLabel: Strings.waitingForApproval,
                  btnColor: IColors.disabledButton,
                )
              ]);
            else
              return Stack(children: <Widget>[
                _ChatPage(),
                PanelAlert(
                  label: Strings.requestSentLabelDoctorSide,
                  buttonLabel: Strings.waitingForApprovalDoctorSide,
                  callback: () {
                    widget.onPush(NavigatorRoutes.patientDialogue,
                        state.entity.partnerEntity);
                  },
                )
              ]);
          } else if (state.entity.panel.status == 3 ||
              state.entity.panel.status == 2) {
//            return _ChatPage();
            return BlocBuilder<VisitTimeBloc, VisitTimeState>(
              builder: (context, _visitTimeState) {
                String _visitTime;
                if (_visitTimeState is VisitTimeLoadedState)
                  _visitTime = replaceFarsiNumber(normalizeDateAndTime(
                      _visitTimeState
                          .visit
                          .visitTime));
                return Stack(children: <Widget>[
                  _ChatPage(),
                  PanelAlert(
                    label: 'ویزیت شما '
                        '\n'
                        '${_visitTime != null ? _visitTime : "هنوز فرا نرسیده"}'
                        '\n'
                        'است' /* Strings.notRequestTimeDoctorSide*/,
                    buttonLabel: Strings.waitLabel,
                    btnColor: IColors.disabledButton,
                    size: AlertSize.LG,
                  ) //TODO: change to timer
                ]);
              },
            );
          } else if (state.entity.panel.status == 6 ||
              state.entity.panel.status == 7) {
            if (state.entity.isPatient)
              return Stack(children: <Widget>[
                _ChatPage(),
                PanelAlert(
                  label: Strings.noAvailableVirtualVisit,
                  buttonLabel: Strings.reserveVirtualVisit,
                  callback: () {
                    widget.onPush(NavigatorRoutes.doctorDialogue,
                        state.entity.partnerEntity);
                  },
                )
              ]);
            else
              return Stack(children: <Widget>[
                _ChatPage(),
                PanelAlert(
                  label: Strings.noAvailableVirtualVisit,
                  buttonLabel: Strings.reserveVirtualVisitDoctorSide,
                  btnColor: IColors.disabledButton,
                )
              ]);
          } else
            return _ChatPage();
        } catch (_) {
          return Container();
        }
      },
    );
  }
}

class _ChatBox extends StatefulWidget {
  final Entity entity;
  final ChatMessage message;

  _ChatBox({Key key, this.entity, this.message}) : super(key: key);

  @override
  _ChatBoxState createState() {
    return _ChatBoxState();
  }
}

class _ChatBoxState extends State<_ChatBox> {
  List<ChatMessage> _messages = [];
  int length = 0;

  @override
  void didUpdateWidget(oldWidget) {
//    setState(() {
////      _messages = _messages;
//    length = _messages.length;
//    });
    super.didUpdateWidget(oldWidget);
  }

  bool isUnique(msgId) {
    for (ChatMessage m in _messages) {
      if (m.id == msgId) return false;
    }
    return true;
  }

  void uniqueMaker() {
    Map<int, dynamic> map = Map();
    List<ChatMessage> removes = [];
    for (ChatMessage m in _messages) {
      if (map.containsKey(m.id))
        removes.add(m);
      else
        map[m.id] = '';
    }
    _messages.removeWhere((element) => removes.contains(element));
  }

  Widget _msgList({messages}) {
    return StreamBuilder(
        stream: SocketHelper().stream,
        builder: (context, snapshot) {
          var data = json.decode(snapshot.data.toString());
          if (data != null) if (data['request_type'] == 'NEW_MESSAGE') {
//            setState(() {
//            });
//          var _chatMessageBloc = BlocProvider.of<ChatMessageBloc>(context);
            if (isUnique(data['id']))
              _messages.insert(
                  0, ChatMessage.fromSocket(data, widget.entity.isPatient));
          }
          uniqueMaker();
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 2,
        child: BlocBuilder<ChatMessageBloc, ChatMessageState>(
            builder: (context, state) {
          if (state is ChatMessageLoaded) {
            _messages = state.chatMessages;
            if (widget.message != null) _messages.insert(0, widget.message);
            if (_messages.length > 0) {
              length = _messages.length;
              return _msgList();
            } else
              return Center(
                child: Text(
                  Strings.emptyChatPage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: IColors.darkGrey),
                ),
              );
          }
          if (state is ChatMessageLoading) {
            _messages = state.chatMessages;
            if (state.chatMessages != null) {
              if (widget.message != null) _messages.insert(0, widget.message);
              if (_messages.length > 0) {
                length = _messages.length;
                return _msgList();
              } else
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
