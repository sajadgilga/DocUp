import 'package:Neuronio/blocs/TextPlanBloc.dart';
import 'package:Neuronio/models/AuthResponseEntity.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/networking/ApiProvider.dart';

class TextPlanRepository {
  ApiProvider _provider = ApiProvider();

  Future<BuyTextPlanResponse> buyTextPlan(int doctorId, int textPlanId) async {
    final response = await _provider.post("api/text-plan-visit/",
        body: {"plan": textPlanId, "doctor": doctorId}, withToken: true);
    return BuyTextPlanResponse.fromJson(response);
  }

  Future<PatientTextPlan> getTextPlan(int partnerId) async {
    final response =
        await _provider.get("api/text-plan-visit?partner=$partnerId");
    return PatientTextPlan.fromJson(response);
  }

  Future<PatientTextPlan> toggleTextPlanChat(
      int patientTextPlan, int panelId, bool enable) async {
    final response = await _provider.patch(
        "api/deactive-or-active-chat/$panelId/",
        body: {"enabled": enable, 'visit_text_plan_id': patientTextPlan});
    return PatientTextPlan.fromJson([response]);
  }
}
