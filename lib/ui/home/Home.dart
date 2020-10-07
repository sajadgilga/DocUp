import 'dart:ui';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/MedicineBloc.dart';
import 'package:docup/blocs/NotificationBloc.dart';
import 'package:docup/blocs/PatientTrackerBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/ui/widgets/TimeSelectorWidget.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:docup/ui/widgets/medicines/ReminderList.dart';
import 'package:docup/ui/home/SearchBox.dart';
import 'package:docup/ui/home/notification/Notification.dart';

import 'package:docup/ui/home/iPartner/IPartner.dart';
import 'package:docup/constants/strings.dart';
import 'package:flutter/services.dart';
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
  MedicineBloc _medicineBloc = MedicineBloc();

  @override
  void initState() {
//    _notificationBloc.add(GetNewestNotifications());
    _medicineBloc.add(MedicineGet());
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isDoctor)
      BlocProvider.of<PatientTrackerBloc>(context).add(TrackerGet());
    super.initState();
  }

  @override
  void didUpdateWidget(Home oldWidget) {
//    _notificationBloc.add(GetNewestNotifications());
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _medicineBloc.close();
    _notificationBloc.close();
    super.dispose();
  }

  Widget _intro(double width) => IgnorePointer(
          child: ListView(
        padding: EdgeInsets.only(right: width * .075),
        shrinkWrap: true,
        children: <Widget>[
          Text(
            Strings.docupIntroHomePart1,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            Strings.docupIntroHomePart2,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      ));

  Widget _reminderList() {
    return BlocBuilder<MedicineBloc, MedicineState>(
        bloc: _medicineBloc,
        builder: (context, state) {
          return ReminderList(
            medicines: state.medicines,
          );
        });
  }

  Widget _trackingList() {
    return BlocBuilder<PatientTrackerBloc, TrackerState>(
        builder: (context, state) {
      return Column(
        children: [
          DocUpSubHeader(title: "مراجعین من"),
          TrackingList(
            all: state.patientTracker.all,
            cured: state.patientTracker.cured,
            curing: state.patientTracker.curing,
            visitPending: state.patientTracker.visitPending,
            onPush: widget.onPush,
          ),
        ],
      );
    });
  }

  Widget _homeList() {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isPatient) {
      return _learningVideos();
    } else if (entity.isDoctor) {
      return _trackingList();
    }
  }

  Widget _noronioClinic() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: GestureDetector(
        onTap: () {
          /// TODO
          widget.selectPage(2);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(child: Image.asset(Assets.homeNoronioClinic)),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(),
                  child: Text("کلینیک نورونیو", style: TextStyle(fontSize: 17)),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: Text(
                    "پایش سلامت شناختی",
                    style: TextStyle(fontSize: 10),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _learningVideos() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: GestureDetector(
        onTap: () async {
          await launchURL(Strings.learningVideosLink);
        },
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Container(child: Image.asset(Assets.homeVideos)),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 40),
                  child:
                      Text("ویدیو های آموزشی", style: TextStyle(fontSize: 17)),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 100, bottom: 15),
                  child: Text(
                    "مراقبت از خود با آگاهی بیشتر",
                    style: TextStyle(fontSize: 10),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
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
        if (state is EntityLoading) {
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
        child: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            BlocBuilder<NotificationBloc, NotificationState>(
//                            bloc: _notificationBloc,
                builder: (context, state) {
              if (state.notifications != null &&
                  state.notifications.newestEventsCounts != null)
                return HomeNotification(
                    newNotificationCount:
                        state.notifications.newestEventsCounts);
              else
                return HomeNotification(
                  newNotificationCount: 0,
                );
            }),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                child: SearchBox(
                  onPush: widget.onPush,
                  isPatient: BlocProvider.of<EntityBloc>(context)
                      .state
                      .entity
                      .isPatient,
                  enableFlag: false,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    SystemChrome.setEnabledSystemUIOverlays(
                        [SystemUiOverlay.bottom]);
                    widget.onPush(NavigatorRoutes.partnerSearchView, null);
                  },
                ),
              ),
            ),
//                        OnCallMedicalHeaderIcon()
          ]),
          SizedBox(
            height: 25,
          ),
          _noronioClinic(),
          _homeList(),
          SizedBox(
            height: 15,
          ),
          _iPartner()
        ],
      ),
    ));
  }
}
