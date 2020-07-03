import 'dart:async';
import 'dart:typed_data';

import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final Clinic clinic;

  MapWidget({this.clinic});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  LatLng defaultPinLocation = LatLng(35.715298, 51.404343);

  void setCustomMapPin() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/location.png', 60);
    pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
  }

  @override
  Widget build(BuildContext context) {
    _markers.add(Marker(
        markerId: MarkerId("defaultMarker"),
        position: getPosition(),
        icon: pinLocationIcon));

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 100,
        child: GoogleMap(
          myLocationEnabled: true,
          markers: _markers,
          onMapCreated: (controller) {
            _controller.complete(controller);
          },
          initialCameraPosition: CameraPosition(
            target: getPosition(),
            zoom: 12.0,
          ),
        ),
      ),
    );
  }

  LatLng getPosition() {
    return widget.clinic != null &&
            widget.clinic.latitude != null &&
            widget.clinic.longitude != null
        ? LatLng(widget.clinic.latitude, widget.clinic.longitude)
        : defaultPinLocation;
  }
}
