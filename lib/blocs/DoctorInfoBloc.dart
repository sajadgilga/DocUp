import 'dart:async';

import 'package:docup/blocs/timer/TimerEvent.dart';
import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/models/DoctorResponseEntity.dart';
import 'package:docup/models/TicketResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/AuthRepository.dart';
import 'package:docup/repository/DoctorRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorInfoBloc {
  DoctorRepository _repository;
  StreamController _getDoctorController;
  StreamController _sendTicketController;

  StreamSink<Response<DoctorEntity>> get doctorInfoSink => _getDoctorController.sink;
  StreamSink<Response<TicketEntity>> get sendTicketSink => _sendTicketController.sink;

  Stream<Response<DoctorEntity>> get doctorInfoStream => _getDoctorController.stream;
  Stream<Response<TicketEntity>> get sendTicketStream => _sendTicketController.stream;

  DoctorInfoBloc() {
    _getDoctorController = StreamController<Response<DoctorEntity>>();
    _sendTicketController = StreamController<Response<TicketEntity>>();
    _repository = DoctorRepository();
  }

  getDoctor(int doctorId) async {
    doctorInfoSink.add(Response.loading(''));
    try {
      DoctorEntity response = await _repository.getDoctor(doctorId);
      doctorInfoSink.add(Response.completed(response));
    } catch (e) {
      doctorInfoSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  sendTicket(int doctorId) async {
    sendTicketSink.add(Response.loading(''));
    try {
      TicketEntity response = await _repository.sendTicket(doctorId);
      sendTicketSink.add(Response.completed(response));
    } catch (e) {
      sendTicketSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _getDoctorController?.close();
    _sendTicketController?.close();
  }
}
