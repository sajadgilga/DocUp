import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polygon_clipper/polygon_clipper.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DoctorDetailPage extends StatefulWidget {
  DoctorDetailPage({Key key}) : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        panel: Center(child: DoctorInfoWidget()),
        body: Center(
          child: Text("This is the Widget behind the sliding panel"),
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}

class DoctorInfoWidget extends StatelessWidget {
  const DoctorInfoWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SvgPicture.asset(
          "assets/down_arrow.svg",
          color: Colors.red,
          width: 24,
          height: 24,
        ),
        SizedBox(height: 30),
        Container(
          width: 100,
          child: ClipPolygon(
            sides: 6,
            rotate: 90,
            boxShadows: [
              PolygonBoxShadow(color: Colors.black, elevation: 1.0),
              PolygonBoxShadow(color: Colors.grey, elevation: 5.0)
            ],
            child: Image.asset("assets/lion.jpg"),
          ),
        ),
        SizedBox(height: 10),
        Text("دکتر یاسر عسکری سبزکوهی",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text("متخصص پوست",
            style: TextStyle(
              fontSize: 16,
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "متخصص و جراح پوست، مو و زیبایی",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(width: 10,),
            Icon(
              Icons.info_outline,
              color: Colors.black,
            )
          ],
        )
      ],
    );
  }
}
