import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Neuronio/blocs/visit_time/visit_time_bloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/ChatMessage.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/repository/ChatMessageRepository.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/ChatBubble.dart';
import 'package:Neuronio/utils/WebsocketHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'PartnerInfo.dart';

class ChatPage extends StatefulWidget {
  final Entity entity;
  final Function(String, UserEntity) onPush;
  final TextPlanRemainedTraffic textPlanRemainedTraffic;

  ChatPage(
      {Key key,
      this.textPlanRemainedTraffic,
      this.entity,
      @required this.onPush})
      : super(key: key);

  @override
  _ChatPageState createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _controller = TextEditingController();
  bool chatPageLoading = false;

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SocketHelper().webSocketStatusController.addListener(() {
      setState(() {});
    });
  }

  void _submitMsg({bool nowIsVisitTime = false}) {
    String text = _controller.text.trim();
    if (text == '') {
      return;
    }
    SocketHelper().sendMessage(panelId: widget.entity.iPanelId, message: text);
    if (!nowIsVisitTime) {
      widget.textPlanRemainedTraffic.remainedWords -= min(
          text.split(" ").length, widget.textPlanRemainedTraffic.remainedWords);
    }
    _controller.text = '';
    setState(() {});
  }

  Widget _submitButton() => GestureDetector(
      onTap: () {
        if (SocketHelper().webSocketStatusController.text == "1") {
          _submitMsg();
        }
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
        child: SocketHelper().webSocketStatusController.text == "1"
            ? Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              )
            : Container(
                width: 20,
                height: 20,
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(0, 0, 0, 0),
                  child: CircularProgressIndicator(
                    strokeWidth: (20) * (10 / 100),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
      ));

  Widget _sendBox({bool nowIsVisitTime = false}) {
    return Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.grey, offset: Offset(0, 5), blurRadius: 10)
        ]),
        padding: EdgeInsets.only(top: 5, bottom: 10, right: 20, left: 20),
        child: Column(
          children: [
            /// text plan temporary removed
            // widget.entity.isPatient
            //     ? Container(
            //         height: 20,
            //         child: AutoText(nowIsVisitTime
            //             ? "پیام نا محدود هنگام ویزیت"
            //             : "کلمات باقی مانده" +
            //                 " " +
            //                 widget.textPlanRemainedTraffic.remainedWords
            //                     .toString()),
            //       )
            //     : SizedBox(),
            // widget.entity.isPatient
            //     ? Container(
            //         height: 0.2,
            //         width: MediaQuery.of(context).size.width * 0.6,
            //         color: IColors.themeColor,
            //       )
            //     : SizedBox(),
            Row(
              children: <Widget>[
                _submitButton(),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    minLines: 1,
                    onSubmitted: (text) {
                      _submitMsg(nowIsVisitTime: nowIsVisitTime);
                    },
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(hintText: "...اینجا بنویسید"),
                  ),
                )
              ],
            ),
          ],
        ));
  }

  Widget _ChatPage({bool nowIsVisitTime = false}) {
//    var _chatMessageBloc = BlocProvider.of<ChatMessageBloc>(context);
//    _chatMessageBloc.add(ChatMessageGet(
//        panelId: widget.entity.iPanelId,
//        size: 5,
//        isPatient: widget.entity.isPatient));
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
            entity: widget.entity.partnerEntity,
            onPush: widget.onPush,
          ),
          _ChatBox(entity: widget.entity),
          _sendBox(nowIsVisitTime: nowIsVisitTime),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    try {
      if ([4, 5].contains(widget.entity.panel.status)) {
        return BlocBuilder<VisitTimeBloc, VisitTimeState>(
          builder: (context, _visitTimeState) {
            if (_visitTimeState is VisitTimeLoadedState) {
              return _ChatPage(nowIsVisitTime: true);
              // if ([1,2].contains(_visitTimeState.visit.visitMethod)) {
              //   return _ChatPage();
              // } else {
              //   return Stack(children: <Widget>[
              //     _ChatPage(),
              //     PanelAlert(
              //       label: "ویزیت متنی در حال حاضر ندارید.",
              //       buttonLabel: Strings.waitLabel,
              //       btnColor: IColors.disabledButton,
              //       size: AlertSize.LG,
              //     ) //TODO: change to timer
              //   ]);
              // }
            } else if (_visitTimeState is VisitTimeErrorState) {
              return APICallError(() {
                BlocProvider.of<VisitTimeBloc>(context)
                    .add(VisitTimeGet(partnerId: widget.entity.pId));
              });
            } else {
              return DocUpAPICallLoading2();
            }
          },
        );
      } else if (widget.textPlanRemainedTraffic.remainedWords <= 0) {
        if (widget.entity.isPatient) {
          return Stack(children: <Widget>[
            _ChatPage(),

            /// TODO text plan removed temporary
            // PanelAlert(
            //   label: Strings.noRemainedWordForYouPlanInChatRoom,
            //   buttonLabel: Strings.goToTextPlanListPage,
            //   btnColor: IColors.themeColor,
            //   callback: () {
            //     Navigator.pop(context);
            //     widget.onPush(
            //         NavigatorRoutes.textPlanPage, widget.entity.doctor);
            //   },
            // )
          ]);
        } else {
          return _ChatPage();
        }
      } else if ([0, 1, 2, 3, 6, 7].contains(widget.entity.panel.status)) {
        /// no visit for now
        return _ChatPage();
      }
//       if (widget.entity.panel.status == 0 || widget.entity.panel.status == 1) {
//         if (widget.entity.isPatient)
//           return Stack(children: <Widget>[
//             _ChatPage(),
//             PanelAlert(
//               label: Strings.requestSentLabel,
//               buttonLabel: Strings.waitingForApproval,
//               btnColor: IColors.disabledButton,
//             )
//           ]);
//         else
//           return Stack(children: <Widget>[
//             _ChatPage(),
//             PanelAlert(
//               label: Strings.requestSentLabelDoctorSide,
//               buttonLabel: Strings.waitingForApprovalDoctorSide,
//               callback: () {
//                 widget.onPush(NavigatorRoutes.patientDialogue,
//                     widget.entity.partnerEntity);
//               },
//             )
//           ]);
//       } else if (widget.entity.panel.status == 3 ||
//           widget.entity.panel.status == 2) {
// //            return _ChatPage();
//         return BlocBuilder<VisitTimeBloc, VisitTimeState>(
//           builder: (context, _visitTimeState) {
//             String _visitTime;
//             if (_visitTimeState is VisitTimeLoadedState) {
//               _visitTime = replaceFarsiNumber(
//                   DateTimeService.normalizeDateAndTime(
//                       _visitTimeState.visit.visitTime));
//               return Stack(children: <Widget>[
//                 _ChatPage(),
//                 PanelAlert(
//                   label: 'ویزیت شما '
//                       '\n'
//                       '${_visitTime != null ? _visitTime : "هنوز فرا نرسیده"}'
//                       '\n'
//                       'است' /* Strings.notRequestTimeDoctorSide*/,
//                   buttonLabel: Strings.waitLabel,
//                   btnColor: IColors.disabledButton,
//                   size: AlertSize.LG,
//                 ) //TODO: change to timer
//               ]);
//             } else if (_visitTimeState is VisitTimeErrorState) {
//               return APICallError(() {
//                 BlocProvider.of<VisitTimeBloc>(context)
//                     .add(VisitTimeGet(partnerId: widget.entity.pId));
//               });
//             } else {
//               return DocUpAPICallLoading2();
//             }
//           },
//         );
//       } else if (widget.entity.panel.status == 6 ||
//           widget.entity.panel.status == 7) {
//         if (widget.entity.isPatient) {
//           return Stack(children: <Widget>[
//             _ChatPage(),
//             PanelAlert(
//               label: Strings.noAvailableVirtualVisit,
//               buttonLabel: Strings.reserveVirtualVisit,
//               callback: () {
//                 widget.onPush(NavigatorRoutes.doctorDialogue,
//                     widget.entity.partnerEntity);
//               },
//             )
//           ]);
//         } else {
//           return Stack(children: <Widget>[
//             _ChatPage(),
//             PanelAlert(
//               label: Strings.noAvailableVirtualVisit,
//               buttonLabel: Strings.reserveVirtualVisitDoctorSide,
//               btnColor: IColors.disabledButton,
//             )
//           ]);
//         }
//       }
    } catch (_) {
      return Container();
    }
  }
}

