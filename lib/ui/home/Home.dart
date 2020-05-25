import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/NotificationBloc.dart';
import 'package:docup/blocs/PatientTrackerBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/start/RoleType.dart';
import 'package:flutter/material.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:docup/ui/home/ReminderList.dart';
import 'package:docup/ui/home/SearchBox.dart';
import 'package:docup/ui/home/notification/Notification.dart';

import 'package:docup/ui/home/iPartner/IPartner.dart';
import 'package:docup/constants/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'TrackingList.dart';
import 'onCallMedical/OnCallMedicalHeaderIcon.dart';

class Home extends StatefulWidget {
  final Function(String, dynamic) onPush;
  final Function(int) selectPage;
  final Function(String, UserEntity) globalOnPush;

  Home({Key key, @required this.onPush, this.globalOnPush, this.selectPage})
      : super(key: key);

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
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isDoctor)
      BlocProvider.of<PatientTrackerBloc>(context).add(TrackerGet());
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _trackingList() {
    return BlocBuilder<PatientTrackerBloc, TrackerState>(
        builder: (context, state) {
      return TrackingList(
        all: state.patientTracker.all,
        cured: state.patientTracker.cured,
        curing: state.patientTracker.curing,
        visitPending: state.patientTracker.visitPending,
        onPush: widget.onPush,
      );
    });
  }

  Widget _homeList() {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isPatient) {
      return _reminderList();
    } else if (entity.isDoctor) {
      return _trackingList();
    }
  }

  Widget _homeListLabel() {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isPatient) {
      return Text(
        Strings.medicineReminder,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      );
    } else if (entity.isDoctor) {
      return Text(
        Strings.doctorTrackingLabel,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      );
    }
  }

  Widget _iPartner() {
    return BlocBuilder<EntityBloc, EntityState>(
      builder: (context, state) {
        if (state is EntityLoaded) {
          if (state.entity.partnerEntity != null) {
            return IPartner(
              selectPage: widget.selectPage,
              partner: state.entity.partnerEntity,
              onPush: widget.onPush,
              globalOnPush: widget.globalOnPush,
              color: IColors.themeColor,
              label: (state.entity.isPatient
                  ? Strings.iDoctorLabel
                  : Strings.iPatientLabel),
            );
          }
        }
        return IPartner(
          color: IColors.themeColor,
          label: (state.entity.isPatient
              ? Strings.iDoctorLabel
              : Strings.iPatientLabel),
          onPush: widget.onPush,
          isEmpty: true,
        );
      },
    );
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
                        widget.onPush(NavigatorRoutes.notificationView, null);
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
                height: 20,
              ),
              _intro(MediaQuery.of(context).size.width),
              Container(
                height: 20,
              ),
              SearchBox(
                onPush: widget.onPush,
                isPatient:
                    BlocProvider.of<EntityBloc>(context).state.entity.isPatient,
              ),
              SizedBox(
                height: 30,
              ),
              _homeListLabel(),
              SizedBox(height: 5),
              SizedBox(
                  width: 20,
                  height: 3,
                  child: Divider(
                    thickness: 2,
                    color: Colors.white,
                  )),
              _homeList(),
              _iPartner()
            ],
          ))
        ],
      ),
    );
  }
}
