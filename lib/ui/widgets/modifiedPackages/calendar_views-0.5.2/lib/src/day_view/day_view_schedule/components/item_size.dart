import 'package:meta/meta.dart';

import 'package:docup/ui/widgets/modifiedPackages/calendar_views-0.5.2/lib/day_view.dart';

/// Recommendation for size of an item inside a [DayViewSchedule].
@immutable
class ItemSize {
  ItemSize({
    @required this.width,
    @required this.height,
  })  : assert(width != null && width >= 0),
        assert(height != null && height >= 0);

  /// Width recommendation for item.
  final double width;

  /// Height recommendation for item.
  final double height;
}
