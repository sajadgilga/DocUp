import 'dart:async';

import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/DoctorPlan.dart';
import 'package:Neuronio/models/VisitResponseEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/DoctorRepository.dart';
import 'package:Neuronio/ui/visit/VisitUtils.dart';

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

  getDoctor(int doctorId, bool currentUserInfo) async {
    /// TODO clean this method
    doctorInfoSink.add(Response.loading());
    try {
      DoctorEntity doctorEntity = await _repository.getDoctor(doctorId);
      if (currentUserInfo) {
        doctorEntity.plan = await _repository.getDoctorPlan();
      } else {
        doctorEntity.plan = await _repository.getDoctorPlanById(doctorId);
      }
      doctorInfoSink.add(Response.completed(doctorEntity));
    } catch (e) {
      doctorInfoSink.add(Response.error(e));
      print(e);
    }
  }

  updateDoctor(int doctorId, DoctorPlan plan) async {
    doctorPlanSink.add(Response.loading());
    try {
      // plan.id = doctorId;
      DoctorPlan doctorPlan = await _repository.updatePlan(plan);
      doctorPlanSink.add(Response.completed(doctorPlan));
    } catch (e) {
      doctorPlanSink.add(Response.error(e));
      print(e);
    }
  }

  visitRequest(int screeningId, int doctorId, int visitType, int visitMethod,
      int durationPlan, String visitTime, VisitSource source) async {
    visitRequestSink.add(Response.loading());
    try {
      VisitEntity response = await _repository.visitRequest(screeningId,
          doctorId, visitType, visitMethod, durationPlan, visitTime, source);
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
