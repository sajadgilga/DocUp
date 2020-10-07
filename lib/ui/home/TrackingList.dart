import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                    onPush(NavigatorRoutes.visitRequestList, null);
                  },
                  child: TrackingBlock(
                    label: Strings.patientTrackingRequestVisitLabel,
                    value: visitPending,
                    color: IColors.trackingVisitPending,
                    backgroundColor: Colors.white,
                    borderColor: Colors.white,
                    iconsAssetAddress: Assets.homeVisitRequest,
                  )),
              GestureDetector(
                onTap: () {
                  onPush(NavigatorRoutes.virtualVisitList, null);
                },
                child: TrackingBlock(
                  label: Strings.patientTrackingVirtualVisitLabel,
                  value: curing,
                  color: IColors.virtualVisit,
                  backgroundColor: Colors.white,
                  borderColor: Colors.white,
                  iconsAssetAddress: Assets.homeVirtualVisit,
                ),
              ),
              GestureDetector(
                onTap: () {
                  onPush(NavigatorRoutes.physicalVisitList, null);
                },
                child: TrackingBlock(
                  label: Strings.patientTrackingVisitFaceToFaceLabel,
                  value: cured,
                  color: IColors.physicalVisit,
                  backgroundColor: Colors.white,
                  borderColor: Colors.white,
                  iconsAssetAddress: Assets.homePresentVisit,
                ),
              )
            ],
          ),
        ));
  }
}

class TrackingBlock extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color borderColor;
  final Color backgroundColor;
  final String iconsAssetAddress;

  TrackingBlock(
      {Key key,
      this.label,
      this.value,
      this.color,
      this.borderColor,
      this.backgroundColor,
      this.iconsAssetAddress})
      : super(key: key);

//
//  Widget _percentCircle() {
//    return Container(
//      child: CircularPercentIndicator(
//        radius: 50,
//        circularStrokeCap: CircularStrokeCap.round,
//        reverse: true,
//        progressColor: color,
//        lineWidth: 7.0,
//        animation: true,
//        percent: 1,
//        center: new Text(
//          "${replaceFarsiNumber(value.toString())}",
//          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 9.0),
//        ),
//      ),
//    );
//  }
  Widget _blockIcon() {
    return Expanded(
      child: SizedBox(
        height: 50,
        width: 50,
        child: Image.asset(
          iconsAssetAddress,
          height: 50,
          width: 50,
        ),
      ),
    );
  }

  Widget _label() => Container(
        margin: EdgeInsets.only(top: 5),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
        ),
      );

  BoxDecoration _decoration() => BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 110, minWidth: 110, maxHeight: 110),
      decoration: _decoration(),
      margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10),
      padding: EdgeInsets.only(bottom: 5, top: 5, left: 20, right: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_blockIcon(), _label()]),
    );
  }
}
