import 'package:docup/models/UpdatePatientResponseEntity.dart';
import 'package:docup/networking/ApiProvider.dart';

class PatientRepository {
  ApiProvider _provider = ApiProvider();

  Future<Patient> update(Patient patient) async {
    final response = await _provider.patch("api/auth/patient/",
        body: patient.toJson());
    return Patient.fromJson(response);
  }

}