class _ChatBox extends StatefulWidget {
  final Entity entity;
  final ChatMessage message;
  final int chatSizeChunk = 50;

  _ChatBox({Key key, this.entity, this.message}) : super(key: key);

  @override
  _ChatBoxState createState() {
    return _ChatBoxState();
  }
}

class _ChatBoxState extends State<_ChatBox> with WidgetsBindingObserver {
  ChatMessageRepository _repository = ChatMessageRepository();
  List<ChatMessage> _messages = [];
  int length = 0;
  bool _isFetchingLoading = false;
  bool _chatPageLoading = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _messages = [];
    _loadData(unidirectional: false);

    if (state == AppLifecycleState.resumed) {
      setState(() {
        print("App State Changed: " + state.toString());
      });
    } else {
      setState(() {
        print("App State Changed: " + state.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  initState() {
    _loadData(unidirectional: false);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  bool isUnique(msgId) {
    for (ChatMessage m in _messages) {
      if (m.id == msgId) return false;
    }
    return true;
  }

  @override
  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (e) {}
    super.dispose();
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

  Widget _msgList() {
    return StreamBuilder(
        stream: SocketHelper().stream,
        builder: (context, snapshot) {
          var data = json.decode(snapshot.data.toString());
          print(data);
          if (data != null) {
            print(data);
            if (data['request_type'] == 'NEW_MESSAGE') {
              if (isUnique(data['id']))
                _messages.insert(
                    0, ChatMessage.fromSocket(data, widget.entity.isPatient));
            }
          }
          uniqueMaker();
          return Container(
              child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification info) {
                    if (info is ScrollStartNotification) {
                    } else if (info is UserScrollNotification) {
                    } else if (info is OverscrollNotification) {
                    } else if (info is ScrollEndNotification) {
                      /// direction is ok but api info TODO
                      if (!_isFetchingLoading &&
                          info.metrics.pixels == info.metrics.minScrollExtent) {
                        // _loadData(down: 0);
                      }
                      if (!_isFetchingLoading &&
                          info.metrics.pixels == info.metrics.maxScrollExtent) {
                        /// TODO amir: incomplete api
                        _loadData(down: 0);
                      }
                    }

                    return false;
                  },
                  child: (_messages == null || _messages.length == 0)
                      ? Center(
                          child: AutoText(
                            Strings.emptyChatPage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: IColors.darkGrey),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: _messages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              if (_isFetchingLoading) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: CircleAvatar(
                                        backgroundColor:
                                            Color.fromARGB(0, 0, 0, 0),
                                        maxRadius: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  IColors.themeColor),
                                        )),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: 40,
                                      height: 20,
                                      child: Text(
                                        "",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: IColors.darkGrey),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                            return ChatBubble(
                              message: _messages[index],
                              isHomePageChat: false,
                            );
                          })));
        });
  }

