import 'dart:convert';

import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polygon_clipper/polygon_clipper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyPartnersResultList extends StatefulWidget {
  final Function(String, UserEntity) onPush;
  List<UserEntity> results;
  bool isDoctor;
  bool isRequestsOnly;

  MyPartnersResultList(
      {this.onPush, this.results, this.isDoctor, this.isRequestsOnly = false});

  @override
  _MyPartnersResultListState createState() => _MyPartnersResultListState();
}

class _MyPartnersResultListState extends State<MyPartnersResultList> {
  Widget _list(List<Widget> results) {
    if (results.length == 0) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Text(
                Strings.noVirtualAppointment,
                style: TextStyle(fontSize: 14, color: IColors.darkGrey),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: ActionButton(
                width: 170,
                height: 60,
                color: IColors.themeColor,
                textColor: IColors.whiteTransparent,
                borderRadius: 10,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                title:
                    widget.isDoctor ? "جست و جو پزشکان" : "جست و جوی بیماران",
                callBack: () {
                  widget.onPush(NavigatorRoutes.partnerSearchView, null);
                },
              ),
            )
          ],
        ),
      );
    } else {
      return Expanded(
        flex: 2,
        child: ListView(
          children: results,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> results = [];
    for (var result in widget.results) {
      if (widget.isDoctor)
        results.add(_MyPartnerItem(
          onPush: widget.onPush,
          entity: result,
        ));
      else if (!widget.isDoctor)
        results.add(_MyPartnerItem(
          onPush: widget.onPush,
          entity: result,
        ));
    }
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 230),
      margin: EdgeInsets.only(top: 20, right: 15, left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[_list(results)],
      ),
    );
  }
}

class _MyPartnerItem extends StatelessWidget {
  final DoctorEntity entity;
  final Function(String, UserEntity) onPush;

  _MyPartnerItem({Key key, @required this.entity, this.onPush})
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

  Widget _location() => Padding(
        padding: EdgeInsets.only(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 0),
              child: Text(
                "نورونیو",
                style: TextStyle(fontSize: 10, color: Colors.black26),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 0),
              child: Icon(
                Icons.add_location,
                color: Colors.black26,
                size: 10,
              ),
            ),
          ],
        ),
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
      padding: EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _location(),
              Text(
                utfName,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
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
          child: _nameAndExpertise()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onPush(NavigatorRoutes.myDoctorDialog, entity);
        },
        child: Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Color.fromRGBO(250, 250, 250, 1),
              borderRadius: BorderRadius.all(Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey,
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: Offset(0, 1.5))
              ]),
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width - 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[_info(), _image(context)],
          ),
        ));
  }
}