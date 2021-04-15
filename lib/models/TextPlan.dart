class PatientTextPlan {
  int id;
  String _createdDate;
  String _modifiedDate;
  bool enabled = false;
  String _requestVisitPlanTime;
  int _doctorId;
  int _patientId;
  int panelId;
  int _planId;

  PatientTextPlan({this.enabled = false});

  PatientTextPlan.fromJson(var json) {
    for (Map<String, dynamic> planJson in (json as List)) {
      if (planJson['enabled'] ?? false) {
        id = planJson['id'];
        _createdDate = planJson['created_date'];
        _modifiedDate = planJson['modified_date'];
        enabled = planJson['enabled'];
        _requestVisitPlanTime = planJson['request_visit_plan_time'];
        _doctorId = planJson['doctor'];
        _patientId = planJson['patient'];
        panelId = planJson['panel'];
        _planId = planJson['plan'];
        break;
      }
    }
  }
}
