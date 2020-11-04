import 'package:docup/blocs/PictureBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:docup/ui/widgets/PicList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class InfoPage extends StatelessWidget {
  final Entity entity;
  final Function(String, dynamic, Widget) onPush;
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

  Widget _fakeWidget() {
    return SingleChildScrollView(
        child: Container(
      child: Column(
        children: <Widget>[
          PartnerInfo(
            entity: entity,
            onPush: (route, detail) {},
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
            tapCallback: () {},
          )
        ],
      ),
    ));
  }

  void _tapUpload() {
    onPush(NavigatorRoutes.uploadFileDialogue, entity.sectionId(pageName),
        _fakeWidget());
  }

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
            onPush: (route, detail) {
              onPush(route, detail, null);
            },
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
            tapCallback: () {
              _tapUpload();
            },
          )
        ],
      ),
    ));
  }
}
