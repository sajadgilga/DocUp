import 'dart:convert';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PartnerResultList extends StatefulWidget {
  final Function(String, UserEntity) onPush;
  List<UserEntity> results;
  bool isDoctor;
  bool isRequestsOnly;
  bool nextPageFetchLoader;
  final Function(int) selectPage;

  PartnerResultList(
      {this.onPush,
      this.results,
      this.isDoctor,
      this.isRequestsOnly = false,
      this.selectPage,
      this.nextPageFetchLoader = false});

  @override
  _PartnerResultListState createState() => _PartnerResultListState();
}

class _PartnerResultListState extends State<PartnerResultList> {
  Widget _list(List<Widget> results) {
    if (results.length == 0)
      return Expanded(
        child: Center(
          child: AutoText(
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
        children: widget.nextPageFetchLoader
            ? results + [DocUpAPICallLoading2()]
            : results,
        physics: BouncingScrollPhysics(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> results = [];
    for (var result in widget.results) {
      if (widget.isDoctor) {
        results.add(_SearchResultDoctorItem(
          onPush: widget.onPush,
          selectPage: widget.selectPage,
          entity: result,
        ));
      } else if (!widget.isDoctor) {
        results.add(_SearchResultPatientItem(
          onPush: widget.onPush,
          selectPage: widget.selectPage,
          entity: result,
        ));
      }
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
            child: AutoText(
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
  final Function(int) selectPage;

  _SearchResultDoctorItem({Key key, this.entity, this.onPush, this.selectPage})
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
    var _state = BlocProvider.of<EntityBloc>(context).state;
    if (!_state.entity.isDoctor) {
      onPush(NavigatorRoutes.doctorDialogue, entity);
    }
  }

  Widget _image(context) => Container(
      child: Container(
          width: 70,
          child: PolygonAvatar(
            user: entity.user,
          )));

  Widget _rating() => RatingBar.builder(
        itemCount: 5,
        initialRating: 3.5,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemSize: 15,
        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
        onRatingUpdate: (rating) {},
      );

  Widget _tag(text, context) {
    return Container(
      padding: EdgeInsets.only(right: 0, left: 0),
      decoration: BoxDecoration(
          color: Color.fromARGB(0, 0, 0, 0),
          borderRadius: BorderRadius.all(Radius.circular(7))),
      child: AutoText(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: IColors.themeColor, fontSize: 10),
      ),
    );
  }

  Widget _tags(context) {
    List<Widget> res = [];
    if(entity.plan== null || entity.plan.visitTypes==null || entity.plan.visitTypes.length==0){
      res.add(_tag("ویزیتی ثبت نشده", context));
    }
    entity.plan?.virtualVisitMethod?.forEach((element) {
      if (element == 0) {
        res.add(_tag('متنی', context));
      } else if (element == 1) {
        res.add(_tag('صوتی', context));
      } else if (element == 2) {
        res.add(_tag('تصویری', context));
      }
      if (entity.plan.virtualVisitMethod.indexOf(element) !=
          entity.plan.virtualVisitMethod.length - 1) {
        res.add(_tag("/", context));
      }
    });
    res.add(_tag("ویزیت ها: ", context));
    return Container(
      width: 200,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: res,
      ),
    );
  }

  Widget _nameAndExpertise(context) {
    String utfName;
    String utfExpert;
    try {
      utfName = utf8.decode((entity.user.name ?? "").toString().codeUnits);
      utfExpert = utf8.decode((entity.expert ?? "").toString().codeUnits);
    } catch (e) {
      utfName = entity.user.name;
      utfExpert = entity.expert ?? "";
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(child: _rating()),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: AutoText(
                    (utfName == "" ? " - " : utfName),
                    style: TextStyle(fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ),
          ],
        ),
        AutoText(
          utfExpert == "" ? " - " : utfExpert,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _info(context) {
    return Expanded(
      flex: 2,
      child: Container(
        margin: EdgeInsets.only(right: 10, left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[_nameAndExpertise(context), _tags(context)],
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
          children: <Widget>[_info(context), _image(context)],
        ),
      ),
    );
  }
}

class _SearchResultPatientItem extends StatelessWidget {
  final PatientEntity entity;
  final Function(String, UserEntity) onPush;
  final Function(int) selectPage;

  _SearchResultPatientItem({Key key, this.entity, this.onPush, this.selectPage})
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
//     selectPage(1);
    onPush(NavigatorRoutes.myPartnerDialog, entity);
  }

  Widget _image(context) => Container(
      child: Container(
          width: 70,
          child: PolygonAvatar(
            user: entity.user,
          )));

  //
  // Widget _rating() => RatingBar.builder(
  //       itemCount: 5,
  //       initialRating: 3.5,
  //       direction: Axis.horizontal,
  //       allowHalfRating: true,
  //       itemSize: 15,
  //       itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
  //       onRatingUpdate: (rating) {},
  //     );

  Widget _tag(text) {
    return Container(
      padding: EdgeInsets.only(right: 10, left: 10),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          color: IColors.themeColor,
          borderRadius: BorderRadius.all(Radius.circular(7))),
      child: AutoText(
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
    String utfExpert = "";
    try {
      utfName = utf8.decode((entity.user.name ?? "").toString().codeUnits);
    } catch (e) {
      utfName = entity.user.name;
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // _rating(),
              SizedBox(),
              AutoText(
                utfName == "" ? " - " : utfName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          AutoText(
            utfExpert == "" ? " - " : utfExpert,
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
          children: <Widget>[_nameAndExpertise()],
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
      ),
    );
  }
}
