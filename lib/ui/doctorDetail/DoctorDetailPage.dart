import 'dart:async';
import 'dart:typed_data';

import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/ui/widgets/MapWidget.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/colors.dart';

class DoctorDetailPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final Function(String, dynamic) onPush;

  DoctorDetailPage({Key key, this.doctorEntity, this.onPush}) : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  DoctorInfoBloc _bloc;

  @override
  void initState() {
    _bloc = DoctorInfoBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bloc.getDoctor(widget.doctorEntity.id);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _bloc.getDoctor(widget.doctorEntity.id),
        child: StreamBuilder<Response<DoctorEntity>>(
          stream: _bloc.doctorInfoStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return APICallLoading();
                  break;
                case Status.COMPLETED:
                  return Center(child: _doctorInfoWidget(snapshot.data.data));
                  break;
                case Status.ERROR:
                  return APICallError(
                    errorMessage: snapshot.data.error.toString(),
                    onRetryPressed: () =>
                        _bloc.getDoctor(widget.doctorEntity.id),
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
    );
  }

  _doctorInfoWidget(DoctorEntity doctorEntity) {
    return Column(
      children: <Widget>[
        SizedBox(height: 50),
        Avatar(user: doctorEntity.user),
        SizedBox(height: 10),
        DoctorData(
            width: MediaQuery.of(context).size.width,
            doctorEntity: doctorEntity),
        SizedBox(height: 20),
        MapWidget(
          clinic: doctorEntity.clinic,
        ),
        SizedBox(height: 20),
        _doctorActionsWidget(doctorEntity)
      ],
    );
  }

  _doctorActionsWidget(DoctorEntity doctorEntity) => Column(
        children: <Widget>[
          ActionButton(
            width: 200,
            color: IColors.themeColor,
            title: Strings.physicalReservationLabel,
            callBack: () => widget.onPush(
                NavigatorRoutes.physicalVisitPage, doctorEntity),
          ),
          SizedBox(height: 10),
          ActionButton(
              width: 200,
              color: IColors.darkBlue,
              title: Strings.virtualReservationLabel,
              callBack: () => widget.onPush(
                  NavigatorRoutes.virtualVisitPage, doctorEntity)),
        ],
      );


  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
