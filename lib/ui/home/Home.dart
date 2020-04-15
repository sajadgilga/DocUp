import 'package:docup/blocs/NotificationBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/models/Patient.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:docup/ui/home/ReminderList.dart';
import 'package:docup/ui/home/SearchBox.dart';
import 'package:docup/ui/home/notification/Notification.dart';

import 'package:docup/ui/home/iDoctor/IDoctor.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Doctor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'onCallMedical/OnCallMedicalHeaderIcon.dart';

class Home extends StatefulWidget {
  final ValueChanged<String> onPush;
  final ValueChanged<String> globalOnPush;

//  Patient patient;

  Home({Key key, @required this.onPush, this.globalOnPush}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
//  List<Doctor> iDoctors;
  NotificationBloc _notificationBloc = NotificationBloc();

  @override
  void initState() {
    _notificationBloc.add(GetNewestNotifications());
    super.initState();
  }

  Widget _intro(double width) => IgnorePointer(
          child: ListView(
        padding: EdgeInsets.only(right: width * .075),
        shrinkWrap: true,
        children: <Widget>[
          Text(
            Strings.docUpIntroHomePart1,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 22),
          ),
          Text(
            Strings.docUpIntroHomePart2,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      ));

  Widget _reminderList() {
    return BlocBuilder<NotificationBloc, NotificationState>(
        bloc: _notificationBloc,
        builder: (context, state) {
          if (state is NotificationsLoaded)
            return ReminderList(
              medicines: state.notifications.newestDrugs,
            );
          else
            return ReminderList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Image(
            image: AssetImage(Assets.homeBackground),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          ),
          Container(
              child: Column(
            children: <Widget>[
              Header(
                  child: GestureDetector(
                      onTap: () {
                        widget.onPush(NavigatorRoutes.notificationView);
                      },
                      child: Row(children: <Widget>[
                        BlocBuilder<NotificationBloc, NotificationState>(
                            bloc: _notificationBloc,
                            builder: (context, state) {
                              if (state is NotificationsLoaded)
                                return HomeNotification(
                                    newNotificationCount:
                                        state.notifications.newestEventsCounts);
                              else
                                return HomeNotification(
                                  newNotificationCount: 0,
                                );
                            }),
                        OnCallMedicalHeaderIcon()
                      ]))),
              Container(
                height: 10,
              ),
              _intro(MediaQuery.of(context).size.width),
              Container(
                height: 20,
              ),
              SearchBox(onPush: widget.onPush),
              SizedBox(
                height: 30,
              ),
              Text(
                Strings.medicineReminder,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(
                  width: 20,
                  height: 20,
                  child: Divider(
                    thickness: 2,
                    color: Colors.white,
                  )),
              SizedBox(
                height: 10,
              ),
              _reminderList(),
              IDoctor(
                doctor: Doctor(3, 'دکتر زهرا شادلو', 'متخصص پوست', 'اقدسیه',
                    Image(image: AssetImage(' ')), null),
                onPush: widget.onPush,
                globalOnPush: widget.globalOnPush,
              ),
            ],
          ))
        ],
      ),
    );
  }
}
