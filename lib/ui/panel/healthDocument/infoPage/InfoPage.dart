import 'package:docup/blocs/FileBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:docup/ui/widgets/PicList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class InfoPage extends StatefulWidget {
  final Entity entity;
  final Function(String, dynamic, Widget) onPush;
  final String picListLabel;
  final String lastPicsLabel;
  final String uploadLabel;
  final String emptyFilesLabel;
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
    widget.onPush(NavigatorRoutes.uploadFileDialogue,
        widget.entity.sectionId(widget.pageName), _fakeWidget());
  }

  @override
  Widget build(BuildContext context) {
    /// if we put this line in init state it will get mixed up with prescription tests and advices
    FileBloc bloc = BlocProvider.of<FileBloc>(context);
    var state = bloc.state;
    int panelSectionId = widget.entity.sectionId(widget.pageName);
    if (state != null) {
      if (((state is FileLoading && state.section!=null && state.section.id == panelSectionId) ||
          (state is FilesLoaded && state.section!=null && state.section.id == panelSectionId))) {
        /// do nothing
      }else{
        bloc.add(FileListGet(listId: panelSectionId));

      }
    } else {
      bloc.add(FileListGet(listId: panelSectionId));
    }

    return SingleChildScrollView(
        child: Container(
      child: Column(
        children: <Widget>[
          PartnerInfo(
            entity: widget.entity,
            onPush: (route, detail) {
              widget.onPush(route, detail, null);
            },
          ),
          PicList(
            listId: widget.entity.sectionId(widget.pageName),
            uploadAvailable: widget.uploadAvailable,
            picLabel: widget.picListLabel,
            recentLabel: widget.lastPicsLabel,
            emptyListLabel: widget.emptyFilesLabel,
            uploadLabel: widget.uploadLabel,
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
