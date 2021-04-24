import 'dart:convert';

import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/PanelSectionBloc.dart';
import 'package:Neuronio/blocs/TextPlanBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/Avatar.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyPartnerDialog extends StatefulWidget {
  final Function(String, UserEntity, PatientTextPlan, int, Function()) onPush;
  final UserEntity partner;

  MyPartnerDialog({@required this.onPush, @required this.partner});

  @override
  _MyPartnerDialogState createState() => _MyPartnerDialogState();
}

class _MyPartnerDialogState extends State<MyPartnerDialog> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    initialApiCall();
    super.initState();
  }

  void initialApiCall() {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    TextPlanBloc _textPlanBloc = BlocProvider.of<TextPlanBloc>(context);

    if (entity.isDoctor) {
      // var panel = entity.mEntity.getPanelByPatientId(widget.partner.id);
      _textPlanBloc.add(GetPatientTextPlanEvent(partnerId: widget.partner.id));
    } else {
      // var panel = entity.mEntity.getPanelByDoctorId(widget.partner.id);
      _textPlanBloc.add(GetPatientTextPlanEvent(partnerId: widget.partner.id));
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }

  Widget _image(context) {
    return Container(
        child: Container(
            width: 70,
            child: PolygonAvatar(
              user: widget.partner.user,
            )));
  }

  Widget _nameAndExpertise(context) {
    String utfName;
    try {
      utfName = utf8.decode(widget.partner.user.name.toString().codeUnits);
    } catch (_) {
      utfName = widget.partner.user.name;
    }
    return Container(
      padding: EdgeInsets.only(right: 15),
      child: AutoText(
        utfName,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _info(context) {
    return Expanded(
      flex: 2,
      child: Container(
          margin: EdgeInsets.only(right: 10, left: 15),
          child: _nameAndExpertise(context)),
    );
  }

  Widget _partnerDetail(context) {
    return Padding(
      padding: EdgeInsets.only(top: 30, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[_info(context), _image(context)],
      ),
    );
  }

  Widget _myPartnerItem(Function() onTap, String iconAddress, String header,
      String subHeader, Color headerColor) {
    double iconSize = 43;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: GestureDetector(
        child: Container(
          height: 90,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey, blurRadius: 10, spreadRadius: -1)
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        child: AutoText(
                          header,
                          textDirection: TextDirection.rtl,
                          overflow: TextOverflow.fade,
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 13.5,
                              color: headerColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: AutoText(
                              subHeader,
                              textDirection: TextDirection.rtl,
                              overflow: TextOverflow.fade,
                              softWrap: true,
                              style: TextStyle(
                                  fontSize: 12, color: IColors.darkGrey),
                            )),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: iconSize,
                  child: Image.asset(iconAddress, width: iconSize),
                ),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return BlocBuilder<TextPlanBloc, TextPlanState>(builder: (context, state) {
      if (state is TextPlanLoaded) {
        return _chatWidget(state.textPlan);
      } else if (state is TextPlanError) {
        return APICallError(
          () => initialApiCall(),
          errorMessage: state.error,
        );
      }
      return DocUpAPICallLoading2();
    });
  }

  Widget _chatWidget(PatientTextPlan textPlanRemainedTraffic) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            PageTopLeftIcon(
              topLeft: Icon(
                Icons.arrow_back,
                color: IColors.themeColor,
                size: 20,
              ),
              topLeftFlag: CrossPlatformDeviceDetection.isIOS,
              topRight: Container(
                  child: Image.asset(Assets.logoTransparent, width: 50)),
              topRightFlag: false,
              onTap: () {
                widget.onPush(NavigatorRoutes.root, null, null, null, null);
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: menuLabel("(کلینیک نورونیو)",
                        fontSize: 12, divider: false),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: menuLabel("پنل کاربری"),
                  ),
                ],
              ),
            ),
            _partnerDetail(context),
            SizedBox(
              height: 35,
            ),
            (widget.partner is DoctorEntity)
                ? _myDoctorItems(context, textPlanRemainedTraffic)
                : SizedBox(),
            (widget.partner is PatientEntity)
                ? _myPatientItems(context, textPlanRemainedTraffic)
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _myDoctorItems(context, PatientTextPlan textPlanRemainedTraffic) {
    return Column(
      children: [
        _myPartnerItem(() {
          /// navigation
          BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
              patientSection: PatientPanelSection.DOCTOR_INTERFACE));
          widget.onPush(NavigatorRoutes.panel, widget.partner,
              textPlanRemainedTraffic, null, () => initialApiCall());

          /// #
        }, Assets.panelDoctorDialogDoctorIcon, "ویزیت پزشک",
            "ویزیت مجازی با پزشک خود را دنبال کنید", IColors.blue),
        _myPartnerItem(() {
          /// navigation
          BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
              patientSection: PatientPanelSection.HEALTH_FILE));
          widget.onPush(NavigatorRoutes.panel, widget.partner,
              textPlanRemainedTraffic, null, () => initialApiCall());

          /// #
        }, Assets.panelDoctorDialogPatientIcon, "پرونده سلامت",
            "پرونده سلامت اتان را بررسی کنید", IColors.green),

        /// TODO amir: incomplete widget tree
        // Settings.bazaarBuild
        //     ? SizedBox()
        //     :
        _myPartnerItem(() {
          /// navigation

          BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
              patientSection: PatientPanelSection.HEALTH_CALENDAR));
          widget.onPush(NavigatorRoutes.panel, widget.partner,
              textPlanRemainedTraffic, null, () => initialApiCall());

          /// #
        }, Assets.panelDoctorDialogAppointmentIcon, "رویداد های سلامت",
            "رویداد های سلامت اتان را پیگیری کنید", IColors.black),
      ],
    );
  }

  Widget _myPatientItems(context, PatientTextPlan textPlanRemainedTraffic) {
    return Column(
      children: [
        _myPartnerItem(() {
          /// navigation

          BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
              patientSection: PatientPanelSection.DOCTOR_INTERFACE));
          widget.onPush(NavigatorRoutes.panel, widget.partner,
              textPlanRemainedTraffic, null, () => initialApiCall());

          /// #
        }, Assets.panelDoctorDialogDoctorIcon, "ویزیت بیمار",
            "ویزیت مجازی و حضوری بیمار", IColors.themeColor),
        _myPartnerItem(() {
          /// navigation

          BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
              patientSection: PatientPanelSection.HEALTH_FILE));
          widget.onPush(NavigatorRoutes.panel, widget.partner,
              textPlanRemainedTraffic, null, () => initialApiCall());

          /// #
        }, Assets.panelDoctorDialogPatientIcon, "پرونده سلامت",
            "پرونده سلامتتان را بررسی کنید", IColors.black),

        /// TODO amir: incomplete widget tree for bazaar

        // Settings.bazaarBuild
        //     ? SizedBox()
        //     :
        _myPartnerItem(() {
          /// navigation

          BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
              patientSection: PatientPanelSection.HEALTH_CALENDAR));
          widget.onPush(NavigatorRoutes.panel, widget.partner,
              textPlanRemainedTraffic, null, () => initialApiCall());

          /// #
        }, Assets.panelDoctorDialogAppointmentIcon, "رویداد های سلامت",
            "رویداد های سلامت اتان را پیگیری کنید", IColors.red),

        _myPartnerItem(() {
          /// navigation
          BlocProvider.of<PanelSectionBloc>(context).add(PanelSectionSelect(
              patientSection: PatientPanelSection.HEALTH_FILE));
          var _state = BlocProvider.of<EntityBloc>(context).state;
          widget.onPush(
              NavigatorRoutes.patientScreening,
              widget.partner,
              null,
              _state.entity.mEntity.getPanelByPatientId(widget.partner.id).id,
              null);

          /// #
        }, Assets.panelDoctorDialogPatientIcon, "پلن غربالگری بیمار",
            "بررسی پلن غربالگری و مشاهده تایم لاین بیمار", IColors.green),
      ],
    );
  }
}
