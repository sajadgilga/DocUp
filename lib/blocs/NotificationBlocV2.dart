import 'dart:async';

import 'package:DocUp/models/NewestNotificationResponse.dart';
import 'package:DocUp/networking/Response.dart';
import 'package:DocUp/repository/NotificationRepository.dart';


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
    sink.add(Response.loading(''));
    try {
      NewestNotificationResponse _response = await _repository.getNewestNotifications();
      sink.add(Response.completed(_response));
    } catch (e) {
      sink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _controller?.close();
  }
}
