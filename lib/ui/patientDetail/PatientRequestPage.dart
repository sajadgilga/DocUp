import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/blocs/PatientBloc.dart';
import 'package:docup/constants/colors.dart';
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
import 'package:docup/utils/UiUtils.dart';
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
                    errorMessage: snapshot.data.message,
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

  _headerWidget(VisitEntity entity) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 50),
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              children: <Widget>[
                Text(
                    "درخواست ویزیت مجازی، ${entity.visitType == 0 ? "متنی" : "تصویری"}",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: IColors.red),
                    textAlign: TextAlign.center),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 5),
                    Text(
                        "${widget.patientEntity.user.firstName} ${widget.patientEntity.user.lastName}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
              ],
            ),
          ),
          SizedBox(width: 10),
          Container(
              margin: EdgeInsets.only(top: 50),
              child: Avatar(avatar: widget.patientEntity.user.avatar)),
        ],
      );

  normalizeTime(String visitTime) {
    var date = visitTime.split("T")[0].split("-");
    var jajaliDate =
        Gregorian(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]))
            .toJalali();
    return replaceFarsiNumber(
        "${jajaliDate.year}/${jajaliDate.month}/${jajaliDate.day}");
  }
}
