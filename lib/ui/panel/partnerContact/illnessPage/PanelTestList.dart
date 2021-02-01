import 'dart:ui';

import 'package:Neuronio/blocs/MedicalTestListBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/MedicalTest.dart';
import 'package:Neuronio/models/NoronioService.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/SquareBoxNoronioClinic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/AutoText.dart';

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
  final List<PanelMedicalTestItem> previousTest;
  final List<PanelMedicalTestItem> waitingTest;
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

  List<NoronioServiceItem> getConvertTestIconToNoronioSquareBox(
      List<PanelMedicalTestItem> tests, bool editableFlag, bool sendableFlag) {
    List<NoronioServiceItem> res = [];
    tests.forEach((element) {
      res.add(NoronioServiceItem(element.name, Assets.noronioServiceBrainTest,
          null, NoronioClinicServiceType.MultipleChoiceTest, () {
        MedicalTestPageData medicalTestPageData = MedicalTestPageData(
            MedicalPageDataType.Panel,
            editableFlag: editableFlag,
            sendableFlag: sendableFlag,
            medicalTestItem: element,
            patientEntity: widget.patient,
            panelId: widget.panelId, onDone: () {
          BlocProvider.of<MedicalTestListBloc>(context)
              .add(GetPanelMedicalTest(panelId: widget.panelId));
        });
        widget.globalOnPush(NavigatorRoutes.cognitiveTest, medicalTestPageData);
      }, true, responseDateTime: element.timeAddTest));
    });
    return res;
  }

  List<Widget> _getTestRows(List<NoronioServiceItem> serviceItems) {
    List<Widget> serviceRows = [];
    for (int i = 0; i < serviceItems.length; i += 2) {
      Widget ch1 = SquareBoxNoronioClinicService(
        serviceItems[i],
        boxSize: 130,
      );
      Widget ch2 = (i == serviceItems.length - 1)
          ? SquareBoxNoronioClinicService(
              NoronioServiceItem.empty(),
              boxSize: 130,
            )
          : SquareBoxNoronioClinicService(
              serviceItems[i + 1],
              boxSize: 130,
            );

      serviceRows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [ch1, ch2],
      ));
    }
    return serviceRows;
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
              child: Column(
                children: _getTestRows(getConvertTestIconToNoronioSquareBox(
                    widget.waitingTest.reversed.toList(), true, false)),
              ),
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
                child: Column(
                  children: _getTestRows(getConvertTestIconToNoronioSquareBox(
                      widget.previousTest.reversed.toList(), false, false)),
                ))
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
