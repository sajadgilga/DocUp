import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/ListResult.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/networking/ApiProvider.dart';

class DoctorRepository {
  ApiProvider _provider = ApiProvider();

  Future<DoctorEntity> get() async {
    final response = await _provider.get('api/auth/doctor/', utf8Support: true);
    return DoctorEntity.fromJson(response);
  }

  Future<DoctorEntity> update(DoctorEntity patient) async {
    final response =
        await _provider.patch("api/auth/doctor/", body: patient.toJson());
    return DoctorEntity.fromJson(response);
  }

  Future<DoctorEntity> getDoctor(int doctorId) async {
    final response = await _provider
        .get("api/doctors/" + doctorId.toString() + "/", utf8Support: true);
    return DoctorEntity.fromJson(response);
  }

  Future<VisitEntity> getVisit(int patientId) async {
    final response = await _provider
        .get("api/visits/" + patientId.toString() + "/", utf8Support: true);
    return VisitEntity.fromJson(response);
  }

  Future<VisitEntity> responseVisit(
      int patientId, VisitEntity visitEntity) async {
    final response = await _provider.patch(
        "api/response-visit/" + patientId.toString() + "/",
        body: visitEntity.toJson());
    return VisitEntity.fromJson(response);
  }

  Future<VisitEntity> visitRequest(int doctorId, int visitType, int visitMethod,
      int durationPlan, String visitTime) async {
    final response = await _provider.post("api/visits/", body: {
      "doctor": doctorId,
      "visit_type": visitType,
      "visit_method": visitMethod,
      "visit_duration_plan": durationPlan,
      "request_visit_time": visitTime
    });
    return VisitEntity.fromJson(response);
  }

  Future<ListResult> getAllVisits() async {
    final response = await _provider.get("api/visits/", utf8Support: true);
    return ListResult.fromJson(response);
  }
}
