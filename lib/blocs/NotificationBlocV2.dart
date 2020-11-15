import 'dart:async';

import 'package:docup/models/NewestNotificationResponse.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/NotificationRepository.dart';


class NotificationBlocV2 {
  NotificationRepository _repository;
  StreamController _controller;

  StreamSink<Response<NewestNotificationResponse>> get sink =>
      _controller.sink;


  Stream<Response<NewestNotificationResponse>> get stream =>
      _controller.stream;


  NotificationBlocV2() {
    _controller = StreamController<Response<NewestNotificationResponse>>();
    _repository = NotificationRepository();
  }

  get() async {
    sink.add(Response.loading());
    try {
      NewestNotificationResponse _response = await _repository.getNewestNotifications();
      _response = await NewestNotificationResponse.removeSeenNotifications(_response);
      sink.add(Response.completed(_response));
    } catch (e) {
      sink.add(Response.error(e));
      print(e);
    }
  }

  dispose() {
    _controller?.close();
  }
}
