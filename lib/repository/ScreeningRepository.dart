import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class ScreeningRepository {
  ApiProvider _provider = ApiProvider();

  Future<Screening> getClinicScreeningPlan(int clinicId) async {
    final response = await _provider.get('api/get-screening-plan/$clinicId/');
    return Screening.fromJson(response);
  }

  Future<PatientScreeningResponse> getPatientScreeningPlanIfExist() async {
    final response = await _provider.get('api/screening');
    return PatientScreeningResponse.fromJson(response);
  }

  Future<ScreeningDiscountDetailResponse> validateDiscount(String discountString) async {
    final response =
        await _provider.get('api/get-discount/?code=$discountString');
    return ScreeningDiscountDetailResponse.fromJson(response);
  }
}
