import 'package:Neuronio/ui/widgets/modifiedPackages/calendar_views-0.5.2/lib/day_view.dart';
import 'package:meta/meta.dart';

/// Item returned by [EventViewArranger].
///
/// It contains an [event] its position ([top], [left]) and size ([width], [height]).
@immutable
class ArrangedEvent {
  ArrangedEvent({
    @required this.top,
    @required this.left,
    @required this.width,
    @required this.height,
    @required this.event,
  })  : assert(top != null),
        assert(left != null),
        assert(width != null),
        assert(height != null),
        assert(event != null);

  final double top;

  final double left;

  final double width;

  final double height;

  final StartDurationItem event;
}
