import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/VisitTime.dart';
import 'package:docup/ui/panel/chatPage/DoctorInfo.dart';
import 'package:docup/ui/widgets/VisitBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:docup/ui/widgets/PicList.dart';

class InfoPage extends StatelessWidget {
  final DoctorEntity doctor;
  final ValueChanged<String> onPush;
  final String picListLabel;
  final String lastPicsLabel;

  InfoPage({Key key, this.doctor, this.picListLabel, this.lastPicsLabel, @required this.onPush}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              DoctorInfo(
                doctor: doctor,
                onPush: onPush,
              ),
              PicList(
                picLabel: picListLabel,
                recentLabel: lastPicsLabel,
                asset: SvgPicture.asset(
                  "assets/cloud.svg",
                  height: 35,
                  width: 35,
                  color: IColors.themeColor,
                ),
                onPush: onPush,
              )
            ],
          ),
        ));
  }
}
