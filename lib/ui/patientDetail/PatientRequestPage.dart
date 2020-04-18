import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/blocs/PatientBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/ui/widgets/PatientData.dart';
import 'package:docup/utils/UiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

class PatientRequestPage extends StatefulWidget {
  final PatientEntity entity;
  PatientRequestPage({Key key, this.entity}) : super(key: key);

  @override
  _PatientRequestPageState createState() => _PatientRequestPageState();
}

class _PatientRequestPageState extends State<PatientRequestPage> {
  PatientBloc _bloc = PatientBloc();

  @override
  void initState() {
//    _bloc.visitRequestStream.listen((data) {
//      if (data.status == Status.COMPLETED) {
//        Scaffold.of(context).showSnackBar(SnackBar(
//          content: Text('درخواست شما با موفقیت ثبت شد'),
//          duration: Duration(seconds: 3),
//        ));
//      } else {
//        Scaffold.of(context).showSnackBar(SnackBar(
//          content: Text(data.message),
//          duration: Duration(seconds: 3),
//        ));
//      }
//    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 50),
        constraints:
        BoxConstraints(maxWidth: MediaQuery
            .of(context)
            .size
            .width),
        child: Column(children: <Widget>[
          _headerWidget(),
          SizedBox(height: 10),

        ]),
      ),
    );
  }



  _headerWidget() =>
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PatientData(patientEntity: widget.entity),
          SizedBox(width: 10),
          Avatar(avatar: widget.entity.user.avatar),
        ],
      );

}
