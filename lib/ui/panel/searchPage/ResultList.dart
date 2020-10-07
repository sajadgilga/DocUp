import 'dart:convert';

import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polygon_clipper/polygon_clipper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ResultList extends StatefulWidget {
  final Function(String, UserEntity) onPush;
  List<UserEntity> results;
  bool isDoctor;
  bool isRequestsOnly;

  ResultList(
      {this.onPush, this.results, this.isDoctor, this.isRequestsOnly = false});

  @override
  _ResultListState createState() => _ResultListState();
}

class _ResultListState extends State<ResultList> {
  Widget _list(List<Widget> results) {
    if (results.length == 0)
      return Expanded(
        child: Center(
          child: Text(
            (widget.isDoctor
                ? Strings.emptyDoctorSearch
                : (widget.isRequestsOnly
                    ? Strings.emptyRequestsDoctorSide
                    : Strings.emptySearchDoctorSide)),
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      );
    return Expanded(
      flex: 2,
      child: ListView(
        children: results,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> results = [];
    for (var result in widget.results) {
      if (widget.isDoctor)
        results.add(_SearchResultDoctorItem(
          onPush: widget.onPush,
          entity: result,
        ));
//      else if (!widget.isDoctor)
//        results.add(_SearchResultPatientItem(
//          onPush: widget.onPush,
//          entity: result,
//        ));
    }
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 60),
      margin: EdgeInsets.only(top: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            child: Text(
              (widget.isRequestsOnly
                  ? Strings.requestsSearchLabel
                  : Strings.resultSearchLabel),
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          _list(results)
        ],
      ),
    );
  }
}

class _SearchResultDoctorItem extends StatelessWidget {
  final DoctorEntity entity;
  final Function(String, UserEntity) onPush;

  _SearchResultDoctorItem({Key key, this.entity, this.onPush})
      : super(key: key);

  void _showDoctorDialogue(context) {
//    showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(
//            title: Text(
//              "منتظر ما باشید",
//              textAlign: TextAlign.center,
//              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//            ),
//            content: Text("این امکان در نسخه‌های بعدی اضافه خواهد شد",
//                textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),
//          );
//        });
    onPush(NavigatorRoutes.doctorDialogue, entity);
  }

  Widget _image(context) => Container(
      child: Container(
          width: 70,
          child: ClipPolygon(
            sides: 6,
            rotate: 90,
            child: Image.network(
                (entity.user.avatar != null ? entity.user.avatar : '')),
          )));

  Widget _rating() => RatingBar(
        itemCount: 5,
        initialRating: 3.5,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemSize: 15,
        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
        onRatingUpdate: (rating) {},
      );

  Widget _tag(text) {
    return Container(
      padding: EdgeInsets.only(right: 10, left: 10),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          color: IColors.themeColor,
          borderRadius: BorderRadius.all(Radius.circular(7))),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget _tags() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _tag('ویزیت متنی'),
          _tag('ویزیت صوتی'),
        ],
      ),
    );
  }

  Widget _nameAndExpertise() {
    String utfName;
    String utfExpert;
    try {
      utfName = utf8.decode(entity.user.name.toString().codeUnits);
      utfExpert = utf8.decode(entity.expert.toString().codeUnits);
    } catch (_) {
      utfName = entity.user.name;
      utfExpert = entity.expert;
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _rating(),
              Text(
                utfName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          Text(
            utfExpert,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _info() {
    return Expanded(
      flex: 2,
      child: Container(
        margin: EdgeInsets.only(right: 10, left: 15),
        child: Column(
          children: <Widget>[_nameAndExpertise(), _tags()],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _showDoctorDialogue(context),
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0),
          margin: EdgeInsets.only(top: 10, bottom: 10),
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width - 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[_info(), _image(context)],
          ),
        ));
  }
}
