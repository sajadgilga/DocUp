import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/DoctorPlan.dart';
import 'package:Neuronio/models/ListResult.dart';
import 'package:Neuronio/models/PatientTracker.dart';
import 'package:Neuronio/models/VisitResponseEntity.dart';
import 'package:Neuronio/networking/ApiProvider.dart';
import 'package:Neuronio/ui/visit/VisitUtils.dart';

class DoctorRepository {
  ApiProvider _provider = ApiProvider();

  Future<DoctorEntity> get() async {
    final response = await _provider.get('api/auth/doctor/', utf8Support: true);
    return DoctorEntity.fromJson(response);
  }

  Future<DoctorEntity> update(DoctorEntity doctor) async {
    final response =
        await _provider.patch("api/auth/doctor/", body: doctor.toJson());
    return DoctorEntity.fromJson(response);
  }

  Future<DoctorEntity> getDoctor(int doctorId) async {
    final response = await _provider
        .get("api/doctors/" + doctorId.toString() + "/", utf8Support: true);
    return DoctorEntity.fromJson(response);
  }

  Future<VisitEntity> getVisit(int patientId) async {
    final response = await _provider.get(
        "api/visit-related/" + patientId.toString() + "/",
        utf8Support: true);
    return VisitEntity.fromJson(response);
  }

  Future<VisitEntity> getVisitById(int visitId) async {
    final response = await _provider
        .get("api/visits/" + visitId.toString() + "/", utf8Support: true);
    return VisitEntity.fromJson(response);
  }

  Future<DoctorPlan> getDoctorPlan() async {
    final response = await _provider.get("api/doctor-plan/");
    return DoctorPlan.fromJson(response);
  }

  Future<DoctorPlan> getDoctorPlanById(int doctorId) async {
    final response = await _provider.get("api/doctor-plan/$doctorId");
    return DoctorPlan.fromJson(response);
  }

  Future<DoctorPlan> updatePlan(DoctorPlan plan) async {
    final response =
        await _provider.patch("api/doctor-plan/", body: plan.toJson());
    return DoctorPlan.fromJson(response);
  }

  Future<VisitEntity> responseVisit(int patientId, VisitEntity visitEntity,
      {isVisitAcceptance = false}) async {
    final response = await _provider.patch(
        "api/response-visit/" + patientId.toString() + "/",
        body: visitEntity.toJson(isAcceptance: isVisitAcceptance));
    return VisitEntity.fromJson(response);
  }

  Future<VisitEntity> visitRequest(
      int screeningId,
      int doctorId,
      int visitType,
      int visitMethod,
      int durationPlan,
      String visitTime,
      VisitSource type) async {
    /// visit type : {physical virtual}
    /// type: {from_screening: 3 , game: 2, ica: 1 , ....}
    /// visit method: {text, voice, video}
    final response = await _provider.post("api/visits/",
        body: {
          "doctor": doctorId,
          "visit_type": visitType,
          "visit_method": visitMethod,
          "visit_duration_plan": durationPlan,
          "request_visit_time": visitTime,
          "screening_step_id": screeningId,
          'type': type.index
        },
        utf8Support: true);
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
