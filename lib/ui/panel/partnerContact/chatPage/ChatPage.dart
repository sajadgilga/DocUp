import 'dart:async';
import 'dart:convert';

import 'package:Neuronio/blocs/TextPlanBloc.dart';
import 'package:Neuronio/blocs/visit_time/visit_time_bloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/ChatMessage.dart';
import 'package:Neuronio/models/SocketRequestModel.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/ChatMessageRepository.dart';
import 'package:Neuronio/services/FirebaseService.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/visit/VisitUtils.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/ChatBubble.dart';
import 'package:Neuronio/utils/CrossPlatformFilePicker.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/WebsocketHelper.dart';
import 'package:Neuronio/utils/DateTimeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'PartnerInfo.dart';

class ChatPage extends StatefulWidget {
  final Entity entity;
  final Function(String, UserEntity, int, VisitSource) onPush;

  PatientTextPlan patientTextPlan;

  ChatPage({Key key, this.patientTextPlan, this.entity, @required this.onPush})
      : super(key: key);

  @override
  _ChatPageState createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _controller = TextEditingController();
  CustomFile selectedFile;
  bool chatPageLoading = false;
  AlertDialog _fileSendingLoading = getLoadingDialog();
  BuildContext _fileLoadingContext;

  TextPlanBloc _textPlanBloc;

  Set<String> textPlanActivationToggleTimes = Set();

