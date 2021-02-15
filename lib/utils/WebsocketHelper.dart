import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/io.dart';

import 'dateTimeService.dart';

class SocketHelper {
  static final SocketHelper _helper = SocketHelper._internal();
  String url;
  String token;
  var _channel;

  // var _stream;
  StreamController _broadcastStreamer = StreamController.broadcast();
  final int _maxRetryTimeout = 32;
  int _retryCount = 0;
  final List<Map<String, dynamic>> messageQueue = [];
  final TextEditingController webSocketStatusController =
  TextEditingController();
  bool appIsPaused = false;

  get channel {
    return _channel;
  }

  Stream get stream {
    return _broadcastStreamer.stream;
  }

  Future<bool> checkInternetConnection() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

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

  void dispose() {
    this.url = null;
    token = null;
    close();
  }

  void connect(String url) {
    getCrossPlatformWebSocket(url,
        {Iterable<String> protocols,
          Map<String, dynamic> headers,
          Duration pingInterval}) {
      if (kIsWeb) {
        /// TODO web
        return HtmlWebSocketChannel.connect(url);
      } else {
        return IOWebSocketChannel.connect(url, pingInterval: pingInterval);
      }
    }

    if (appIsPaused) {
      Future.delayed(Duration(milliseconds: 1000), () {
        print("App Is Waiting for UnPause");
        connect(url);
      });
      return;
    }
    checkInternetConnection().then((value) {
      if (value) {
        if (token != null && token.isNotEmpty) {
          _channel = getCrossPlatformWebSocket(
              "ws://$url/ws/chat/?Authorization=JWT $token",
              pingInterval: Duration(milliseconds: 2000));
          // _stream = _channel.stream.asBroadcastStream();

          Future.delayed(Duration(milliseconds: 500), () {
            print('websocket connected');
            webSocketStatusController.text = "1";
          }).then((value) {
            print("websocket listening");
            try {
              channel.stream.asBroadcastStream().listen((event) {
                Future.delayed(Duration(seconds: 5)).then((value) {
                  if (webSocketStatusController.text == "1") {
                    _retryCount = 0;
                  }
                });
                onReceive(event);
              }, onDone: () {
                print('websocket got done ' +
                    DateTimeService.getCurrentDateTime().toString());
                webSocketStatusController.text = "0";

                /// as disconnected status
                final _retryTimeout =
                min(_maxRetryTimeout, 2 ^ (_retryCount++) + 2);
                Future.delayed(Duration(seconds: _retryTimeout)).then((value) {
                  connect(url);
                });
              }, onError: (err) {
                webSocketStatusController.text = "0";

                /// as disconnected status
                print('websocket error ' +
                    DateTimeService.getCurrentDateTime().toString());
                final _retryTimeout =
                min(_maxRetryTimeout, 2 ^ (_retryCount++) + 2);
                Future.delayed(Duration(seconds: _retryTimeout)).then((value) {
                  connect(url);
                });
              });
            } catch (e) {}

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

    /// TODO
  }
}
