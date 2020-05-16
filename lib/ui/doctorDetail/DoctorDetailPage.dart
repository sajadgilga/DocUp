import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

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
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/colors.dart';
import 'VirtualReservationPage.dart';

class DoctorDetailPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final Function(String) onPush;

  DoctorDetailPage({Key key, this.doctorEntity, this.onPush}) : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  DoctorInfoBloc _bloc;

  BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  LatLng defaultPinLocation = LatLng(35.715298, 51.404343);

  @override
  void initState() {
    _bloc = DoctorInfoBloc();
    setCustomMapPin();
    super.initState();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void setCustomMapPin() async {
    final Uint8List markerIcon =
    await getBytesFromAsset('assets/location.png', 60);
    pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
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
                  return APICallLoading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return Center(child: _doctorInfoWidget(snapshot.data.data));
                  break;
                case Status.ERROR:
                  return APICallError(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () => _bloc.getDoctor(widget.doctorEntity.id),
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
    _markers.add(Marker(
        markerId: MarkerId("defaultMarker"),
        position: doctorEntity.clinic.latitude != null &&
            doctorEntity.clinic.longitude != null
            ? LatLng(
            doctorEntity.clinic.latitude, doctorEntity.clinic.longitude)
            : defaultPinLocation,
        icon: pinLocationIcon));
    return Column(
      children: <Widget>[
        SizedBox(height: 50),
        Avatar(user: doctorEntity.user),
        SizedBox(height: 10),
        DoctorData(
            width: MediaQuery
                .of(context)
                .size
                .width,
            doctorEntity: doctorEntity),
        SizedBox(height: 20),
        _doctorMapWidget(doctorEntity),
        SizedBox(height: 20),
        _doctorActionsWidget(doctorEntity)
      ],
    );
  }

  _doctorActionsWidget(DoctorEntity doctorEntity) =>
      Column(
        children: <Widget>[
          ActionButton(
            width: 200,
            color: IColors.themeColor,
            title: Strings.physicalReservationLabel,
            callBack: () => showNextVersionDialog(context),
          ),
          SizedBox(height: 10),
          ActionButton(
              width: 200,
              color: IColors.darkBlue,
              title: Strings.virtualReservationLabel,
              callBack: () => {
              widget.onPush(NavigatorRoutes.virtualReservation)
          }),
        ],
      );

  ClipRRect _doctorMapWidget(DoctorEntity doctorEntity) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.8,
        height: 100,
        child: GoogleMap(
          myLocationEnabled: true,
          markers: _markers,
          onMapCreated: (controller) {
            _controller.complete(controller);
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
