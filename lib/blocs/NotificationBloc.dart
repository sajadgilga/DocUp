import 'package:Neuronio/models/NewestNotificationResponse.dart';
import 'package:Neuronio/repository/NotificationRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationRepository _repository = NotificationRepository();

  @override
  get initialState => NotificationUnloaded();

  Stream<NotificationState> _get() async* {
    yield NotificationLoading(notifications: state.notifications);
    try {
      NewestNotificationResponse notifications =
          await _repository.getNewestNotifications();
      // notifications = await NewestNotificationResponse.removeSeenNotifications(
      //     notifications);

      yield NotificationsLoaded(notifications: notifications);
    } catch (e) {
      yield NotificationError(
          error: e.toString(), notifications: state.notifications);
    }
  }

  Stream<NotificationState> _addNotifToSeen(AddNotifToSeen event) async* {
    try {
      AddToSeenResponse addToSeenResponse =
          await _repository.addNotifToSeen(event.newestNotifId);
      if (addToSeenResponse.success) {
        state.notifications.updateNotifIsRead(event.newestNotifId);
        NewestNotificationResponse newestNotificationResponse =
            state.notifications.getCopy();
        yield NotificationsLoaded(notifications: newestNotificationResponse);
      } else {
        throw Exception("Add_To_Seen method were not successful");
      }
    } catch (e) {
      print(e.toString());
      yield NotificationError(
          error: e.toString(), notifications: state.notifications);
    }
  }

  // Stream<NotificationState> _addVisitNotification(NewestVisit visit) async* {
  //   NewestNotificationResponse notifications =
  //       state.notifications ?? NewestNotificationResponse();
  //   yield NotificationLoading(notifications: notifications);
  //
  //   try {
  //     notifications.addOrUpdateNewVisitPushNotification(visit);
  //     notifications = await NewestNotificationResponse.removeSeenNotifications(
  //         notifications);
  //
  //     yield NotificationsLoaded(notifications: notifications);
  //   } catch (e) {
  //     yield NotificationError(notifications: state.notifications);
  //   }
  // }

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
    } else if (event is AddNotifToSeen) {
      yield* _addNotifToSeen(event);
    }
    // else if (event is AddNewestVisitNotification) {
    //   yield* _addVisitNotification(event.newVisit);
    // }
  }
}

// events
abstract class NotificationEvent {
  final NewestVisitNotif newVisit;

  NotificationEvent({this.newVisit});
}

class GetInitialNewestNotifications extends NotificationEvent {}

class GetNewestNotifications extends NotificationEvent {}

class AddNotifToSeen extends NotificationEvent {
  int newestNotifId;

  AddNotifToSeen(this.newestNotifId);
}
// class AddNewestVisitNotification extends NotificationEvent {
//   AddNewestVisitNotification({newVisit}) : super(newVisit: newVisit);
// }

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
  String error;

  NotificationError({this.error, notifications})
      : super(notifications: notifications);
}

class AddToSeenResponse {
  bool success;

  AddToSeenResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
  }
}
