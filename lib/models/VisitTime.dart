enum Month { FAR, ORD, KHR, TIR, MRD, SHR, MHR, ABN, AZR, DAY, BAH, ESF }

extension MonthExtension on Month {
  get name {
    switch (this) {
      case Month.FAR:
        return 'فروردین';
      case Month.ORD:
        return 'اردیبهشت';
      case Month.KHR:
        return 'خرداد';
      case Month.TIR:
        return 'تیر';
      case Month.MRD:
        return 'مرداد';
      case Month.SHR:
        return 'شهریور';
      case Month.MHR:
        return 'مهر';
      case Month.ABN:
        return 'آبان';
      case Month.AZR:
        return 'آذر';
      case Month.DAY:
        return 'دی';
      case Month.BAH:
        return 'بهمن';
      case Month.ESF:
        return 'اسفند';
    }
  }
}

class VisitTime {
  final Month month;
  final String day;
  final String year;
  final bool isNear;

  VisitTime(this.month, this.day, this.year, this.isNear);
}
