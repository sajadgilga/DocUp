import 'dart:ui';

import 'package:docup/blocs/MedicalTestListBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/models/NoronioService.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/SquareBoxNoronioClinic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'AutoText.dart';

class PanelTestList extends StatefulWidget {
  final PatientEntity patient;
  final int panelId;
  final String picLabel;
  final String uploadLabel;
  final String recentLabel;
  final Widget asset;
  final bool uploadAvailable;
  final int listId;
  final VoidCallback tapCallback;
  final List<MedicalTestItem> previousTest;
  final List<MedicalTestItem> waitingTest;
  final Function(String, dynamic) globalOnPush;

  PanelTestList(
      {Key key,
      this.picLabel,
      this.recentLabel,
      this.asset,
      @required this.listId,
      this.uploadAvailable = true,
      this.tapCallback,
      this.uploadLabel,
      this.previousTest,
      this.waitingTest,
      this.patient,
      @required this.panelId,
      this.globalOnPush})
      : super(key: key);

  @override
  _PanelTestListState createState() => _PanelTestListState();
}

class _PanelTestListState extends State<PanelTestList> {
  Widget _label(String text) => Container(
        padding: EdgeInsets.only(bottom: 15),
        child: AutoText(
          text,
          style: TextStyle(
              color: IColors.darkGrey,
              fontSize: 14,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
      );

  List<Widget> getConvertTestIconToNoronioSquareBox(
      List<MedicalTestItem> tests, bool editableFlag) {
    List<Widget> res = [];
    tests.forEach((element) {
      res.add(SquareBoxNoronioClinicService(
        NoronioServiceItem(element.name, Assets.noronioServiceBrainTest, null,
            NoronioClinicServiceType.MultipleChoiceTest, () {
          MedicalTestPageData medicalTestPageData = MedicalTestPageData(
              editableFlag: editableFlag,
              medicalTestItem: element,
              patientEntity: widget.patient,
              panelId: widget.panelId,
              onDone: () {
                BlocProvider.of<MedicalTestListBloc>(context)
                    .add(GetPanelMedicalTest(panelId: widget.panelId));
              });
          widget.globalOnPush(
              NavigatorRoutes.cognitiveTest, medicalTestPageData);
        }, true),
        boxSize: 120,
      ));
    });
    return res;
  }

  Widget _newTests() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                _label(widget.picLabel),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: getConvertTestIconToNoronioSquareBox(
                      widget.waitingTest, true)),
            )
          ],
        ),
      ),
    );
  }

  Widget _oldTests() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                _label(widget.recentLabel),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: getConvertTestIconToNoronioSquareBox(
                      widget.previousTest, false)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 50,
          maxWidth: MediaQuery.of(context).size.width - 50),
      child: Column(
        children: <Widget>[
          _newTests(),
          _oldTests(),
        ],
      ),
    );
  }
}
