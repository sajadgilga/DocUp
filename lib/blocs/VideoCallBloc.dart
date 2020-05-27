import 'dart:async';

import 'package:DocUp/models/AgoraChannelEntity.dart';
import 'package:DocUp/networking/Response.dart';
import 'package:DocUp/repository/VideoCallRepository.dart';

class VideoCallBloc {
  VideoCallRepository _repository;
  StreamController _getChannelNameController;

  StreamSink<Response<AgoraChannel>> get getChannelNameSink => _getChannelNameController.sink;

  Stream<Response<AgoraChannel>> get getChannelNameStream => _getChannelNameController.stream;

  VideoCallBloc() {
    _getChannelNameController = StreamController<Response<AgoraChannel>>();
    _repository = VideoCallRepository();
  }

  getChannelName(int doctorId) async {
    getChannelNameSink.add(Response.loading(''));
    try {
      AgoraChannel response = await _repository.getChannelName(doctorId);
      getChannelNameSink.add(Response.completed(response));
    } catch (e) {
      getChannelNameSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _getChannelNameController?.close();
  }
}
