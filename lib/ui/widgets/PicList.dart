import 'dart:ui';

import 'package:dashed_container/dashed_container.dart';
import 'package:docup/blocs/FileBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/Picture.dart';
import 'package:docup/ui/widgets/UploadSlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

import 'AutoText.dart';
import 'Waiting.dart';

class PicList extends StatefulWidget {
  final String picLabel;
  final String uploadLabel;
  final String recentLabel;
  final String emptyListLabel;
  final Widget asset;
  final bool uploadAvailable;
  final int listId;
  final VoidCallback tapCallback;

  PicList(
      {Key key,
      this.picLabel,
      this.recentLabel,
      this.emptyListLabel = "فایلی موجود نمی باشد.",
      this.asset,
      @required this.listId,
      this.uploadAvailable = true,
      this.tapCallback,
      this.uploadLabel})
      : super(key: key);

  @override
  _PicListState createState() => _PicListState();
}

class _PicListState extends State<PicList> {
  Widget _label() => Container(
        padding: EdgeInsets.only(bottom: 15),
        child: AutoText(
          widget.picLabel,
          style: TextStyle(
              color: IColors.darkGrey,
              fontSize: 14,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
      );

  Widget _uploadBoxLabel() => Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.asset,
          AutoText(
            widget.uploadLabel,
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
        onTap: () => widget.tapCallback(),
      );
    else
      return Container();
  }

  Widget _pictureItem(FileEntity fileEntity) {
    return GestureDetector(
      onTap: () {
        if (fileEntity != null) {
          if (AllowedFile.getFileType(fileEntity.extension) ==
              AllowedFileType.image) {
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (_) {
              return DetailScreen(
                imageURL: fileEntity.fileURL,
                description: fileEntity.description,
                title: fileEntity.title,
              );
            }));
          } else {}
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * (40 / 100),
        height: 140.0,
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * (40 / 100),
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                child: FittedBox(
                  child: fileEntity.defaultFileWidget,
                  fit: BoxFit.cover,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                ),
              ),
            ),
            AutoText(
              fileEntity != null ? fileEntity.title : "",
              maxLines: 2,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: IColors.darkGrey,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _picListBox(width, List<FileEntity> pics) {
    List<Widget> pictures = [];
    for (int i = 0; i < pics.length; i += 2) {
      FileEntity pic1 = pics[i];
      FileEntity pic2 = (i == pics.length - 1) ? null : pics[i + 1];

      pictures.add(Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_pictureItem(pic2), _pictureItem(pic1)],
        ),
      ));
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
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
              child: AutoText(
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
                  AutoText(
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

  Widget _picList(width, List<FileEntity> pics) {
    return Container(
      child: Column(
        children: <Widget>[
          widget.uploadAvailable ? _picListHeader() : SizedBox(),
          pics.length == 0
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: AutoText(widget.emptyListLabel),
                )
              : _picListBox(width, pics)
        ],
      ),
    );
  }

  Widget _recentPics() => BlocBuilder<FileBloc, FileState>(
        builder: (context, state) {
          if (widget.listId == null || widget.listId < 0) return Container();
          if (state is FilesLoaded) {
            if (state.section.id == widget.listId) {
              return _picList(
                  MediaQuery.of(context).size.width, state.section.pictures);
            }
          }
          if (state is FileLoading) {
            if (state.section == null)
              return Container(
                  margin: EdgeInsets.only(top: 40), child: Waiting());

            if (state.section.id == widget.listId)
              return _picList(
                  MediaQuery.of(context).size.width, state.section.pictures);
            else
              return Container(
                  margin: EdgeInsets.only(top: 40), child: Waiting());
          }
          return Container(
            child: AutoText(''),
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

class DetailScreen extends StatefulWidget {
  String imageURL;
  final String title;
  final String description;

  DetailScreen({Key key, this.imageURL, this.title, this.description})
      : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  int textToggle = 1;

  /// 1 show 0 hide
  @override
  Widget build(BuildContext context) {
    widget.imageURL = null;
    double maxX = MediaQuery.of(context).size.width;
    double maxY = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: maxX,
            height: maxY,
            color: Colors.black,
          ),
          widget.imageURL != null
              ? GestureDetector(
                  child: Center(
                      child: PhotoView(
                    imageProvider: NetworkImage(
                      widget.imageURL,
                    ),
                  )),
                  onTap: () {
                    setState(() {
                      textToggle = textToggle == 1 ? 0 : 1;
                    });
                  },
                )
              : SizedBox(),
          AnimatedSize(
            duration: Duration(milliseconds: 100),
            vsync: this,
            child: Container(
                width: maxX,
                constraints: BoxConstraints(
                    maxHeight: widget.imageURL != null
                        ? textToggle * maxY / 3
                        : textToggle * maxY * 0.9,
                    minHeight: 0),
                decoration: BoxDecoration(
                    color: Color.fromARGB(100, 150, 150, 150),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        width: maxX,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: AutoText(
                                widget.title,
                                color: Colors.white,
                                textAlign: TextAlign.center,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: AutoText(
                                widget.description,
                                color: Colors.white,
                                textAlign: TextAlign.center,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          Positioned(
            top: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).maybePop();
              },
              child: Container(
                padding: EdgeInsets.all(5.0),
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: IColors.darkGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
