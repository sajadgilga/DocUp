import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/blocs/PictureBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/models/VisitTime.dart';
import 'package:docup/ui/panel/PanelAlert.dart';
import 'package:docup/ui/panel/chatPage/PartnerInfo.dart';
import 'package:docup/ui/widgets/VisitBox.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:docup/ui/widgets/PicList.dart';

class IllnessPage extends StatelessWidget {
  final Entity entity;
  final Function(String, dynamic) onPush;
  final PictureBloc _pictureBloc = PictureBloc();

  IllnessPage({Key key, this.entity, @required this.onPush}) : super(key: key);

  Widget _IllnessPage(times) {
    return BlocProvider.value(
        value: _pictureBloc,
        child: SingleChildScrollView(
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
                listId: entity.sectionId(Strings.cognitiveTests),
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
        )));
  }

  @override
  Widget build(BuildContext context) {
    List<VisitTime> times = [];
    times.add(VisitTime(Month.ESF, '۷', '۱۳۹۸', true));
    times.add(VisitTime(Month.DAY, '۱۶', '۱۳۹۸', false));
    times.add(VisitTime(Month.ABN, '۷', '۱۳۹۸', false));
    times.add(VisitTime(Month.TIR, '۱۲', '۱۳۹۸', false));
    times.add(VisitTime(Month.FAR, '۲۱', '۱۳۹۸', false));

    _pictureBloc
        .add(PictureListGet(listId: entity.sectionId(Strings.cognitiveTests)));

    return BlocBuilder<EntityBloc, EntityState>(
      builder: (context, state) {
        if (state is EntityLoaded) {
          if (state.entity.panel.status == 0 || state.entity.panel.status == 1)
            if (entity.isPatient)
            return Stack(children: <Widget>[
              _IllnessPage(times),
              PanelAlert(
                label: Strings.requestSentLabel,
                buttonLabel: Strings.waitingForApproval,
              )
            ]);
            else
              return Stack(children: <Widget>[
                _IllnessPage(times),
                PanelAlert(
                  label: Strings.requestSentLabelDoctorSide,
                  buttonLabel: Strings.waitingForApprovalDoctorSide,
                )
              ]);
          else
            return _IllnessPage(times);
        }
        return Container(
            constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            child:  Waiting());
      },
    );
  }
}
