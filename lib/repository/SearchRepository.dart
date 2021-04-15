import 'package:Neuronio/models/SearchResult.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class SearchRepository {
  final ApiProvider _provider = ApiProvider();

  Future<SearchResult> searchDoctor(
      searchParam, int clinicId, String expertise) async {
    String urlParam = "?query=$searchParam";
    if (clinicId != null && clinicId != -1) {
      urlParam += "&clinic_id=$clinicId";
    }
    if (expertise != null && expertise != "" && expertise != "همه") {
      urlParam += "&expertise=$expertise";
    }
    final response = await _provider.get('api/search/doctors$urlParam');
    return SearchResult.fromJson(response, EntityType.DoctorEntity);
  }

  Future<SearchResult> searchMyDoctor() async {
    final response = await _provider.get('api/my-doctors');
    return SearchResult.fromJson(response, EntityType.DoctorEntity);
  }

  Future<SearchResult> searchPatient(searchParam, patientFilter) async {
    String urlParams = "?query=$searchParam";
    if (patientFilter != null &&
        patientFilter != "" &&
        patientFilter != "همه") {
      urlParams += "&filter=$patientFilter";
    }
    final response =
        await _provider.get('api/search/patients-list/' + urlParams);
    return SearchResult.fromJson(response, EntityType.PatientEntity);
  }

  Future<SearchResult> searchPatientVisits(
      String searchParam, int acceptStatus, int visitType) async {
    String urlParams = "?query=$searchParam";
    if (acceptStatus != null) {
      urlParams += "&status=$acceptStatus";
    }
    if (visitType != null) {
      urlParams += "&visit_type=$visitType";
    }
    final response = await _provider.get('api/visits/$urlParams');
    return SearchResult.fromJson(response, EntityType.VisitEntity);
  }

  Future<SearchResult> searchCount(param) async {
    final response = await _provider
        .get('api/search/patients-list?query=$param&status=0,1&page=0');
    return SearchResult.fromJson(response, EntityType.PatientEntity);
  }

  Future<SearchResult> searchClinics() async {
    var response = await _provider.get('api/search/clinics', utf8Support: true);
    return SearchResult.fromJson(response, EntityType.ClinicEntity);
  }
}
