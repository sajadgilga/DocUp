import 'package:docup/blocs/NotificationBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/NewestNotificationResponse.dart';
import 'package:docup/ui/customPainter/DrawerPainter.dart';
import 'package:docup/utils/UiUtils.dart';

//import 'package:docup/ui/home/notification/DrawerPainter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_shadow/icon_shadow.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationBloc _notificationBloc = NotificationBloc();

  @override
  void initState() {
    _notificationBloc.add(GetNewestNotifications());
    super.initState();
  }

  Widget _notificationCountCircle(int count) {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.55,
      top: MediaQuery.of(context).size.height * 0.29,
      child: Container(
          alignment: Alignment.centerRight,
          child: Wrap(children: <Widget>[
            Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Text(replaceFarsiNumber("$count"),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.background,
      body: Stack(
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
                    left: MediaQuery.of(context).size.width * 0.6,
                    top: MediaQuery.of(context).size.height * 0.3,
                    child: Text(
                      "اعلانات",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, state) {
                    if (state is NotificationsLoaded) {
                      return _notificationCountCircle(
                          state.notifications.newestDrugsCounts +
                              state.notifications.newestEventsCounts);
                    } else
                      return _notificationCountCircle(0);
                  }),
                  BlocBuilder<NotificationBloc, NotificationState>(
                      bloc: _notificationBloc,
                      builder: (context, state) {
                        if (state is NotificationsLoaded) {
                          return _notificationsWidget(
                              context, state.notifications);
                        } else
                          return Container();
                      }),
                ],
              )),
          Container(
            width: 100,
            height: 120,
            child: Icon(
              Icons.notifications,
              size: 35,
              color: IColors.themeColor,
            ),
          ),
        ],
      ),
    );
  }
}

_notificationsWidget(context, NewestNotificationResponse notifications) {
  Column column = Column();
  for (var event in notifications.newestEvents) {
    column.children.add(NotificationItem(
      time: event.time,
      title: event.title,
      description: event.description,
    ));
    for (var drug in notifications.newestDrugs) {
      column.children.add(NotificationItem(
        time: drug.consumingTime,
        title: drug.drugName,
      ));
    }
    return Positioned(
      right: MediaQuery.of(context).size.width * 0.15,
      top: MediaQuery.of(context).size.height * 0.4,
      child: column,
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String time;
  final String title;
  final String description;
  final String location;

  const NotificationItem(
      {Key key, this.time, this.title, this.description, this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Material(
          color: IColors.grey,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text(
                    time == null ? "هم اکنون" : time,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                          color: IColors.themeColor,
                        ),
                        showShadow: true,
                        shadowColor: IColors.themeColor),
                    SizedBox(width: 5),
                    Text(
                      title == null ? "اعلان جدید" : title,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: IColors.themeColor, fontSize: 16),
                    ),
                    SizedBox(width: 10),
                    Text(
                      description == null ? "" : description,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: IColors.darkGrey),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "اقدسیه",
                        style: TextStyle(color: IColors.darkGrey),
                      ),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: IColors.darkGrey,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
