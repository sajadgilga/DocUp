import 'dart:ui';

import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/blocs/PatientBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/ui/widgets/PatientData.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

class PatientRequestPage extends StatefulWidget {
  final PatientEntity patientEntity;

  PatientRequestPage({Key key, this.patientEntity}) : super(key: key);

  @override
  _PatientRequestPageState createState() => _PatientRequestPageState();
}

class _PatientRequestPageState extends State<PatientRequestPage> {
  DoctorInfoBloc _bloc = DoctorInfoBloc();

  @override
  void initState() {
    _bloc.responseVisitStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        String span = data.data.status == 1 ? "تایید" : "رد";
        toast(context, 'درخواست بیمار با موفقیت $span شد');
        Navigator.pop(context);
      } else if (data.status == Status.ERROR) {
        toast(context, data.message);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bloc.getVisit(widget.patientEntity.id);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _bloc.getVisit(widget.patientEntity.id),
        child: StreamBuilder<Response<VisitEntity>>(
          stream: _bloc.getVisitStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return APICallLoading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return Center(child: _headerWidget(snapshot.data.data));
                  break;
                case Status.ERROR:
                  return APICallError(
                    errorMessage: Strings.notFoundRequest,
                    onRetryPressed: () =>
                        _bloc.getVisit(widget.patientEntity.id),
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
    );
  }

  _headerWidget(VisitEntity entity) => Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _patientDataWidget(entity),
                SizedBox(width: 10),
                Avatar(user: widget.patientEntity.user),
              ],
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "توضیحات بیمار : ${entity.patientMessage}",
                  style: TextStyle(fontSize: 18),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.info_outline),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  "پرونده سلامت (در صورت ویزیت قبلی)",
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            _picListBox(MediaQuery.of(context).size.width),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ActionButton(
                  width: 150,
                  title: "رد",
                  icon: Icon(Icons.close),
                  color: IColors.red,
                  callBack: () {
                    _bloc.responseVisit(entity, false);
                  },
                ),
                ActionButton(
                  width: 150,
                  title: "تایید",
                  icon: Icon(Icons.check),
                  color: IColors.green,
                  callBack: () {
                    _bloc.responseVisit(entity, true);
                  },
                ),
              ],
            )
          ],
        ),
      );

  int _calculatePossiblePicCount(width) {
    return ((width - 50) / 160).toInt();
  }

  Widget _picListBox(width) {
    List<Widget> pictures = [];
    for (int i = 0; i < _calculatePossiblePicCount(width); i++) {
      pictures.add(Container(
        child: Column(
          children: <Widget>[
            Container(
              width: 150.0,
              height: 100.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover, image: AssetImage('assets/hand1.jpg')),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  color: Colors.white.withOpacity(.1),
                ),
              ),
            ),
            Text(
              'تصویر',
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: pictures,
      ),
    );
  }

  _patientDataWidget(VisitEntity entity) {
    return Column(
      children: <Widget>[
        Text(
            "درخواست ویزیت مجازی، ${entity.visitType == 0 ? "متنی" : "تصویری"}",
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: IColors.red),
            textAlign: TextAlign.center),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 5),
            Text(widget.patientEntity.user.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "زمان :‌ ${normalizeTime(entity.visitTime)}",
              style: TextStyle(fontSize: 12, color: IColors.green),
              textAlign: TextAlign.end,
            ),
            SizedBox(width: 10),
            Icon(
              Icons.check,
              color: IColors.green,
            )
          ],
        ),
      ],
    );
  }
}
