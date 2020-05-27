import 'package:bloc/bloc.dart';
import 'package:DocUp/models/NewestNotificationResponse.dart';
import 'package:DocUp/repository/NotificationRepository.dart';
import 'package:equatable/equatable.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationRepository _repository = NotificationRepository();

  @override
  get initialState => NotificationUnloaded();

  Stream<NotificationState> _get() async* {
    yield NotificationLoading();
    try {
      final NewestNotificationResponse notifications =
          await _repository.getNewestNotifications();
      yield NotificationsLoaded(notifications: notifications);
    } catch (e) {
      yield NotificationError();
    }
  }

  @override
  Stream<NotificationState> mapEventToState(event) async* {
    if (event is GetNewestNotifications) {
      yield* _get();
    }
  }
}

// events
abstract class NotificationEvent {}

class GetNewestNotifications extends NotificationEvent {}

// states
abstract class NotificationState extends Equatable {
  NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationUnloaded extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final NewestNotificationResponse notifications;

  NotificationsLoaded({@override this.notifications});

  @override
  List<Object> get props => [notifications];
}

class NotificationError extends NotificationState {}
