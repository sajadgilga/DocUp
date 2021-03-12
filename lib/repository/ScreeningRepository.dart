import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class ScreeningRepository {
  ApiProvider _provider = ApiProvider();

  Future<Screening> getClinicScreeningPlan(int clinicId) async {
    final response = await _provider.get('api/get-screening-plan/$clinicId/');
    return Screening.fromJson(response);
  }

  Future<PatientScreeningResponse> getPatientScreeningPlanIfExist(
      {int panelId}) async {
    String args = "";
    if (panelId != null) {
      args = "?panel_id=$panelId";
    }
    final response = await _provider.get('api/screening' + args);
    return PatientScreeningResponse.fromJson(response);
  }

  Future<ActivateScreeningPlanResponse> buyScreeningPlan(
      int screeningId, String discountString) async {
    // final response = await _provider.post('api/activate-screening-plan/',
    // body: {"screening_id": screeningId, "code": discountString});

    final response = await _provider.post('api/buy-screening-plan/',
        body: {"screening_id": screeningId, "code": discountString});
    return ActivateScreeningPlanResponse.fromJson(response);
  }

  Future<ActivateScreeningPlanResponse> setDoctorForScreeningPlan(
      int screeningId, int doctorId) async {
    final response = await _provider.post('api/set-doctor/',
        body: {"screening_step_id": screeningId, "doctor_id": doctorId});
    return ActivateScreeningPlanResponse.fromJson(response);
  }

  Future<ScreeningDiscountDetailResponse> validateDiscount(
      String discountString) async {
    final response =
        await _provider.get('api/get-discount/?code=$discountString');
    return ScreeningDiscountDetailResponse.fromJson(response);
  }

  Future doScreeningTestLifeQ(int testId, int screeningId) async {
    final response = await _provider.get(
        'medical-test/update-status?test_id=$testId&screening_step_id=$screeningId');
    return response;
  }
}
