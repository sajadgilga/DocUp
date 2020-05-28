import 'package:docup/models/AddTestEntity.dart';
import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/networking/ApiProvider.dart';
import 'package:docup/networking/Response.dart';

class MedicalTestRepository {
  ApiProvider _provider = ApiProvider();

  Future<MedicalTest> getTest(int id) async {
    final response = await _provider.get("medical-test/available-tests/$id",
        utf8Support: true);
    return MedicalTest.fromJson(response);
  }

  Future<AddTestEntity> addTestToPatient(int testId, int patientId) async {
    final response = await _provider.post('medical-test/send-test-to-patient/?test_id=$testId&patient_id=$patientId');
    return AddTestEntity.fromJson(response);
  }

}
