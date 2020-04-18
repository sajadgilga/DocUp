import 'dart:convert';

import 'package:docup/models/Doctor.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

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
      margin: EdgeInsets.only(top: 50, right: 40),
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

  Widget _info() {
    String utfName;
    String utfExpert;
    try {
      utfName = utf8.decode(entity.user.name
          .toString()
          .codeUnits);
      utfExpert = utf8.decode(entity.expert
          .toString()
          .codeUnits);
    } catch (_) {
      utfName = entity.user.name;
      utfExpert = entity.expert;
    }
    return Container(
      margin: EdgeInsets.only(right: 20),
      child: Column(
        children: <Widget>[
          Text(
            utfName,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            textAlign: TextAlign.right,
          ),
          Text(
            utfExpert,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            textAlign: TextAlign.right,
          ),
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
                child: Image.network(entity.user.avatar),
              ))));

  Widget _info() {
    String utfName;
    try {
      utfName= utf8.decode(entity.user.name.toString().codeUnits);
    } catch (_) {
      utfName = entity.user.name;
    }
    return Container(
      margin: EdgeInsets.only(right: 20),
      child: Column(
        children: <Widget>[
          Text(
            utfName,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            textAlign: TextAlign.right,
          ),
          Text(
            'درخواست ویزیت', //TODO
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            textAlign: TextAlign.right,
          ),
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
