import 'dart:async';
import 'dart:convert';

import 'package:docup/blocs/ChatMessageBloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

class SocketHelper {
  static final SocketHelper _helper = SocketHelper._internal();
  String url;
  String token;
  IOWebSocketChannel _channel;
  StreamController _broadcastStreamer = StreamController.broadcast();

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
    if (token != null && token.isNotEmpty) {
      _channel = IOWebSocketChannel.connect(
          "ws://$url/ws/chat/?Authorization=JWT $token");
      _channel.stream.listen((event) {
        onReceive(event);
      });
    } else
      print('no token set for websocket to connect');
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

  void sendMessage({type='NEW_MESSAGE', panelId, message, msgType = 0, file}) {
    Map data = Map<String, dynamic>();
    data['request_type'] = type;
    data['panel_id'] = panelId;
    data['message'] = message;
    data['type'] = msgType;
    data['file'] = file;
    data['isMe'] = '';
    _channel.sink.add(jsonEncode(data));
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
}
