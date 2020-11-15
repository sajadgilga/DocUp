import 'package:docup/models/MedicalTest.dart';
import 'package:docup/networking/ApiProvider.dart';

class MedicalTestRepository {
  ApiProvider _provider = ApiProvider();

  Future<MedicalTest> getTest(int id) async {
    final response = await _provider.get("medical-test/available-tests/$id",
        utf8Support: true);
    return MedicalTest.fromJson(response);
  }

  Future<MedicalTest> getPatientTestAndResponse(int id, int patientId) async {
    final response = await _provider.get(
        "medical-test/cognitive-tests-response?test_id=$id&patient_id=$patientId",
        utf8Support: true,
        body: {'test_id': id, "patient_id": patientId});
    return MedicalTest.fromJson(response);
  }

  Future<List<MedicalTestItem>> getAllTests() async {
    /// TODO amir: need to test
    final response =
        await _provider.get("medical-test/available-tests/", utf8Support: true);
    List<MedicalTestItem> res = [];
    (response['results'] as List).forEach((element) {
      res.add(MedicalTestItem.fromJson(element));
    });
    return res;
  }

  Future<List<MedicalTestItem>> getPanelMedicalTests(int panelId) async {
    /// TODO amir: need to test
    final response = await _provider.get(
        "medical-test/cognitive-tests-panel?panel_id=$panelId",
        utf8Support: true);
    List<MedicalTestItem> res = [];
    (response['results'] as List).forEach((element) {
      res.add(MedicalTestItem.fromJson(element));
    });
    return res;
  }

  Future<MedicalTestResponseEntity> addTestToPatient(
      int testId, int patientId) async {
    final response = await _provider.post(
        'medical-test/send-test-to-patient/?test_id=$testId&patient_id=$patientId');
    return MedicalTestResponseEntity.fromJson(response);
  }

  Future<List<MedicalTest>> getPanelTests() async {
    final response =
        await _provider.get("medical-test/cognitive-tests/", utf8Support: true);
    List<MedicalTest> res = [];
    (response as List).forEach((element) {
      res.add(MedicalTest.fromJson(element));
    });
    return res;
  }

  Future<MedicalTestResponseEntity> addPatientResponse(
      MedicalTestResponse testResponse) async {
    /// TODO amir: need to test
    String params = "";
    if (testResponse.panelId != null) {
      params = "?panel_id=${testResponse.panelId}";
    }
    final response = await _provider.post(
        "medical-test/cognitive-tests-add-response/" + params,
        utf8Support: true,
        body: testResponse.toJson());
    return MedicalTestResponseEntity.fromJson(response);
  }
}
