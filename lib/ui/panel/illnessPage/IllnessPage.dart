import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/models/VisitTime.dart';
import 'package:docup/ui/panel/chatPage/PartnerInfo.dart';
import 'package:docup/ui/widgets/VisitBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:docup/ui/widgets/PicList.dart';

class IllnessPage extends StatelessWidget {
  final Entity entity;
  final ValueChanged<String> onPush;

  IllnessPage({Key key, this.entity, @required this.onPush}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<VisitTime> times = [];
    times.add(VisitTime(Month.ESF, '۷', '۱۳۹۸', true));
    times.add(VisitTime(Month.DAY, '۱۶', '۱۳۹۸', false));
    times.add(VisitTime(Month.ABN, '۷', '۱۳۹۸', false));
    times.add(VisitTime(Month.TIR, '۱۲', '۱۳۹۸', false));
    times.add(VisitTime(Month.FAR, '۲۱', '۱۳۹۸', false));

    return SingleChildScrollView(
        child: Container(
      child: Column(
        children: <Widget>[
          PartnerInfo(
            entity: entity,
            onPush: onPush,
          ),
          VisitBox(
            visitTimes: times,
          ),
          PicList(
            uploadAvailable: entity.isPatient,
            picLabel: Strings.illnessInfoPicListLabel,
            recentLabel: Strings.illnessInfoLastPicsLabel,
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
