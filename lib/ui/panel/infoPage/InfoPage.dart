import 'package:docup/blocs/PictureBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/models/VisitTime.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/chatPage/PartnerInfo.dart';
import 'package:docup/ui/widgets/VisitBox.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:docup/ui/widgets/PicList.dart';

class InfoPage extends StatelessWidget {
  final Entity entity;
  final Function(String, dynamic) onPush;
  final String picListLabel;
  final String lastPicsLabel;
  final String uploadLabel;
  final String pageName;
  bool uploadAvailable;

  InfoPage(
      {Key key,
      this.entity,
      this.picListLabel,
      @required this.pageName,
      this.lastPicsLabel,
      this.uploadAvailable = true,
      this.uploadLabel,
      @required this.onPush})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PictureBloc>(context)
        .add(PictureListGet(listId: entity.sectionId(pageName)));

    return SingleChildScrollView(
        child: Container(
      child: Column(
        children: <Widget>[
          PartnerInfo(
            entity: entity,
            onPush: onPush,
          ),
          PicList(
            listId: entity.sectionId(pageName),
            uploadAvailable: uploadAvailable,
            picLabel: picListLabel,
            recentLabel: lastPicsLabel,
            uploadLabel: uploadLabel,
            asset: SvgPicture.asset(
              "assets/cloud.svg",
              height: 35,
              width: 35,
              color: IColors.themeColor,
            ),
            tapCallback: () => {
              onPush(
                  NavigatorRoutes.uploadPicDialogue, entity.sectionId(pageName))
            },
          )
        ],
      ),
    ));
  }
}
