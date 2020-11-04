import 'dart:ui';

import 'package:dashed_container/dashed_container.dart';
import 'package:docup/blocs/PictureBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/models/NoronioService.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/Picture.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/SquareBoxNoronioClinic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

import 'AutoText.dart';
import 'Waiting.dart';

class PanelTestList extends StatefulWidget {
  final PatientEntity patient;
  final String picLabel;
  final String uploadLabel;
  final String recentLabel;
  final Widget asset;
  final bool uploadAvailable;
  final int listId;
  final VoidCallback tapCallback;
  final List<MedicalTestItem> previousTest;
  final List<MedicalTestItem> waitingTest;
  final Function(String, dynamic) globalOnPush;

  PanelTestList(
      {Key key,
      this.picLabel,
      this.recentLabel,
      this.asset,
      @required this.listId,
      this.uploadAvailable = true,
      this.tapCallback,
      this.uploadLabel,
      this.previousTest,
      this.waitingTest,
      this.patient,
      this.globalOnPush})
      : super(key: key);

  @override
  _PanelTestListState createState() => _PanelTestListState();
}

class _PanelTestListState extends State<PanelTestList> {
  Widget _label(String text) => Container(
        padding: EdgeInsets.only(bottom: 15),
        child: AutoText(
          text,
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

  Widget _picListBox(width, List<PictureEntity> pics) {
//    return Container();
    List<Widget> pictures = [];
    for (PictureEntity pic in pics) {
//    for (int i = 0; i < _calculatePossiblePicCount(width); i++) {
      pictures.add(Container(
        child: Column(
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (_) {
                    return DetailScreen(
                      url: pic.imageURL,
                    );
                  }));
                },
                child: Container(
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
                )),
            AutoText(
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

  Widget _picList(width, pics) => Expanded(
        flex: 2,
        child: Container(
          child: Column(
            children: <Widget>[_picListHeader(), _picListBox(width, pics)],
          ),
        ),
      );

  Widget _testPictures() => BlocBuilder<PictureBloc, PictureState>(
        builder: (context, state) {
          if (widget.listId < 0) return Container();
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
            child: AutoText(''),
          );
        },
      );

  List<Widget> getConvertTestIconToNoronioSquareBox(
      List<MedicalTestItem> tests) {
    List<Widget> res = [];
    tests.forEach((element) {
      res.add(SquareBoxNoronioClinicService(
        NoronioServiceItem(element.name, Assets.noronioServiceBrainTest, null,
            NoronioClinicServiceType.MultipleChoiceTest, () {
          MedicalTestPageData medicalTestPageData = MedicalTestPageData(
              editableFlag: false,
              medicalTestItem: element,
              patientEntity: widget.patient);
          widget.globalOnPush(NavigatorRoutes.cognitiveTest, medicalTestPageData);
        }, true),
        boxSize: 120,
      ));
    });
    return res;
  }

  Widget _newTests() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                _label(widget.picLabel),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children:
                      getConvertTestIconToNoronioSquareBox(widget.waitingTest)),
            )
          ],
        ),
      ),
    );
  }

  Widget _oldTests() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                _label(widget.recentLabel),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: getConvertTestIconToNoronioSquareBox(
                      widget.previousTest)),
            )
          ],
        ),
      ),
    );
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
          _newTests(),
          _oldTests(),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String url;

  DetailScreen({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
            child: PhotoView(
          imageProvider: NetworkImage(
            url,
          ),
        )),
        onTap: () {
          Navigator.of(context, rootNavigator: true).maybePop();
        },
      ),
    );
  }
}
