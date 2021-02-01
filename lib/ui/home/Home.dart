import 'dart:ui';

import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/MedicineBloc.dart';
import 'package:Neuronio/blocs/NotificationBloc.dart';
import 'package:Neuronio/blocs/PatientTrackerBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/home/SearchBox.dart';
import 'package:Neuronio/ui/home/iPartner/IPartner.dart';
import 'package:Neuronio/ui/home/notification/Notification.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'TrackingList.dart';

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
  MedicineBloc _medicineBloc = MedicineBloc();

  @override
  void initState() {
    _medicineBloc.add(MedicineGet());
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isDoctor)
      BlocProvider.of<PatientTrackerBloc>(context).add(TrackerGet());
    super.initState();
  }

  @override
  void didUpdateWidget(Home oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    try {
      _medicineBloc.close();
    } catch (e) {}
    super.dispose();
  }

  Widget _intro(double width) => IgnorePointer(
          child: ListView(
        padding: EdgeInsets.only(right: width * .075),
        shrinkWrap: true,
        children: <Widget>[
          AutoText(
            Strings.docupIntroHomePart1,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          AutoText(
            Strings.docupIntroHomePart2,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      ));

  // Widget _reminderList() {
  //   return BlocBuilder <MedicineBloc, MedicineState>(
  //       bloc: _medicineBloc,
  //       builder: (context, state) {
  //         return ReminderList(
  //           medicines: state.medicines,
  //         );
  //       });
  // }

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
      return Column(
        children: [
          _neuronioScreening(),
          _learningVideos(),
        ],
      );
    } else if (entity.isDoctor) {
      return Column(
        children: [
          _neuronioClinic(),
          _trackingList(),
        ],
      );
    }
  }

  Widget _neuronioClinic() {
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
                  child: AutoText("کلینیک نورونیو",
                      style: TextStyle(fontSize: 17)),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: AutoText(
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

  Widget _neuronioScreening() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: GestureDetector(
        onTap: () {
          /// TODO
          widget.selectPage(1);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(child: Image.asset(Assets.homeNoronioClinic)),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(),
                  child: AutoText("سنجش بیمار", style: TextStyle(fontSize: 17)),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 40),
                  child: AutoText(
                    "پایش سلامت شناختی" + "\n" + "غربالگری",
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
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.10,
                  ),
                  child: AutoText("ویدیو های آموزشی",
                      style: TextStyle(fontSize: 17)),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.20,
                      bottom: 15),
                  child: AutoText(
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
      return AutoText(
        Strings.medicineReminder,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      );
    } else if (entity.isDoctor) {
      return AutoText(
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
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
              return HomeNotification(
                  onPush: widget.onPush,
                  newNotificationCount:
                      state.notifications?.newestNotifsCounts ?? 0);
            }),
            BlocProvider.of<EntityBloc>(context).state.entity.isDoctor
                ? Expanded(
                    child: Container(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 15),
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
                            widget.onPush(
                                NavigatorRoutes.partnerSearchView, null);
                          },
                        ),
                      ),
                    ),
                  )
                : Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        DocUpHeader(
                          docUpLogo: true,
                        ),
                      ],
                    ),
                ),
//                        OnCallMedicalHeaderIcon()
          ]),
          SizedBox(
            height: 25,
          ),
          _homeList(),
          SizedBox(
            height: 15,
          ),
          _iPartner()
        ],
      )),
    );
  }
}
