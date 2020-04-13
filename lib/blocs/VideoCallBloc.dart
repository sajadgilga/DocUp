import 'dart:async';

import 'package:docup/blocs/timer/TimerEvent.dart';
import 'package:docup/models/AgoraChannelEntity.dart';
import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/models/DoctorResponseEntity.dart';
import 'package:docup/models/TicketResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/VideoCallRepository.dart';
import 'package:docup/repository/AuthRepository.dart';
import 'package:docup/repository/DoctorRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
