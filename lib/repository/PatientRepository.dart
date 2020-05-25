//import 'package:docup/models/UpdatePatientResponseEntity.dart';
import 'package:docup/models/Medicine.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/networking/ApiProvider.dart';

class PatientRepository {
  ApiProvider _provider = ApiProvider();

  Future<PatientEntity> update(PatientEntity patient) async {
    final response =
        await _provider.patch("api/auth/patient/", body: patient.toJson());
    return PatientEntity.fromJson(response);
  }

  Future<PatientEntity> get() async {
    final response = await _provider.get('api/auth/patient', utf8Support: true);
    return PatientEntity.fromJson(response);
  }

  Future<PatientEntity> getPatient(int patientId) async {
    final response = await _provider
        .get("api/patients/" + patientId.toString() + "/", utf8Support: true);
    return PatientEntity.fromJson(response);
  }

  List<Medicine> _medicineList(List<Map<String, dynamic>> list) {
    List<Medicine> medicines = [];
    list.forEach((element) {
      medicines.add(Medicine.fromJson(element));
    });
    return medicines;
  }

  Future<List<Medicine>> getDrugs({doctorId}) async {
    final response = await _provider.get("api/drugs/", utf8Support: true);
    return _medicineList(response['results']);
  }
}
