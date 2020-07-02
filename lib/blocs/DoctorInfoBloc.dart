import 'dart:async';

import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/DoctorPlan.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/DoctorRepository.dart';
import 'package:docup/repository/PatientRepository.dart';

class DoctorInfoBloc {
  DoctorRepository _repository;
  StreamController _getDoctorController;
  StreamController _visitRequestController;
  StreamController _getVisitController;
  StreamController _responseVisitController;
  StreamController _doctorUpdateController;

  StreamSink<Response<DoctorPlan>> get doctorPlanSink =>
      _doctorUpdateController.sink;

  StreamSink<Response<DoctorEntity>> get doctorInfoSink =>
      _getDoctorController.sink;

  StreamSink<Response<VisitEntity>> get visitRequestSink =>
      _visitRequestController.sink;

  StreamSink<Response<VisitEntity>> get getVisitSink =>
      _getVisitController.sink;

  StreamSink<Response<VisitEntity>> get responseVisitSink =>
      _responseVisitController.sink;

  Stream<Response<DoctorPlan>> get doctorPlanStream =>
      _doctorUpdateController.stream;

  Stream<Response<DoctorEntity>> get doctorInfoStream =>
      _getDoctorController.stream;

  Stream<Response<VisitEntity>> get visitRequestStream =>
      _visitRequestController.stream;

  Stream<Response<VisitEntity>> get getVisitStream =>
      _getVisitController.stream;

  Stream<Response<VisitEntity>> get responseVisitStream =>
      _responseVisitController.stream;

  DoctorInfoBloc() {
    _getDoctorController = StreamController<Response<DoctorEntity>>();
    _visitRequestController = StreamController<Response<VisitEntity>>();
    _getVisitController = StreamController<Response<VisitEntity>>();
    _responseVisitController = StreamController<Response<VisitEntity>>();
    _doctorUpdateController = StreamController<Response<DoctorPlan>>();
    _repository = DoctorRepository();
  }

  getDoctor(int doctorId) async {
    doctorInfoSink.add(Response.loading());
    try {
      DoctorEntity doctorEntity = await _repository.getDoctor(doctorId);
      doctorEntity.plan = await _repository.getDoctorPlan(doctorId);
      doctorInfoSink.add(Response.completed(doctorEntity));
    } catch (e) {
      doctorInfoSink.add(Response.error(e));
      print(e);
    }
  }

  updateDoctor(int doctorId, DoctorPlan plan) async {
    doctorPlanSink.add(Response.loading());
    try {
      plan.id = doctorId;
      DoctorPlan doctorPlan = await _repository.updatePlan(plan);
      doctorPlanSink.add(Response.completed(doctorPlan));
    } catch (e) {
      doctorPlanSink.add(Response.error(e));
      print(e);
    }
  }

  visitRequest(int doctorId, int visitType, int visitMethod, int durationPlan,
      String visitTime) async {
    visitRequestSink.add(Response.loading());
    try {
      VisitEntity response = await _repository.visitRequest(
          doctorId, visitType, visitMethod, durationPlan, visitTime);
      visitRequestSink.add(Response.completed(response));
    } catch (e) {
      visitRequestSink.add(Response.error(e));
      print(e);
    }
  }

  getVisit(int patientId) async {
    getVisitSink.add(Response.loading());
    try {
      VisitEntity response = await _repository.getVisitById(patientId);
      getVisitSink.add(Response.completed(response));
    } catch (e) {
      getVisitSink.add(Response.error(e));
      print(e);
    }
  }

  responseVisit(VisitEntity entity, bool status) async {
    responseVisitSink.add(Response.loading());
    try {
      VisitEntity response = await _repository.responseVisit(
          entity.id,
          VisitEntity(
              status: status ? 1 : 2,
              enabled: entity.enabled,
              visitTime: entity.visitTime),
          isVisitAcceptance: true);
      responseVisitSink.add(Response.completed(response));
    } catch (e) {
      responseVisitSink.add(Response.error(e));
      print(e);
    }
  }

  dispose() {
    _getDoctorController?.close();
    _visitRequestController?.close();
    _getVisitController?.close();
    _responseVisitController?.close();
    _doctorUpdateController?.close();
  }
}
