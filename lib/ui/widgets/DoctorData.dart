import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AutoText.dart';

class DoctorData extends StatelessWidget {
  final DoctorEntity doctorEntity;
  final double width;
  final int
      clinicMarkLocation; // 1 mean location should be in front of doctor name,2 mean it should be near expertise and -1 mean no location mark

  const DoctorData(
      {Key key, this.doctorEntity, this.width, this.clinicMarkLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: clinicMarkLocation == 1
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              clinicMarkLocation == 1 ? _clinicLocationMark() : SizedBox(),
              AutoText(
                  "دکتر ${doctorEntity.user.firstName} ${doctorEntity.user.lastName != null ? doctorEntity.user.lastName : ""}",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,softWrap: true,overflow: TextOverflow.fade,),
            ],
          ),
          SizedBox(height: 5),
          Visibility(
            visible: doctorEntity.clinic != null &&
                doctorEntity.clinic.clinicName != null,
            child: Row(
              mainAxisAlignment: clinicMarkLocation == 2
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.center,
              children: <Widget>[
                clinicMarkLocation == 2 ? _clinicLocationMark() : SizedBox(),
                Flexible(
                  child: AutoText(
                    "${doctorEntity.expert}",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Visibility(
            visible: doctorEntity.councilCode != null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AutoText(
                  "کد نظام پزشکی :‌ ${doctorEntity.councilCode}",
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.end,
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.info_outline,
                  color: Colors.black,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _clinicLocationMark() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AutoText(
            " کلینیک ${doctorEntity.clinic != null ? doctorEntity.clinic.clinicName : ""}",
            style: TextStyle(fontSize: 12, color: IColors.themeColor)),
        Icon(
          Icons.add_location,
          color: IColors.themeColor,
          size: 20,
        ),
      ],
    );
  }
}
