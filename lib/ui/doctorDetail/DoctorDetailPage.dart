import 'package:Neuronio/blocs/DoctorInfoBloc.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/Avatar.dart';
import 'package:Neuronio/ui/widgets/DoctorData.dart';
import 'package:Neuronio/ui/widgets/MapWidget.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class DoctorDetailPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final int screeningId;
  final Function(String, dynamic, Function(), int) onPush;

  DoctorDetailPage({Key key, this.doctorEntity, this.onPush, this.screeningId})
      : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  DoctorInfoBloc _bloc = DoctorInfoBloc();

  @override
  void initState() {
    _bloc.getDoctor(widget.doctorEntity.id, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _bloc.getDoctor(widget.doctorEntity.id, false),
        child: StreamBuilder<Response<DoctorEntity>>(
          stream: _bloc.doctorInfoStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return DocUpAPICallLoading2();
                  break;
                case Status.COMPLETED:
                  return Center(child: _doctorInfoWidget(snapshot.data.data));
                  break;
                case Status.ERROR:
                  return APICallError(
                    () => _bloc.getDoctor(widget.doctorEntity.id, false),
                    errorMessage: snapshot.data.error.toString(),
                  );
                  break;
              }
            }
            return DocUpAPICallLoading2();
          },
        ),
      ),
    );
  }

  _doctorInfoWidget(DoctorEntity doctorEntity) {
    return Column(
      children: <Widget>[
        SizedBox(height: 60),
        PolygonAvatar(user: doctorEntity.user),
        SizedBox(height: 10),
        DoctorData(
          width: MediaQuery.of(context).size.width,
          doctorEntity: doctorEntity,
          clinicMarkLocation: 2,
        ),
        SizedBox(height: 30),

        /// TODO
        !CrossPlatformDeviceDetection.isWeb
            ? MapWidget(
                clinic: doctorEntity.clinic,
              )
            : SizedBox(),
        SizedBox(height: 20),
        _doctorActionsWidget(doctorEntity)
      ],
    );
  }

  _doctorActionsWidget(DoctorEntity doctorEntity) => Column(
        children: <Widget>[
          ALittleVerticalSpace(
            height: 20,
          ),
          doctorEntity.plan.visitTypesNumber.contains(0)
              ? ActionButton(
                  width: 250,
                  height: 60,
                  borderRadius: 15,
                  color: IColors.themeColor,
                  title: Strings.physicalReservationLabel,
                  callBack: () => widget.onPush(
                      NavigatorRoutes.physicalVisitPage, doctorEntity, () {
                    _bloc.getDoctor(widget.doctorEntity.id, false);
                  }, widget.screeningId),
                )
              : SizedBox(),
          ALittleVerticalSpace(height: 10),
          doctorEntity.plan.visitTypesNumber.contains(1)
              ? ActionButton(
                  width: 250,
                  height: 60,
                  borderRadius: 15,
                  color: IColors.darkBlue,
                  title: Strings.virtualReservationLabel,
                  callBack: () => widget.onPush(
                      NavigatorRoutes.virtualVisitPage, doctorEntity, () {
                    _bloc.getDoctor(widget.doctorEntity.id, false);
                  }, widget.screeningId),
                )
              : SizedBox(),
          ALittleVerticalSpace(height: 10),
          // ActionButton(
          //   width: 250,
          //   height: 60,
          //   borderRadius: 15,
          //   color: IColors.themeColor,
          //   title: Strings.trafficPlanReservationLabel,
          //   callBack: () =>
          //       widget.onPush(NavigatorRoutes.textPlanPage, doctorEntity, () {
          //     _bloc.getDoctor(widget.doctorEntity.id, false);
          //   }, null),
          // )
        ],
      );

  @override
  void dispose() {
    try {
      _bloc.dispose();
    } catch (e) {}
    super.dispose();
  }
}
