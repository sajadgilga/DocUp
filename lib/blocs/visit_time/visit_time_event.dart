part of 'visit_time_bloc.dart';

@immutable
abstract class VisitTimeEvent {}

class VisitTimeGet extends VisitTimeEvent {
  int partnerId;

  VisitTimeGet({this.partnerId});
}
