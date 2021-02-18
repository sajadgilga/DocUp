import 'package:Neuronio/ui/widgets/modifiedPackages/calendar_views-0.5.2/lib/day_view.dart';

/// Base for a class that arranges events displayed by [EventViewComponent].
abstract class EventViewArranger {
  /// Arranges [events] while concerning [constraints] and returns a list of [ArrangedEvent]s.
  List<ArrangedEvent> arrangeEvents(
    Iterable<StartDurationItem> events,
    ArrangerConstraints constraints,
  );
}
