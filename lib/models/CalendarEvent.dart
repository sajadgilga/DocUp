import 'dart:ui';

import 'package:flutter/foundation.dart';

@immutable
class Event {
  Event({
    @required this.startMinuteOfDay,
    @required this.duration,
    @required this.title,
    @required this.color,
  });

  final int startMinuteOfDay;
  final int duration;

  final String title;

  final Color color;

}
