import 'package:meta/meta.dart';

import 'package:docup/ui/widgets/modifiedPackages/calendar_views-0.5.2/lib/day_view.dart';

/// Recommendation for position of an item inside a [DayViewSchedule].
@immutable
class ItemPosition {
  const ItemPosition({
    @required this.top,
    @required this.left,
  })  : assert(top != null),
        assert(left != null);

  /// Position recommendation from top edge of [DayViewSchedule].
  final double top;

  /// Position recommendation from left edge of [DayViewSchedule].
  final double left;
}
