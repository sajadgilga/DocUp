import 'package:DocUp/models/AuthResponseEntity.dart';
import 'package:DocUp/models/DoctorEntity.dart';
import 'package:DocUp/models/DoctorPlan.dart';
import 'package:DocUp/models/ListResult.dart';
import 'package:DocUp/models/PatientTracker.dart';
import 'package:DocUp/models/VisitResponseEntity.dart';
import 'package:DocUp/networking/ApiProvider.dart';

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
        .get("api/visit-related/" + patientId.toString() + "/", utf8Support: true);
    return VisitEntity.fromJson(response);
  }

  Future<DoctorPlan> getDoctorPlan(int doctorId) async {
    final response = await _provider
        .get("api/doctor-plan/" + doctorId.toString());
    return DoctorPlan.fromJson(response);
  }


  Future<VisitEntity> responseVisit(
      int patientId, VisitEntity visitEntity, {isVisitAcceptance= false}) async {
    final response = await _provider.patch(
        "api/response-visit/" + patientId.toString() + "/",
        body: visitEntity.toJson(isAcceptance: isVisitAcceptance));
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

  Future<PatientTracker> getPatientTracker() async {
    final response = await _provider.get('api/patient-tracking/');
    return PatientTracker.fromJson(response);
  }

  Future<ListResult> getAllVisits() async {
    final response = await _provider.get("api/visits/", utf8Support: true);
    return ListResult.fromJson(response);
  }


}
