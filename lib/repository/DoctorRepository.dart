import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/networking/ApiProvider.dart';

class DoctorRepository {
  ApiProvider _provider = ApiProvider();


  Future<DoctorEntity> get() async {
    final response = await _provider.get('api/auth/doctor/');
    return DoctorEntity.fromJson(response);
  }

  Future<DoctorEntity> update(DoctorEntity patient) async {
    final response = await _provider.patch("api/auth/doctor/",
        body: patient.toJson());
    return DoctorEntity.fromJson(response);
  }

  Future<DoctorEntity> getDoctor(int doctorId) async {
    final response = await _provider
        .get("api/doctors/" + doctorId.toString() + "/", utf8Support: true);
    return DoctorEntity.fromJson(response);
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
}
