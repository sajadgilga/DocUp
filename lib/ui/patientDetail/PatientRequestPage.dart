import 'dart:ui';

import 'package:DocUp/blocs/DoctorInfoBloc.dart';
import 'package:DocUp/blocs/PanelBloc.dart';
import 'package:DocUp/blocs/SearchBloc.dart';
import 'package:DocUp/constants/colors.dart';
import 'package:DocUp/constants/strings.dart';
import 'package:DocUp/models/PatientEntity.dart';
import 'package:DocUp/models/VisitResponseEntity.dart';
import 'package:DocUp/networking/Response.dart';
import 'package:DocUp/ui/widgets/APICallError.dart';
import 'package:DocUp/ui/widgets/APICallLoading.dart';
import 'package:DocUp/ui/widgets/ActionButton.dart';
import 'package:DocUp/ui/widgets/Avatar.dart';
import 'package:DocUp/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientRequestPage extends StatefulWidget {
  final PatientEntity patientEntity;

  PatientRequestPage({Key key, this.patientEntity}) : super(key: key);

  @override
  _PatientRequestPageState createState() => _PatientRequestPageState();
}

class _PatientRequestPageState extends State<PatientRequestPage> {
  DoctorInfoBloc _bloc = DoctorInfoBloc();

  void _updateSearch() {
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    searchBloc.add(SearchPatient(text: '', isRequestOnly: true));
    var _panelBloc = BlocProvider.of<PanelBloc>(context);
    _panelBloc.add(GetMyPanels());
  }

  @override
  void initState() {
    _bloc.responseVisitStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        String span = data.data.status == 1 ? "تایید" : "رد";
        toast(context, 'درخواست بیمار با موفقیت $span شد');
        _updateSearch();
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
    String visitType = entity.visitType == 0 ? "حضوری" : "مجازی";
    String visitMethod = entity.visitMethod == 0 ? "متنی" : "تصویری";
    return Column(
      children: <Widget>[
        Text(
          "درخواست ویزیت $visitType، $visitMethod",
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
              replaceFarsiNumber(normalizeDateAndTime(entity.visitTime)),
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
