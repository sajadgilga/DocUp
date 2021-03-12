import 'package:Neuronio/blocs/ICATestBloc.dart';
import 'package:Neuronio/models/MedicalTest.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class IcaTestRepository {
  ApiProvider _provider = ApiProvider();

  Future<ICATestScores> setScoreForScreeningICA(
      ICATestScores icaTestScores, int screeningStepId) async {
    final response = await _provider.post("api/ica/",
        body: {
          "screening_step": screeningStepId,
        }..addAll(icaTestScores.toJson()));
    return ICATestScores.fromJson(response);
  }

  Future<ICATestScores> getIcaTestScore(int screeningStepId) async {
    final response =
        await _provider.get("api/get-ica?screening_step_id=$screeningStepId");
    return ICATestScores.fromJson(response);
  }
}
