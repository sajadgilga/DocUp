import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/networking/CustomException.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/TextPlanRepository.dart';

class TextPlanBloc extends Bloc<TextPlanEvent, TextPlanState> {
  TextPlanRepository _repository;
  StreamController _buyTextPlanController;
  StreamController _activateAndDeactivatePatientTextPlan;

  StreamSink<Response<BuyTextPlanResponse>> get buyTextPlanSink =>
      _buyTextPlanController.sink;

  Stream<Response<BuyTextPlanResponse>> get buyTextPlanStream =>
      _buyTextPlanController.stream;

  StreamSink<Response<PatientTextPlan>> get togglePatientTextPlanSink =>
      _activateAndDeactivatePatientTextPlan.sink;

  Stream<Response<PatientTextPlan>> get togglePatientTextPlanStream =>
      _activateAndDeactivatePatientTextPlan.stream;

  @override
  get initialState => TextPlanLoading();

  TextPlanBloc() {
    _buyTextPlanController = StreamController<Response<BuyTextPlanResponse>>();
    _activateAndDeactivatePatientTextPlan =
        StreamController<Response<PatientTextPlan>>();
    _repository = TextPlanRepository();
  }

  void reNewStreams() {
    try {
      _buyTextPlanController.close();
    } finally {
      _buyTextPlanController =
          StreamController<Response<BuyTextPlanResponse>>();
    }

    try {
      _activateAndDeactivatePatientTextPlan.close();
    } finally {
      _activateAndDeactivatePatientTextPlan =
          StreamController<Response<PatientTextPlan>>();
    }
  }

  activateAndDeactivatePatientTextPlan(
      int patientTextPlan, int panelId, bool enable) async {
    togglePatientTextPlanSink.add(Response.loading());
    try {
      PatientTextPlan response = await _repository.toggleTextPlanChat(
          patientTextPlan, panelId, enable);
      togglePatientTextPlanSink.add(Response.completed(response));
    } catch (e) {
      togglePatientTextPlanSink.add(Response.error(e));
      print(e);
    }
  }

  textPlanActivation(int doctorId, int textPlanId) async {
    buyTextPlanSink.add(Response.loading());
    try {
      BuyTextPlanResponse response =
          await _repository.buyTextPlan(doctorId, textPlanId);
      if (!response.created && response.success) {
        throw ApiException(603, "");
      } else if (!response.success) {
        throw ApiException(604, "خطا");
      }
      buyTextPlanSink.add(Response.completed(response));
    } catch (e) {
      buyTextPlanSink.add(Response.error(e));
      print(e);
    }
  }

  Stream<TextPlanState> _getTextPlanIfExist(int partnerId) async* {
    yield TextPlanLoading();
    try {
      PatientTextPlan response = await _repository.getTextPlan(partnerId);

      yield TextPlanLoaded(response);
    } catch (e) {
      yield TextPlanError(error: e);
      print(e);
    }
  }

  dispose() {
    _buyTextPlanController?.close();
  }

  @override
  Stream<TextPlanState> mapEventToState(TextPlanEvent event) async* {
    if (event is GetPatientTextPlanEvent) {
      yield* _getTextPlanIfExist(event.partnerId);
    }
  }
}

class BuyTextPlanResponse {
  bool success;
  bool created;

  BuyTextPlanResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    created = json['created'] ?? false;
  }
}

/// event
abstract class TextPlanEvent {}

class GetPatientTextPlanEvent extends TextPlanEvent {
  int partnerId;

  GetPatientTextPlanEvent({this.partnerId});
}

///states
abstract class TextPlanState {
  TextPlanState();
}

class TextPlanLoading extends TextPlanState {
  final PatientTextPlan textPlanTraffic;

  TextPlanLoading({this.textPlanTraffic});
}

class TextPlanLoaded extends TextPlanState {
  final PatientTextPlan textPlan;

  TextPlanLoaded(this.textPlan);
}

class TextPlanError extends TextPlanState {
  final String error;

  TextPlanError({this.error});
}
