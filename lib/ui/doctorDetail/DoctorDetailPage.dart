import 'dart:async';

import 'package:docup/constants/strings.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:polygon_clipper/polygon_clipper.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../constants/colors.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;
  DoctorDetailPage({Key key, this.doctor}) : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        defaultPanelState: PanelState.OPEN,
        panel: Center(child: DoctorInfoWidget(doctor: widget.doctor,)),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}

class DoctorInfoWidget extends StatelessWidget {
  Completer<GoogleMapController> _controller = Completer();
  final Doctor doctor;

  DoctorInfoWidget({Key key, this.doctor}) : super(key: key);

  static const LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SvgPicture.asset(
          "assets/down_arrow.svg",
          color: IColors.red,
          width: 24,
          height: 24,
        ),
        SizedBox(height: 30),
        Container(
          width: 100,
          child: Hero(
              tag: 'doctorImage${doctor.name}',
              transitionOnUserGestures: true,
              child: ClipPolygon(
                sides: 6,
                rotate: 90,
                boxShadows: [
                  PolygonBoxShadow(color: Colors.black, elevation: 1.0),
                  PolygonBoxShadow(color: Colors.grey, elevation: 5.0)
                ],
                child: doctor.image,
              )),
        ),
        SizedBox(height: 10),
        Text("دکتر یاسر عسکری سبزکوهی",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text("متخصص پوست",
            style: TextStyle(
              fontSize: 16,
            )),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "متخصص و جراح پوست، مو و زیبایی",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(width: 20),
            Icon(
              Icons.info_outline,
              color: Colors.black,
            )
          ],
        ),
        SizedBox(height: 10,),
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: Container(
            width: 200,
            height: 150,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 5.0,
              ),
            ),
          ),
        ),

        SizedBox(height: 10,),
        ActionButton(
          color: IColors.red,
          title: Strings.requestAction,
          icon: Icon(
            Icons.send,
            size: 18.0,
          ),
          callBack: () {},
        )
      ],
    );
  }
}
