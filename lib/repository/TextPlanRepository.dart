import 'package:docup/blocs/visit_time/TextPlanBloc.dart';
import 'package:docup/models/AuthResponseEntity.dart';
import 'package:docup/models/TextPlan.dart';
import 'package:docup/networking/ApiProvider.dart';

class TextPlanRepository {
  ApiProvider _provider = ApiProvider();

  Future<BuyTextPlanResponse> buyPlan(int doctorId, int textPlanId) async {
    final response = await _provider.post("api/visit-plan/",
        body: {"plan": textPlanId, "doctor": doctorId}, withToken: true);
    return BuyTextPlanResponse.fromJson(response);
  }

  Future<TextPlanRemainedTraffic> loadTextPlanRemainedTraffic(int panelId)async{
    final response = await _provider.get("api/get-remained-words-in-plan/$panelId/");
    return TextPlanRemainedTraffic.fromJson(response);
  }
}
