part of 'visit_time_bloc.dart';

@immutable
abstract class VisitTimeState {}

class EmptyVisitTimeState extends VisitTimeState {}

class VisitTimeLoadedState extends VisitTimeState {
  VisitEntity visit;

  VisitTimeLoadedState({this.visit});
}

class VisitTimeErrorState extends VisitTimeState {}
