import 'package:DocUp/blocs/PictureBloc.dart';
import 'package:DocUp/constants/colors.dart';
import 'package:DocUp/constants/strings.dart';
import 'package:DocUp/models/DoctorEntity.dart';
import 'package:DocUp/models/UserEntity.dart';
import 'package:DocUp/models/VisitTime.dart';
import 'package:DocUp/ui/mainPage/NavigatorView.dart';
import 'package:DocUp/ui/panel/chatPage/PartnerInfo.dart';
import 'package:DocUp/ui/widgets/VisitBox.dart';
import 'package:DocUp/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:DocUp/ui/widgets/PicList.dart';

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
