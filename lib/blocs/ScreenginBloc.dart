import 'dart:async';

import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/networking/CustomException.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/repository/ScreeningRepository.dart';
import 'package:bloc/bloc.dart';

class ScreeningBloc extends Bloc<ScreeningEvent, ScreeningState> {
  ScreeningRepository _repository = ScreeningRepository();


  /// buy and load clinic screening plan
  StreamController _screeningController =
      StreamController<Response<Screening>>();

  StreamSink<Response<Screening>> get apiSink => _screeningController.sink;

  Stream<Response<Screening>> get apiStream => _screeningController.stream;

  getClinicScreeningPlan(int clinicId) async {
    apiSink.add(Response.loading());
    try {
      Screening screening = await _repository.getClinicScreeningPlan(clinicId);
      apiSink.add(Response.completed(screening));
    } catch (e) {
      apiSink.add(Response.error(e));
      print(e);
    }
  }

  /// discount api
  StreamController<Response<ScreeningDiscountDetailResponse>>
      _discountController =
      StreamController<Response<ScreeningDiscountDetailResponse>>();

  StreamSink<Response<ScreeningDiscountDetailResponse>> get discountSink =>
      _discountController.sink;

  Stream<Response<ScreeningDiscountDetailResponse>> get discountStream =>
      _discountController.stream;

  validateScreeningDiscount(String discountString) async {
    discountSink.add(Response.loading());
    try {
      ScreeningDiscountDetailResponse discount =
          await _repository.validateDiscount(discountString);
      if (!discount.success) {
        throw Exception();
      }
      discountSink.add(Response.completed(discount));
    } catch (e) {
      discountSink.add(Response.error(e));
      print(e);
    }
  }

  /// discount buy api
  StreamController<Response<ActivateScreeningPlanResponse>>
      _buyScreeningController =
      StreamController<Response<ActivateScreeningPlanResponse>>();

  StreamSink<Response<ActivateScreeningPlanResponse>> get buySink =>
      _buyScreeningController.sink;

  Stream<Response<ActivateScreeningPlanResponse>> get buyStream =>
      _buyScreeningController.stream;

  requestActivateScreening(int screeningId, String discountString) async {
    buySink.add(Response.loading());
    try {
      ActivateScreeningPlanResponse response =
          await _repository.buyScreeningPlan(screeningId, discountString);
      if (!response.success) {
        throw ApiException(response.code, response.msg);
      }
      buySink.add(Response.completed(response));
    } catch (e) {
      buySink.add(Response.error(e));
      print(e);
    }
  }

  /// screening doctor selection api
  StreamController<Response<ActivateScreeningPlanResponse>>
      _screeningDoctorSelectionController =
      StreamController<Response<ActivateScreeningPlanResponse>>();

  StreamSink<Response<ActivateScreeningPlanResponse>> get doctorSelectionSink =>
      _screeningDoctorSelectionController.sink;

  Stream<Response<ActivateScreeningPlanResponse>> get doctorSelectionStream =>
      _screeningDoctorSelectionController.stream;

  requestToSetDoctorForScreeningPlan(int screeningId, int doctorId) async {
    doctorSelectionSink.add(Response.loading());
    try {
      ActivateScreeningPlanResponse response =
          await _repository.setDoctorForScreeningPlan(screeningId, doctorId);
      if (!response.success) {
        throw ApiException(response.code, response.msg);
      }
      doctorSelectionSink.add(Response.completed(response));
    } catch (e) {
      doctorSelectionSink.add(Response.error(e));
      print(e);
    }
  }

  /// renew
  void reNewStreams() {
    try {
      _screeningController.close();
    } finally {
      _screeningController = StreamController<Response<Screening>>();
    }

    try {
      _discountController.close();
    } finally {
      _discountController =
          StreamController<Response<ScreeningDiscountDetailResponse>>();
    }

    try {
      _buyScreeningController.close();
    } finally {
      _buyScreeningController =
          StreamController<Response<ActivateScreeningPlanResponse>>();
    }

    try {
      _screeningDoctorSelectionController.close();
    } finally {
      _screeningDoctorSelectionController =
          StreamController<Response<ActivateScreeningPlanResponse>>();
    }
  }

  /// patient screening plan
  @override
  get initialState => ScreeningLoading();

  Stream<ScreeningState> _getPatientScreeningPlan(
      GetPatientScreening event) async* {
    if (event.withLoading) {
      yield ScreeningLoading();
    } else {
      yield ScreeningLoading(result: this.state.result);
    }
    try {
      final PatientScreeningResponse patientScreening = await _repository
          .getPatientScreeningPlanIfExist(panelId: event.panelId);
      yield ScreeningLoaded(result: patientScreening);
    } catch (e) {
      yield ScreeningError();
    }
  }

  @override
  Stream<ScreeningState> mapEventToState(event) async* {
    if (event is GetPatientScreening) {
      yield* _getPatientScreeningPlan(event);
    }
  }
}

// events
abstract class ScreeningEvent {}

class GetPatientScreening extends ScreeningEvent {
  bool withLoading;
  int panelId;

  GetPatientScreening({this.withLoading = false, this.panelId});
}

// states
abstract class ScreeningState {
  PatientScreeningResponse result;

  ScreeningState({this.result});
}

class ScreeningError extends ScreeningState {
  ScreeningError({result}) : super(result: result);
}

class ScreeningLoaded extends ScreeningState {
  ScreeningLoaded({result}) : super(result: result);
}

class ScreeningLoading extends ScreeningState {
  ScreeningLoading({result}) : super(result: result);
}
