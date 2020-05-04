import 'dart:convert';

import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polygon_clipper/polygon_clipper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ResultList extends StatefulWidget {
  final Function(String, UserEntity) onPush;
  List<UserEntity> results;
  bool isDoctor;

  ResultList({this.onPush, @required this.results, this.isDoctor});

  @override
  _ResultListState createState() => _ResultListState();
}

class _ResultListState extends State<ResultList> {
  @override
  Widget build(BuildContext context) {
    List<Widget> results = [];

    for (var result in widget.results) {
      if (widget.isDoctor)
        results.add(_SearchResultDoctorItem(
          onPush: widget.onPush,
          entity: result,
        ));
      else if (!widget.isDoctor)
        results.add(_SearchResultPatientItem(
          onPush: widget.onPush,
          entity: result,
        ));
    }
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 60),
      margin: EdgeInsets.only(top: 20, right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            child: Text(
              'نتایج جستجو',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView(
              children: results,
            ),
          )
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

  Widget _image(context) => GestureDetector(
      onTap: () => _showDoctorDialogue(context),
      child: Container(
          child: Container(
              width: 70,
              child: ClipPolygon(
                sides: 6,
                rotate: 90,
                child: Image.network(entity.user.avatar),
              ))));

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
          Text(
            utfName,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            textAlign: TextAlign.right,
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
        margin: EdgeInsets.only(right: 20, left: 20),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[_rating(), _nameAndExpertise()],
            ),
            _tags()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      constraints:
          BoxConstraints(minWidth: MediaQuery.of(context).size.width - 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[_info(), _image(context)],
      ),
    );
  }
}

class _SearchResultPatientItem extends StatelessWidget {
  final PatientEntity entity;
  final Function(String, UserEntity) onPush;

  _SearchResultPatientItem({Key key, this.entity, this.onPush})
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
    onPush(NavigatorRoutes.patientDialogue, entity);
  }

  Widget _image(context) => GestureDetector(
      onTap: () => _showDoctorDialogue(context),
      child: Container(
          child: Container(
              width: 70,
              child: ClipPolygon(
                sides: 6,
                rotate: 90,
                child: (entity.user.avatar != null
                    ? Image.network(entity.user.avatar)
                    : Image.asset(Assets.emptyAvatar)),
              ))));

  Widget _status() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            PatientStatus.values[entity.status].text,
            style: TextStyle(
                color: PatientStatus.values[entity.status].color,
                fontSize: 8,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          PatientStatus.values[entity.status].icon,
        ],
      ),
    );
  }

  Widget _info() {
    String utfName;
    try {
      utfName = utf8.decode(entity.user.name.toString().codeUnits);
    } catch (_) {
      utfName = entity.user.name;
    }
    return Container(
      margin: EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            utfName,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            textAlign: TextAlign.right,
          ),
          _status()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[_info(), _image(context)],
      ),
    );
  }
}

enum PatientStatus { VIRTUAL_VISIT_REQUEST, VISIT_REQUEST, CURED, IN_CONTACT }

extension PatientStatusExtension on PatientStatus {
  Color get color {
    switch (this) {
      case PatientStatus.VISIT_REQUEST:
        return IColors.visitRequest;
      case PatientStatus.VIRTUAL_VISIT_REQUEST:
        return IColors.virtualVisitRequest;
      case PatientStatus.IN_CONTACT:
        return IColors.inContact;
      case PatientStatus.CURED:
        return IColors.cured;
      default:
        return Colors.black87;
    }
  }

  String get text {
    switch (this) {
      case PatientStatus.VISIT_REQUEST:
        return Strings.visitRequestLabel;
      case PatientStatus.VIRTUAL_VISIT_REQUEST:
        return Strings.virtualVisitRequestLabel;
      case PatientStatus.IN_CONTACT:
        return Strings.inContactLabel;
      case PatientStatus.CURED:
        return Strings.curedLabel;
      default:
        return '';
    }
  }

  get icon {
    switch (this) {
      case PatientStatus.VISIT_REQUEST:
        return SvgPicture.asset('');
      case PatientStatus.VIRTUAL_VISIT_REQUEST:
        return SvgPicture.asset(
          Assets.onCallMedicalIcon,
          width: 15,
        );
      case PatientStatus.IN_CONTACT:
        return Icon(
          Icons.person,
          size: 15,
          color: this.color,
        );
      case PatientStatus.CURED:
        return Icon(
          Icons.update,
          size: 15,
          color: this.color
        );
      default:
        return '';
    }
  }
}
