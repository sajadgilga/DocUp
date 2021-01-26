import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/networking/CustomException.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/TextPlanRepository.dart';

class TextPlanBloc extends Bloc<TextPlanEvent, TextPlanState> {
  TextPlanRepository _repository;
  StreamController _buyTextPlanController;

  StreamSink<Response<BuyTextPlanResponse>> get buyTextPlanSink =>
      _buyTextPlanController.sink;

  Stream<Response<BuyTextPlanResponse>> get buyTextPlanStream =>
      _buyTextPlanController.stream;

  @override
  get initialState => TextPlanLoading();

  TextPlanBloc() {
    _buyTextPlanController = StreamController<Response<BuyTextPlanResponse>>();

    _repository = TextPlanRepository();
  }

  void reNewStreams() {
    try {
      _buyTextPlanController.close();
    } finally {
      _buyTextPlanController =
          StreamController<Response<BuyTextPlanResponse>>();
    }
  }

  textPlanActivation(int doctorId, int textPlanId) async {
    buyTextPlanSink.add(Response.loading());
    try {
      BuyTextPlanResponse response =
          await _repository.buyPlan(doctorId, textPlanId);
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

  Stream<TextPlanState> _getPatientRemainedTextPlanTraffic(int panelId) async* {
    yield TextPlanLoading();
    try {
      TextPlanRemainedTraffic response =
          await _repository.loadTextPlanRemainedTraffic(panelId);

      yield TextPlanLoaded(response);
    } catch (e) {
      yield TextPlanError(error: e);
      print(e);
    }
  }

  Stream<TextPlanState> _getDoctorRemainedTextPlanTraffic(int panelId) async* {
    yield TextPlanLoading();
    try {
      TextPlanRemainedTraffic response =
          TextPlanRemainedTraffic(remainedWords: 9999999);

      /// as infinite traffic

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
    if (event is GetPatientTextPlanTrafficEvent) {
      yield* _getPatientRemainedTextPlanTraffic(event.panelId);
    } else if (event is GetDoctorTextPlanTrafficEvent) {
      yield* _getDoctorRemainedTextPlanTraffic(event.panelId);
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

class GetPatientTextPlanTrafficEvent extends TextPlanEvent {
  int panelId;

  GetPatientTextPlanTrafficEvent({this.panelId});
}

class GetDoctorTextPlanTrafficEvent extends TextPlanEvent {
  int panelId;

  GetDoctorTextPlanTrafficEvent({this.panelId});
}

///states
abstract class TextPlanState {
  TextPlanState();
}

class TextPlanLoading extends TextPlanState {
  final TextPlanRemainedTraffic textPlanTraffic;

  TextPlanLoading({this.textPlanTraffic});
}

class TextPlanLoaded extends TextPlanState {
  final TextPlanRemainedTraffic textPlan;

  TextPlanLoaded(this.textPlan);
}

class TextPlanError extends TextPlanState {
  final String error;

  TextPlanError({this.error});
}
