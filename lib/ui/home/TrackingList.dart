import 'package:DocUp/constants/colors.dart';
import 'package:DocUp/constants/strings.dart';
import 'package:DocUp/models/UserEntity.dart';
import 'package:DocUp/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TrackingList extends StatelessWidget {
  final int all;
  final int cured;
  final int curing;
  final int visitPending;
  Function(String, UserEntity) onPush;
  Function(String, dynamic) onGlobalPush;

  TrackingList(
      {Key key,
      this.all,
      this.cured,
      this.curing,
      this.visitPending,
      this.onPush,
      this.onGlobalPush})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          height: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    onPush(NavigatorRoutes.requestsView, null);
                  },
                  child: TrackingBlock(
                    label: Strings.patientTrackingVisitPendingLabel,
                    percent: visitPending / all,
                    color: IColors.trackingVisitPending,
                    backgroundColor: Colors.white,
                    borderColor: IColors.trackingVisitPending,
                  )),
              TrackingBlock(
                label: Strings.patientTrackingCuringLabel,
                percent: curing / all,
                color: IColors.trackingCuring,
                backgroundColor: Colors.white,
                borderColor: IColors.trackingCuring,
              ),
              TrackingBlock(
                label: Strings.patientTrackingCuredLabel,
                percent: cured / all,
                color: IColors.trackingCured,
                backgroundColor: Colors.white,
                borderColor: Colors.white,
              )
            ],
          ),
        ));
  }
}

class TrackingBlock extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  final Color borderColor;
  final Color backgroundColor;

  TrackingBlock(
      {Key key,
      this.label,
      this.percent,
      this.color,
      this.borderColor,
      this.backgroundColor})
      : super(key: key);

  Widget _percentCircle() {
    return Container(
      child: CircularPercentIndicator(
        radius: 50,
        circularStrokeCap: CircularStrokeCap.round,
        reverse: true,
        progressColor: color,
        lineWidth: 7.0,
        animation: true,
        percent: percent,
        center: new Text(
          "${(percent * 100).ceil()}%",
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 9.0),
        ),
      ),
    );
  }

  Widget _label() => Container(
        margin: EdgeInsets.only(top: 5),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: color),
        ),
      );

  BoxDecoration _decoration() => BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      border: Border.all(color: borderColor, width: 3));

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 110, minWidth: 110, maxHeight: 110),
      decoration: _decoration(),
      margin: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 10),
      padding: EdgeInsets.only(bottom: 5, top: 5, left: 20, right: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_percentCircle(), _label()]),
    );
  }
}
