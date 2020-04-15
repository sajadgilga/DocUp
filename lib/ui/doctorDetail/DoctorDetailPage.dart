import 'dart:async';

import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/models/DoctorResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/DoctorAvatar.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/colors.dart';
import 'VirtualReservationPage.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  DoctorDetailPage({Key key, this.doctor}) : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  DoctorInfoBloc _bloc;
  Completer<GoogleMapController> _controller = Completer();
  LatLng defaultPinLocation = LatLng(35.715298, 51.404343);

  @override
  void initState() {
    _bloc = DoctorInfoBloc();
    _bloc.sendTicketStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('درخواست شما با موفقیت ثبت شد'),
          duration: Duration(seconds: 3),
        ));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bloc.getDoctor(widget.doctor.id);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _bloc.getDoctor(widget.doctor.id),
        child: StreamBuilder<Response<DoctorEntity>>(
          stream: _bloc.doctorInfoStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return APICallLoading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return Center(child: _doctorInfoWidget(snapshot.data.data));
                  break;
                case Status.ERROR:
                  return APICallError(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () => _bloc.getDoctor(widget.doctor.id),
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

  _doctorInfoWidget(DoctorEntity doctorEntity) => Column(
        children: <Widget>[
          SizedBox(height: 50),
          DoctorAvatar(doctorEntity: doctorEntity),
          SizedBox(height: 10),
          DoctorData(doctorEntity: doctorEntity),
          SizedBox(height: 20),
          _doctorMapWidget(doctorEntity),
          SizedBox(height: 20),
          _doctorActionsWidget(doctorEntity)
        ],
      );

  _doctorActionsWidget(DoctorEntity doctorEntity) => Column(
        children: <Widget>[
          ActionButton(
            width: 200,
            color: IColors.themeColor,
            title: Strings.physicalReservationLabel,
            callBack: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VirtualReservationPage(doctorEntity: doctorEntity)))
            },
          ),
          SizedBox(height: 10),
          ActionButton(
            width: 200,
            color: IColors.darkBlue,
            title: Strings.virtualReservationLabel,
            callBack: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VirtualReservationPage(doctorEntity: doctorEntity)))
            },
          ),
        ],
      );

  ClipRRect _doctorMapWidget(DoctorEntity doctorEntity) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 100,
        child: GoogleMap(
          onMapCreated: (controller) {
//            _controller.complete(controller);
          },
          initialCameraPosition: CameraPosition(
            target: doctorEntity.clinic.latitude != null &&
                    doctorEntity.clinic.longitude != null
                ? LatLng(
                    doctorEntity.clinic.latitude, doctorEntity.clinic.longitude)
                : defaultPinLocation,
            zoom: 12.0,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
