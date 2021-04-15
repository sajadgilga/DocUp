import 'package:Neuronio/ui/widgets/modifiedPackages/calendar_views-0.5.2/lib/day_view.dart';
import 'package:flutter/material.dart';

/// Base class for a component whose built items will be displayed as children of [DayViewSchedule].
abstract class ScheduleComponent {
  const ScheduleComponent();

  /// Builds a list of [Positioned] widget that will be displayed as children of [DayViewSchedule].
  List<Positioned> buildItems(
    BuildContext context,
    DayViewProperties properties,
    SchedulePositioner positioner,
  );
}
