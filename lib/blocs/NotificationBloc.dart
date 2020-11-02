import 'package:bloc/bloc.dart';
import 'package:docup/models/NewestNotificationResponse.dart';
import 'package:docup/repository/NotificationRepository.dart';
import 'package:equatable/equatable.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationRepository _repository = NotificationRepository();

  @override
  get initialState => NotificationUnloaded();

  Stream<NotificationState> _get() async* {
    yield NotificationLoading(notifications: state.notifications);
    try {
      final NewestNotificationResponse notifications =
          await _repository.getNewestNotifications();
      yield NotificationsLoaded(notifications: notifications);
    } catch (e) {
      yield NotificationError(notifications: state.notifications);
    }
  }

  Stream<NotificationState> _addVisitNotification(NewestVisit visit) async* {
    NewestNotificationResponse notifications =
        state.notifications ?? NewestNotificationResponse();
    yield NotificationLoading(notifications: notifications);

    try {
    notifications.addOrUpdateNewVisitPushNotification(visit);
      yield NotificationsLoaded(notifications: notifications);
    } catch (e) {
      yield NotificationError(notifications: state.notifications);
    }
  }

  @override
  Stream<NotificationState> mapEventToState(event) async* {
    /// TODO amir: we just want notifications to be fetched from database just once.
    /// cleaning is necessary
    if (event is GetInitialNewestNotifications) {
      if (state.notifications == null) {
        yield* _get();
      }
    } else if (event is GetNewestNotifications) {
      yield* _get();
    } else if (event is AddNewestVisitNotification) {
      yield* _addVisitNotification(event.newVisit);
    }
  }
}

// events
abstract class NotificationEvent {
  final NewestVisit newVisit;

  NotificationEvent({this.newVisit});
}

class GetInitialNewestNotifications extends NotificationEvent {}

class GetNewestNotifications extends NotificationEvent {}

class AddNewestVisitNotification extends NotificationEvent {
  AddNewestVisitNotification({newVisit}) : super(newVisit: newVisit);
}

// states
abstract class NotificationState extends Equatable {
  final NewestNotificationResponse notifications;

  NotificationState({this.notifications});

  @override
  List<Object> get props => [notifications];
}

class NotificationUnloaded extends NotificationState {
  NotificationUnloaded({notifications}) : super(notifications: notifications);
}

class NotificationLoading extends NotificationState {
  NotificationLoading({notifications}) : super(notifications: notifications);
}

class NotificationsLoaded extends NotificationState {
  NotificationsLoaded({notifications}) : super(notifications: notifications);
}

class NotificationError extends NotificationState {
  NotificationError({notifications}) : super(notifications: notifications);
}