  /// loading stuff
  AlertDialog _loadingDialog = getLoadingDialog();
  BuildContext loadingContext;

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _textPlanBloc.reNewStreams();
    NotificationAndFirebaseService.currentPageAndData = null;
    super.dispose();
  }

  void _initialApiCall() {
    BlocProvider.of<VisitTimeBloc>(context)
        .add(VisitTimeGet(partnerId: widget.entity.pId));
    _textPlanBloc.add(
        GetPatientTextPlanEvent(partnerId: widget.entity.partnerEntity.id));
  }

  @override
  void initState() {
    /// update currentPage in notification service
    NotificationAndFirebaseService.currentPageAndData =
        MapEntry(this.runtimeType.toString(), {'entity': widget.entity});

    /// init state
    _textPlanBloc = BlocProvider.of<TextPlanBloc>(context);
    widget.patientTextPlan = widget.patientTextPlan ?? PatientTextPlan();
    _textPlanBloc.listen((TextPlanState state) {
      if (state is TextPlanLoaded) {
        setState(() {
          widget.patientTextPlan = state.textPlan;
        });
      } else if (state is TextPlanError) {}
    });

    _initialApiCall();
    if (widget.entity.isPatient || true) {
      SocketHelper().stream.listen((event) {
        Map<String, dynamic> data = json.decode(event);
        if (data != null &&
            intPossible(data['panel_id']) ==
                widget.entity.panelByPartnerId.id) {
          if (data['request_type'] ==
              SocketMessageType.TOGGLE_VISIT_TEXT_PLAN.name) {
            if (isActivateDeactivateMessageUnique(data['time'])) {
              print(event);
              setState(() {
                widget.patientTextPlan.id = data['visit_text_plan_id'];
                widget.patientTextPlan.enabled = data['enabled'];
                widget.patientTextPlan.panelId = data['panel_id'];
                textPlanActivationToggleTimes.add(data['time']);
              });
            }
          }
        }
      });
    }

    _textPlanBloc.togglePatientTextPlanStream
        .asBroadcastStream()
        .listen((data) {
      if (data.status == Status.LOADING) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              loadingContext = context;
              return _loadingDialog;
            });
      } else {
        if (loadingContext != null) {
          Navigator.of(loadingContext).pop();
        }
        if (data.status == Status.COMPLETED) {
          /// notifying patient
          ActivateOrDeactivatePatientTextPlan m =
              ActivateOrDeactivatePatientTextPlan(
                  SocketMessageType.TOGGLE_VISIT_TEXT_PLAN,
                  widget.entity.iPanelId,
                  widget.patientTextPlan?.id,
                  data.data.enabled,
                  DateTimeService.getCurrentTime());
          SocketHelper().sendToSocket(socketRequest: m);
          setState(() {
            widget.patientTextPlan.enabled = data.data.enabled;
          });
        } else if (data.status == Status.ERROR) {
          toast(context, data.error.toString());
        }
      }
    });
    super.initState();

    SocketHelper().webSocketStatusController.addListener(() {
      setState(() {});
    });
  }

  bool isActivateDeactivateMessageUnique(String time) {
    if (this.textPlanActivationToggleTimes.contains(time)) {
      return false;
    }
    return true;
  }

  void _submitMsg({bool nowIsVisitTime = false}) {
    if (selectedFile != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            _fileLoadingContext = context;
            return _fileSendingLoading;
          });
      try {
        ChatMessage chatMessage = ChatMessage(file: selectedFile);
        chatMessage.updateTypeFromFile();
        ChatMessageRepository()
            .uploadFileMessage(
                panel: widget.entity.iPanelId, message: chatMessage)
            .then((value) {
          if (_fileLoadingContext != null) {
            Navigator.of(_fileLoadingContext).pop();
            _fileLoadingContext = null;
          }
          selectedFile = null;

          NewMessageSocketRequest newMessageSocketRequest =
              NewMessageSocketRequest(
                  SocketMessageType.NEW_MESSAGE,
                  value.message.panelId,
                  value.message.type,
                  value.message.message,
                  value.message.fileLink,
                  '',
                  value.message.id);
          SocketHelper().sendToSocket(socketRequest: newMessageSocketRequest);
          setState(() {});
        });
      } catch (e) {
        if (_fileLoadingContext != null) {
          Navigator.of(_fileLoadingContext).maybePop();
          _fileLoadingContext = null;
        }
        showOneButtonDialog(context, InAppStrings.chatFileMessageFailed,
            InAppStrings.okAction, () {});
      }
    } else {
      String text = _controller.text.trim();
      if (text == '') {
        return;
      }
      NewMessageSocketRequest newMessageSocketRequest = NewMessageSocketRequest(
          SocketMessageType.NEW_MESSAGE,
          widget.entity.iPanelId,
          MessageType.Text.index,
          text,
          null,
          '',
          null);
      SocketHelper().sendToSocket(socketRequest: newMessageSocketRequest);
      // if (!nowIsVisitTime) {
      //   widget.textPlanRemainedTraffic.remainedWords -= min(
      //       text.split(" ").length, widget.textPlanRemainedTraffic.remainedWords);
      // }
      _controller.text = '';
      setState(() {});
    }
  }

  Widget _sendButton() => GestureDetector(
      onTap: () {
        if (SocketHelper().webSocketStatusController.text == "1" &&
            widget.patientTextPlan.enabled) {
          _submitMsg();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 8.0),
        child: Container(
          width: 45,
          height: 35,
          decoration: BoxDecoration(
              color: widget.patientTextPlan.enabled
                  ? IColors.themeColor
                  : IColors.darkGrey,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                    color: IColors.themeColor, blurRadius: 10, spreadRadius: 1)
              ]),
          padding: EdgeInsets.all(5),
          child: SocketHelper().webSocketStatusController.text == "1" ||
                  !widget.patientTextPlan.enabled
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
        ),
      ));

  Widget _fileSelectionButton() => GestureDetector(
      onTap: () async {
        if (selectedFile == null) {
          selectedFile = await CrossPlatformFilePicker.pickCustomFile(
              AllowedFile.images + AllowedFile.pdf + AllowedFile.videos);
        } else {
          selectedFile = null;
        }
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 4.0),
        child: Container(
            width: 45,
            height: 35,
            decoration: BoxDecoration(
                color: selectedFile == null ? IColors.themeColor : IColors.red,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                      color: selectedFile == null
                          ? IColors.themeColor
                          : IColors.red,
                      blurRadius: 10,
                      spreadRadius: 1)
                ]),
            padding: EdgeInsets.all(5),
            child: Icon(
              selectedFile == null ? Icons.attach_file : Icons.delete,
              color: Colors.white,
              size: 20,
            )),
      ));

  Widget _inputTextField({bool nowIsVisitTime = false}) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          controller: selectedFile != null
              ? TextEditingController(text: selectedFile.name)
              : _controller,
          maxLines: 4,
          minLines: 1,
          enabled: selectedFile == null,
          onSubmitted: (text) {
            _submitMsg(nowIsVisitTime: nowIsVisitTime);
          },
          textAlign: selectedFile != null ? TextAlign.start : TextAlign.end,
          decoration: InputDecoration(hintText: "...اینجا بنویسید"),
        ),
      ),
    );
  }

  Widget _sendBox({bool nowIsVisitTime = false}) {
    return Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.grey, offset: Offset(0, 5), blurRadius: 10)
        ]),
        padding: EdgeInsets.only(top: 5, bottom: 10),
        child: Column(
          children: [
            /// text plan temporary removed
            widget.entity.isPatient
                ? (!widget.patientTextPlan.enabled
                    ? GestureDetector(
                        onTap: () {
                          widget.onPush(
                              NavigatorRoutes.doctorDialogue,
                              widget.entity.partnerEntity,
                              null,
                              VisitSource.USUAL);
                        },
                        child: Container(
                          // height: 20,
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: AutoText(
                              InAppStrings.noActivePatientTextPlanForChatRoom),
                        ),
                      )
                    : SizedBox())
                : GestureDetector(
                    onTap: () {
                      _textPlanBloc.activateAndDeactivatePatientTextPlan(
                          widget.patientTextPlan.id,
                          widget.entity.panelByPartnerId.id,
                          !widget.patientTextPlan.enabled);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(widget.patientTextPlan.enabled
                              ? Icons.close_rounded
                              : Icons.check),
                          AutoText(widget.patientTextPlan.enabled
                              ? InAppStrings.deactivatePatientTextPlan
                              : InAppStrings.activatePatientTextPlan),
                        ],
                      ),
                    ),
                  ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _fileSelectionButton(),
                _sendButton(),
                _inputTextField(nowIsVisitTime: nowIsVisitTime)
              ],
            ),
          ],
        ));
  }

  Widget _chatPage({bool nowIsVisitTime = false}) {
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
            onPush: (string, userEntity) {
              widget.onPush(string, userEntity, null, VisitSource.USUAL);
            },
          ),
          _ChatBox(entity: widget.entity),
          _sendBox(nowIsVisitTime: nowIsVisitTime),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    // try {
    if ([4, 5].contains(widget.entity.panel.status)) {
      return BlocBuilder<VisitTimeBloc, VisitTimeState>(
        builder: (context, _visitTimeState) {
          if (_visitTimeState is VisitTimeLoadedState) {
            return _chatPage(nowIsVisitTime: true);
          } else if (_visitTimeState is VisitTimeErrorState) {
            return APICallError(
              () {
                _initialApiCall();
              },
            );
          } else {
            return DocUpAPICallLoading2();
          }
        },
      );
    } else if ([0, 1, 2, 3, 6, 7].contains(widget.entity.panel.status)) {
      /// no visit for now
      return _chatPage();
    }
    // } catch (error) {
    //   print(error);
    //   return APICallError(
    //     () {
    //       _initialApiCall();
    //     },
    //   );
    // }
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

  bool isMessageUnique(msgId) {
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
          if (data != null &&
              intPossible(data['panel_id']) ==
                  widget.entity.panelByPartnerId.id) {
            if (data['request_type'] == SocketMessageType.NEW_MESSAGE.name) {
              if (isMessageUnique(data['id'])) {
                print(data);
                _messages.insert(
                    0, ChatMessage.fromJson(data, widget.entity.isPatient));
              }
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
                        _loadData(down: 0);
                      }
                    }

                    return false;
                  },
                  child: (_messages == null || _messages.length == 0)
                      ? Center(
                          child: AutoText(
                            InAppStrings.emptyChatPage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: IColors.darkGrey),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: _messages.length + 1,
                          addAutomaticKeepAlives: true,
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
  }
}
