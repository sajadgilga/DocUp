//import 'package:Neuronio/models/UpdatePatientResponseEntity.dart';
import 'package:Neuronio/models/Medicine.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

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

  List<Medicine> _medicineList(List<dynamic> list) {
    List<Medicine> medicines = [];
    list.forEach((element) {
      medicines.add(Medicine.fromJson(element));
    });
    return medicines;
  }

  Future<List<Medicine>> getDrugs({doctorId, isWithDate, date}) async {
    String url = "api/drugs/";
    if (doctorId != null) url += '$doctorId/';
    final response = await _provider.get(url, utf8Support: true);
    return _medicineList(response['results']);
  }

  Future<dynamic> addDrug(Medicine medicine) async {
    final response = await _provider.post('api/drugs/', body: medicine.toJson());
    return Medicine.fromJson(response);
  }
}
