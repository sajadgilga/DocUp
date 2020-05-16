import 'dart:ui';

import 'package:docup/blocs/PictureBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Picture.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:dashed_container/dashed_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PicList extends StatefulWidget {
  final String picLabel;
  final String recentLabel;
  final Widget asset;
  final bool uploadAvailable;
  final int listId;
  final Function(String, dynamic) onPush;

  PicList(
      {Key key,
      this.picLabel,
      this.recentLabel,
      this.asset,
      @required this.listId,
      this.uploadAvailable = true,
      @required this.onPush})
      : super(key: key);

  @override
  _PicListState createState() => _PicListState();
}

class _PicListState extends State<PicList> {
  Widget _label() => Container(
        padding: EdgeInsets.only(bottom: 15),
        child: Text(
          widget.picLabel,
          style: TextStyle(
              color: IColors.darkGrey,
              fontSize: 14,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
      );

  void _showUploadDialogue() {
    widget.onPush(NavigatorRoutes.uploadPicDialogue, widget.listId);
//    widget.onPush(NavigatorRoutes.cognitiveTest, "10000");
  }

  Widget _uploadBoxLabel() => Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.asset,
          Text(
            Strings.illnessInfoPicUploadLabel,
            style: TextStyle(
                fontSize: 8,
                color: IColors.themeColor,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )
        ],
      ));

  Widget _uploadBox() {
    if (widget.uploadAvailable)
      return GestureDetector(
        child: DashedContainer(
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
              Radius.circular(10),
            )),
            child: _uploadBoxLabel(),
          ),
          dashColor: IColors.themeColor,
          borderRadius: 10.0,
          dashedLength: 10,
          blankLength: 10,
          strokeWidth: 2.5,
        ),
        onTap: _showUploadDialogue,
      );
    else
      return Container();
  }

  Widget _picListBox(width, List<PictureEntity> pics) {
//    return Container();
    List<Widget> pictures = [];
    for (PictureEntity pic in pics) {
//    for (int i = 0; i < _calculatePossiblePicCount(width); i++) {
      pictures.add(Container(
        child: Column(
          children: <Widget>[
            Container(
              width: 150.0,
              height: 100.0,
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover, image: NetworkImage(pic.imageURL)),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  color: Colors.white.withOpacity(.4),
                ),
              ),
            ),
            Text(
              pic.title,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: IColors.darkGrey,
              ),
            )
          ],
        ),
      ));
    }
    return Container(
      margin: EdgeInsets.only(right: 15, top: 10),
      child: Wrap(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: pictures,
      ),
    );
  }

  int _calculatePossiblePicCount(width) {
    return ((width - 50) / 160).toInt();
  }

  Widget _picListHeader() => Container(
        margin: EdgeInsets.only(right: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
//                Strings.illnessInfoPicShowLabel,
                '',
                style: TextStyle(
                    color: IColors.themeColor,
                    fontSize: 8,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.recentLabel,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 8,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 8,
                    height: 5,
                    child: Divider(
                      thickness: 2,
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );

  Widget _picList(width, pics) => Expanded(
        flex: 2,
        child: Container(
          child: Column(
            children: <Widget>[_picListHeader(), _picListBox(width, pics)],
          ),
        ),
      );

  Widget _recentPics() => BlocBuilder<PictureBloc, PictureState>(
        builder: (context, state) {
          if (widget.listId <0)
            return Container();
          if (state is PicturesLoaded) {
            if (state.section.id == widget.listId)
              return Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    _picList(MediaQuery.of(context).size.width,
                        (state as PicturesLoaded).section.pictures),
                  ],
                ),
              );
          }
          if (state is PictureLoading) {
            if (state.section == null)
              return Container(
                  margin: EdgeInsets.only(top: 40), child: Waiting());

            if (state.section.id == widget.listId)
              return Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    _picList(MediaQuery.of(context).size.width,
                        (state as PictureLoading).section.pictures),
                  ],
                ),
              );
            else
              return Container(
                  margin: EdgeInsets.only(top: 40), child: Waiting());
          }
          return Container(
            child: Text(''),
          );
        },
      );

  Widget _uploadPic() {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: FractionallySizedBox(
            widthFactor: 1,
//        decoration: BoxDecoration(
//          color: Colors.blue,
//        ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _label(),
                Container(
                  alignment: Alignment.center,
                  child: _uploadBox(),
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 50,
          maxWidth: MediaQuery.of(context).size.width - 50),
      child: Column(
        children: <Widget>[
          _uploadPic(),
          _recentPics(),
        ],
      ),
    );
  }
}
