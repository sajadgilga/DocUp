import 'dart:async';
import 'dart:typed_data';

import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;

  MapWidget({this.latitude, this.longitude});

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
        position: widget.latitude != null &&
            widget.longitude != null
            ? LatLng(
            widget.latitude,
            widget.longitude)
            : defaultPinLocation,
        icon: pinLocationIcon));

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
            target: widget.latitude != null &&
                widget.longitude != null
                ? LatLng(
                widget.latitude,
                widget.longitude)
                : defaultPinLocation,
            zoom: 12.0,
          ),
        ),
      ),
    );
  }


}