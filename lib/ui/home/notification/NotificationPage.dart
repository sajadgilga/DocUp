import 'dart:async';

import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/NotificationBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/NewestNotificationResponse.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/repository/DoctorRepository.dart';
import 'package:Neuronio/repository/PatientRepository.dart';
import 'package:Neuronio/services/NotificationNavigationService.dart';
import 'package:Neuronio/ui/start/RoleType.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/customPainter/DrawerPainter.dart';
import 'package:Neuronio/utils/DateTimeService.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_shadow/icon_shadow.dart';

class NotificationPage extends StatefulWidget {
  final Function(String, dynamic, dynamic, dynamic, dynamic) onPush;

  const NotificationPage({Key key, this.onPush}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  initState() {
    BlocProvider.of<NotificationBloc>(context).add(GetNewestNotifications());
    super.initState();
  }

  Widget _notificationCountCircle(int count) => Positioned(
        right: 150,
        top: 110,
        child: Container(
            alignment: Alignment.centerRight,
            child: Wrap(children: <Widget>[
              Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: AutoText(replaceFarsiNumber("$count"),
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  decoration: BoxDecoration(
                      color: IColors.themeColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                            color: IColors.themeColor,
                            offset: Offset(1, 3),
                            blurRadius: 10)
                      ])),
            ])),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: IColors.background,
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return DocUpAPICallLoading2();
            } else if (state is NotificationsLoaded) {
              return _widget(context, state.notifications);
            } else {
              return APICallError(
                  () => BlocProvider.of<NotificationBloc>(context)
                      .add(GetNewestNotifications()),
                  errorMessage:
                      ((state is NotificationError) ? state.error : "") ?? "");
            }
          },
        ));
  }

  _widget(context, NewestNotificationResponse data) => Stack(
        children: <Widget>[
          Image(
            image: AssetImage('assets/backgroundHome.png'),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          ),
          CustomPaint(
              painter: DrawerPainter(arcStart: 20),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: 55,
                    top: 75,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 30,
                        )),
                  ),
                  Positioned(
                    right: 70,
                    top: 120,
                    child: AutoText(
                      "اعلانات",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  _notificationCountCircle(data.newestNotifsNotReadCounts),
                  _notificationsWidget(context, data),
                ],
              )),
          Container(
            width: 100,
            height: 90,
            child: Icon(
              Icons.notifications,
              size: 35,
              color: IColors.themeColor,
            ),
          ),
        ],
      );

  _notificationsWidget(buildContext, NewestNotificationResponse notifications) {
    return (notifications.newestNotifsTotalCounts) == 0
        ? Expanded(
            child: Positioned(
                right: MediaQuery.of(buildContext).size.width * 0.4,
                top: 180,
                child: AutoText("اعلانی موجود نیست")),
          )
        : Positioned(
            right: MediaQuery.of(buildContext).size.width * 0.15,
            top: 180,
            child: Container(
              width: MediaQuery.of(buildContext).size.width * 0.85,
              height: MediaQuery.of(buildContext).size.height * 0.7,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: notifications.newestNotifsTotalCounts,
                  itemBuilder: (BuildContext context, int index) {
                    NewestNotif newestNotif = notifications.newestNotifs[index];
                    return NotificationItem(
                      newestNotifs: newestNotif,
                      color: IColors.themeColor,
                      onPush: widget.onPush,
                    );
                    //   Dismissible(
                    //   key: Key(newestNotif.hashCode.toString()),
                    //
                    //   onDismissed: (item) {
                    //     BlocProvider.of<NotificationBloc>(context)
                    //         .add(AddNotifToSeen(newestNotif.notifId));
                    //   },
                    //   child: NotificationItem(
                    //     newestNotifs: newestNotif,
                    //     color: IColors.themeColor,
                    //     onPush: widget.onPush,
                    //   ),
                    // );
                  }),
            ),
          );
  }
}

class NotificationItem extends StatelessWidget {
  final NewestNotif newestNotifs;
  final String location;
  final Color color;
  final Function(String, dynamic, dynamic, dynamic, dynamic) onPush;

  const NotificationItem(
      {Key key, this.newestNotifs, this.location, this.color, this.onPush})
      : super(key: key);

  Future<UserEntity> getPartnerEntity(BuildContext context,
      {int doctorId, int patientId}) async {
    var state = BlocProvider.of<EntityBloc>(context).state;
    UserEntity uEntity;
    if (state.entity.type == RoleType.PATIENT) {
      uEntity = await DoctorRepository().getDoctor(doctorId);
    } else if (state.entity.type == RoleType.DOCTOR) {
      uEntity = await PatientRepository().getPatient(patientId);
    }
    return uEntity;
  }

  void onItemTap(NewestNotif notif, BuildContext context) {
    /// Set message to seen
    BlocProvider.of<NotificationBloc>(context)
        .add(AddNotifToSeen(notif.notifId));

    /// update notif counts in home page
    NotificationNavigationService notifNavRepo =
        NotificationNavigationService(onPush);
    notifNavRepo.navigate(context, notif);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onItemTap(newestNotifs, context);
      },
      child: Opacity(
        opacity: newestNotifs.isRead ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: IColors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16))),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: AutoText(
                      newestNotifs.notifTime == null
                          ? "هم اکنون"
                          : replaceFarsiNumber(DateTimeService.normalizeTime(
                                  newestNotifs.notifTime,
                                  cutSeconds: true)) +
                              " - " +
                              replaceFarsiNumber(DateTimeService
                                  .getJalaliStringFormGeorgianDateTimeString(
                                      newestNotifs.notifDate)),
                      textDirection: TextDirection.rtl,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: <Widget>[
                      IconShadowWidget(
                          Icon(
                            Icons.brightness_1,
                            size: 16,
                            color: color ?? IColors.black,
                          ),
                          showShadow: true,
                          shadowColor: color ?? IColors.black),
                      SizedBox(width: 5),
                      AutoText(
                        newestNotifs.title == null
                            ? "اعلان جدید"
                            : newestNotifs.title,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            color: color ?? IColors.black, fontSize: 14),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  AutoText(
                    newestNotifs.description == null
                        ? ""
                        : newestNotifs.description,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: IColors.darkGrey, fontSize: 12),
                  ),
                  SizedBox(height: 5),
                  Visibility(
                    visible: location != null,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Row(
                        children: <Widget>[
                          AutoText(
                            location != null ? location : "",
                            style: TextStyle(color: IColors.darkGrey),
                          ),
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: IColors.darkGrey,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
