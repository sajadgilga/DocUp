const VISIT_METHOD = "نوع مشاوره";
const VISIT_DURATION_PLAN = "مدت زمان مشاوره";
const String TIME_SELECTION = "انتخاب ساعت";

enum VisitMethod { TEXT, VOICE,  VIDEO}

extension VisitMethodExtension on VisitMethod {
  String get title {
    switch (this) {
      case VisitMethod.TEXT:
        return "متنی";
      case VisitMethod.VOICE:
        return "صوتی";
      case VisitMethod.VIDEO:
        return "تصویری";
      default:
        return "";
    }
  }
}

enum VisitDurationPlan { BASE, SUPPLEMENTARY, LONG }

extension VisitDurationPlanExtension on VisitDurationPlan {
  String get title {
    switch (this) {
      case VisitDurationPlan.BASE:
        return "پایه ۱۵ دقیقه";
      case VisitDurationPlan.SUPPLEMENTARY:
        return "تکمیلی ۳۰ دقیقه";
      case VisitDurationPlan.LONG:
        return "طولانی ۴۵ دقیقه";
      default:
        return "پایه ۱۵ دقیقه";
    }
  }

  int get duration {
    switch (this) {
      case VisitDurationPlan.BASE:
        return 30;
      case VisitDurationPlan.SUPPLEMENTARY:
        return 60;
      case VisitDurationPlan.LONG:
        return 90;
      default:
        return 30;
    }
  }
}
