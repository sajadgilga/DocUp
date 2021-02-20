const VISIT_METHOD = "نوع مشاوره";
const VISIT_DURATION_PLAN = "مدت زمان مشاوره";
const String TIME_SELECTION = "انتخاب ساعت";

enum VisitTypes { PHYSICAL, VIRTUAL }

extension VisitTypeExtension on VisitTypes {
  String get title {
    switch (this) {
      case VisitTypes.VIRTUAL:
        return "مجازی";
      case VisitTypes.PHYSICAL:
        return "حضوری";
      default:
        return "";
    }
  }
}

enum VirtualVisitMethod { TEXT, VOICE, VIDEO }

extension VisitMethodExtension on VirtualVisitMethod {
  String get title {
    switch (this) {
      case VirtualVisitMethod.TEXT:
        return "متنی";
      case VirtualVisitMethod.VOICE:
        return "صوتی";
      case VirtualVisitMethod.VIDEO:
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
        return 15;
      case VisitDurationPlan.SUPPLEMENTARY:
        return 30;
      case VisitDurationPlan.LONG:
        return 45;
      default:
        return 15;
    }
  }
}