  void _checkMsgAsSeen(msgId) {
    SocketHelper()
        .checkMessageAsSeen(panelId: widget.entity.iPanelId, msgId: msgId);
  }

  Future _loadData({up = 1, down = 1, unidirectional = true}) async {
    setState(() {
      _isFetchingLoading = true;
    });
    int mid;
    if (_messages.length > 0) {
      if (unidirectional && up == 1) mid = _messages.last.id;
      if (unidirectional && down == 1) {
        mid = _messages.first.id;
        _checkMsgAsSeen(mid);
      }
    }
    final List<ChatMessage> response = await _repository.getMessages(
        panel: widget.entity.iPanelId,
        size: widget.chatSizeChunk,
        up: up,
        down: down,
        messageId: mid,
        isPatient: widget.entity.isPatient);
    setState(() {
      if (mid == null) {
        _messages.addAll(response);
      } else if (up == 1)
        _messages.addAll(response);
      else if (down == 1) {
        _messages.insertAll(0, response.reversed.toList());
      }
      _chatPageLoading = false;
      _isFetchingLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_chatPageLoading) {
      return Expanded(
        child: DocUpAPICallLoading2(
          height: MediaQuery.of(context).size.height / 2,
        ),
      );
    }

    length = _messages.length;
    return Expanded(
      flex: 2,
      child: _msgList(),
    );
//    return Expanded(
//        flex: 2,
//        child: BlocBuilder<ChatMessageBloc, ChatMessageState>(
//            builder: (context, state) {
//          if (state is ChatMessageLoaded) {
//            _messages = state.chatMessages;
//            if (widget.message != null) _messages.insert(0, widget.message);
//            if (_messages.length > 0) {
//              length = _messages.length;
//              return _msgList();
//            } else
//              return Center(
//                child: AutoText(
//                  Strings.emptyChatPage,
//                  textAlign: TextAlign.center,
//                  style: TextStyle(color: IColors.darkGrey),
//                ),
//              );
//          }
//          if (state is ChatMessageLoading) {
//            _messages = state.chatMessages;
//            if (state.chatMessages != null) {
//              if (widget.message != null) _messages.insert(0, widget.message);
//              if (_messages.length > 0) {
//                length = _messages.length;
//                return _msgList();
//              } else
//                return Center(
//                  child: AutoText(
//                    Strings.emptyChatPage,
//                    textAlign: TextAlign.center,
//                    style: TextStyle(color: IColors.darkGrey),
//                  ),
//                );
//            } else
//              return Waiting();
//          }
//          if (state is ChatMessageEmpty) return Waiting();
//          return Waiting();
//        })
//    );
  }
}
