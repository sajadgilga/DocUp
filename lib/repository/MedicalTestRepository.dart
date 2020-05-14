import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/networking/ApiProvider.dart';

class MedicalTestRepository {
  ApiProvider _provider = ApiProvider();

  Future<MedicalTest> getTest(int id) async {
    final response = await _provider.get("medical-test/available-tests/$id",
        utf8Support: true);
    return MedicalTest.fromJson(response);
  }
}
