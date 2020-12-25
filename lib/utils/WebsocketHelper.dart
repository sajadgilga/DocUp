import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class SocketHelper {
  static final SocketHelper _helper = SocketHelper._internal();
  String url;
  String token;
  IOWebSocketChannel _channel;
  StreamController _broadcastStreamer = StreamController.broadcast();
  final int _maxRetryTimeout = 32;
  int _retryCount = 0;
  final List<Map<String, dynamic>> messageQueue = [];
  final TextEditingController webSocketStatusController =
      TextEditingController();
  bool appIsPaused = false;

  factory SocketHelper() {
    return _helper;
  }

  SocketHelper._internal();

  void init(String url) async {
    this.url = url;
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    this.connect(url);
  }

  void connect(String url) {
    if (appIsPaused) {
      Future.delayed(Duration(milliseconds: 800), () {
        print("App Is Waiting for UnPause");
        connect(url);
      });
      return;
    }
    checkInternetConnection().then((value) {
      if (value) {
        if (token != null && token.isNotEmpty) {
          _channel = IOWebSocketChannel.connect(
              "ws://$url/ws/chat/?Authorization=JWT $token",
              pingInterval: Duration(milliseconds: 2000));

          Future.delayed(Duration(milliseconds: 0), () {
            print('websocket connected');
            webSocketStatusController.text = "1";
          }).then((value) {
            print("websocket listening");
            try{
              channel.stream.asBroadcastStream().listen((event) {
                _retryCount = 0;
                onReceive(event);
              }, onDone: () {
                print('websocket got done ' + DateTime.now().toString());
                webSocketStatusController.text = "0";

                /// as disconnected status
                final _retryTimeout = min(_maxRetryTimeout, 2 ^ (_retryCount++));
                Future.delayed(Duration(seconds: _retryTimeout)).then((value) {
                  connect(url);
                });
              }, onError: (err) {
                webSocketStatusController.text = "0";

                /// as disconnected status
                print('websocket error ' + DateTime.now().toString());
                final _retryTimeout = min(_maxRetryTimeout, 2 ^ (_retryCount++));
                Future.delayed(Duration(seconds: _retryTimeout)).then((value) {
                  connect(url);
                });
              });
            }catch(e){

            }


            /// as connected status
            retryingMessageQueue();
          });
        } else
          print('no token set for websocket to connect');
      } else {
        Future.delayed(Duration(milliseconds: 800), () {
          print("Internet Connection Error");
          connect(url);
        });
      }
    });
  }

  void reconnect() {
    _channel = IOWebSocketChannel.connect(
        "ws://$url/ws/chat/?Authorization=JWT $token");
    _channel.stream.listen((event) {
      onReceive(event);
    });
  }

  void onError(err) {
    print(err);
    reconnect();
    //TODO
  }

  void close({int code = 0, String reason = ''}) {
    _channel.sink.close(code, reason);
  }

  void retryingMessageQueue() {
    try {
      for (int i = messageQueue.length - 1; i >= 0; i--) {
        Map<String, dynamic> data = messageQueue[i];
        _channel.sink.add(jsonEncode(data));
        messageQueue.removeAt(i);
      }
    } catch (e) {}
  }

  void sendMessage(
      {type = 'NEW_MESSAGE', panelId, message, msgType = 0, file}) {
    Map data = Map<String, dynamic>();
    data['request_type'] = type;
    data['panel_id'] = panelId;
    data['message'] = message;
    data['type'] = msgType;
    data['file'] = file;
    data['isMe'] = '';
    try {
      _channel.sink.add(jsonEncode(data));
    } catch (e) {
      // SocketHelper().connect(ApiProvider.URL_IP);
    }
  }

  void checkMessageAsSeen({type = 'SEND_SEEN', panelId, msgId}) {
    Map data = Map<String, dynamic>();
    data['request_type'] = type;
    data['panel_id'] = panelId;
    data['message_id'] = msgId;
    try {
      _channel.sink.add(jsonEncode(data));
    } catch (e) {
      // SocketHelper().connect(ApiProvider.URL_IP);
    }
  }

  void onReceive(data) {
    _broadcastStreamer.add(data);
    //TODO
  }

  IOWebSocketChannel get channel {
    return _channel;
  }

  Stream get stream {
    return _broadcastStreamer.stream;
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }
}
