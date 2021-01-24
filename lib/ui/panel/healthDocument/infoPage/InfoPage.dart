import 'package:docup/constants/colors.dart';
import 'package:docup/models/TextPlan.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:docup/ui/widgets/PicList.dart';
import 'package:docup/utils/CrossPlatformSvg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class InfoPage extends StatefulWidget {
  final Entity entity;
  final Function(String, dynamic, dynamic, Widget) onPush;
  final String picListLabel;
  final String lastPicsLabel;
  final String uploadLabel;
  final String emptyFilesLabel;
  final String pageName;
  bool uploadAvailable;
  final TextPlanRemainedTraffic textPlanRemainedTraffic;

  InfoPage(
      {Key key,
      this.entity,
      this.picListLabel,
      this.textPlanRemainedTraffic,
      @required this.pageName,
      this.lastPicsLabel,
      this.uploadAvailable = true,
      this.uploadLabel,
      this.emptyFilesLabel,
      @required this.onPush})
      : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _fakeWidget() {
    return SingleChildScrollView(
        child: Container(
      child: Column(
        children: <Widget>[
          PartnerInfo(
            entity: widget.entity,
            onPush: (route, detail) {},
          ),
          PicList(
            listId: widget.entity.sectionId(widget.pageName),
            uploadAvailable: widget.uploadAvailable,
            picLabel: widget.picListLabel,
            recentLabel: widget.lastPicsLabel,
            emptyListLabel: widget.emptyFilesLabel,
            uploadLabel: widget.uploadLabel,
            asset: CrossPlatformSvg.asset(
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
    int partnerId = widget.entity.isDoctor
        ? widget.entity.patient.id
        : widget.entity.doctor.id;
    widget.onPush(NavigatorRoutes.uploadFileDialogue,
        widget.entity.sectionId(widget.pageName), partnerId, _fakeWidget());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      child: Column(
        children: <Widget>[
          PartnerInfo(
            entity: widget.entity,
            onPush: (route, detail) {
              widget.onPush(route, detail, null, null);
            },
          ),
          PicList(
            listId: widget.entity.sectionId(widget.pageName),
            uploadAvailable: widget.uploadAvailable,
            picLabel: widget.picListLabel,
            recentLabel: widget.lastPicsLabel,
            emptyListLabel: widget.emptyFilesLabel,
            uploadLabel: widget.uploadLabel,
            asset: CrossPlatformSvg.asset(
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
