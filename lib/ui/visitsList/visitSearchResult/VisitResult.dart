import 'dart:convert';

import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/utils/CrossPlatformSvg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class VisitResultList extends StatefulWidget {
  final Function(String, UserEntity) onPush;
  final String text;
  List<VisitEntity> visitResults;
  bool isDoctor;
  bool isRequestsOnly;
  final String emptyText;

  VisitResultList(
      {this.onPush,
      this.visitResults,
      this.isDoctor,
      this.text,
      this.emptyText,
      this.isRequestsOnly = false});

  @override
  _VisitResultListState createState() => _VisitResultListState();
}

class _VisitResultListState extends State<VisitResultList> {
  Widget _list(List<Widget> results) {
    if (results.length == 0)
      return Center(
        child: AutoText(
          widget.emptyText ?? "",
          style: TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      );
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: results,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> results = [];

    for (var result in widget.visitResults) {
      results.add(_SearchResultPatientItem(
        onPush: widget.onPush,
        entity: result,
      ));
    }
    return Container(
      margin: EdgeInsets.only(right: 20, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Divider(
            thickness: 1,
            color: IColors.darkGrey,
            height: 0,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
//            constraints: BoxConstraints(maxWidth: 60),
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                decoration: BoxDecoration(
                    color: IColors.themeColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: AutoText(
                  widget.text,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              )),
          _list(results)
        ],
      ),
    );
  }
}

class _SearchResultPatientItem extends StatelessWidget {
//  final PatientEntity entity;
  final VisitEntity entity;
  final Function(String, UserEntity) onPush;
  final Map<int, String> visitTypes = {0: 'حضوری', 1: 'مجازی'};
  final Map<int, String> visitMethods = {0: 'متنی', 1: 'صوتی', 2: 'تصویری'};
  final Map<int, String> visitPlans = {0: 'حضوری', 1: 'مجازی'};

  _SearchResultPatientItem({Key key, this.entity, this.onPush})
      : super(key: key);

  void _showDoctorDialogue(context) {
//    showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(
//            title: AutoText(
//              "منتظر ما باشید",
//              textAlign: TextAlign.center,
//              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//            ),
//            content: AutoText("این امکان در نسخه‌های بعدی اضافه خواهد شد",
//                textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),
//          );
//        });
    PatientEntity pEntity = PatientEntity(
        user: entity.patientEntity.user,
        id: entity.patientEntity.id,
        vid: entity.id);
    onPush(NavigatorRoutes.patientDialogue, pEntity);
  }

  Widget _image(context) => Container(
      child: Container(
          width: 70,
          child: PolygonAvatar(
            user: entity.patientEntity.user,
          )));

  String _statusString(type, method) {
    var str = 'ویزیت '
        '${visitTypes[type]}';
    if (type == 1)
      str += ' '
          '${visitMethods[method]}';
    return str;
  }

  Widget _status(context) {
    return Container(
      height: 30,
      constraints:
          BoxConstraints.tightFor(width: MediaQuery.of(context).size.width / 2,height: 30),
      alignment: Alignment.bottomLeft,
      margin: EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          AutoText(
            _statusString(entity.visitType, entity.visitMethod),
            softWrap: true,
            overflow: TextOverflow.fade,
            style: TextStyle(
                color: IColors.themeColor,
                fontSize: 9,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
            textDirection: TextDirection.rtl,
          ),
          SizedBox(
            child: PatientStatus.values[entity.status].icon,
            width: 15,
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _info(context) {
    String utfName;
    try {
      utfName =
          utf8.decode(entity.patientEntity.user.name.toString().codeUnits);
    } catch (_) {
      utfName = entity.patientEntity.user.name;
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AutoText(
                utfName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          _status(context)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (entity.patientEntity == null) return Container();
    return GestureDetector(
        onTap: () => _showDoctorDialogue(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(top: 10, bottom: 10, left: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[_info(context), _image(context)],
          ),
        ));
  }
}

enum PatientStatus {
  VISIT_REQUEST,
  VIRTUAL_VISIT_REQUEST,
  VISIT_REQUEST_VERIFIED,
  VIRTUAL_VISIT_REQUEST_VERIFIED,
  VISIT_IN_CONTACT,
  VIRTUAL_VISIT_IN_CONTACT,
  CURED,
  REJECTED,
}

extension PatientStatusExtension on PatientStatus {
  Color get color {
    switch (this) {
      case PatientStatus.VISIT_REQUEST:
        return IColors.visitRequest;
      case PatientStatus.VIRTUAL_VISIT_REQUEST:
        return IColors.virtualVisitRequest;
      case PatientStatus.VIRTUAL_VISIT_IN_CONTACT:
        return IColors.inContact;
      case PatientStatus.VISIT_IN_CONTACT:
        return IColors.inContact;
      case PatientStatus.VISIT_REQUEST_VERIFIED:
        return IColors.inContact;
      case PatientStatus.VIRTUAL_VISIT_REQUEST_VERIFIED:
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
      case PatientStatus.VIRTUAL_VISIT_IN_CONTACT:
        return Strings.inContactLabel;
      case PatientStatus.VISIT_IN_CONTACT:
        return Strings.inContactLabel;
      case PatientStatus.VISIT_REQUEST_VERIFIED:
        return Strings.inContactLabel;
      case PatientStatus.VIRTUAL_VISIT_REQUEST_VERIFIED:
        return Strings.inContactLabel;
      case PatientStatus.CURED:
        return Strings.curedLabel;
      default:
        return '';
    }
  }

  get icon {
    switch (this) {
      case PatientStatus.VIRTUAL_VISIT_IN_CONTACT:
        return Icon(
          Icons.person,
          size: 15,
          color: this.color,
        );
      case PatientStatus.VISIT_IN_CONTACT:
        return Icon(
          Icons.person,
          size: 15,
          color: this.color,
        );
      case PatientStatus.VISIT_REQUEST_VERIFIED:
        return Icon(
          Icons.person,
          size: 15,
          color: this.color,
        );
      case PatientStatus.VIRTUAL_VISIT_REQUEST_VERIFIED:
        return Icon(
          Icons.person,
          size: 15,
          color: this.color,
        );
      case PatientStatus.VISIT_REQUEST:
        return Image.asset(
          Assets.visitListDoctorIcon1,
          width: 15,
          height: 15,
        );
      case PatientStatus.VIRTUAL_VISIT_REQUEST:
        return CrossPlatformSvg.asset(
          Assets.onCallMedicalIcon,
          width: 15,
        );
      case PatientStatus.CURED:
        return Icon(Icons.update, size: 15, color: this.color);
      default:
        return Image.asset(
          Assets.visitListDoctorIcon1,
          width: 15,
          height: 15,
        );
    }
  }
}
