import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/MedicineBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/panel/chatPage/PartnerInfo.dart';
import 'package:docup/ui/panel/medicinePage/CreateMedicinePage.dart';
import 'package:docup/ui/widgets/medicines/ReminderList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _MedicinePage { MAIN, CREATION }

class MedicinePage extends StatefulWidget {
  final Entity entity;
  final Function(String, dynamic) onPush;

  const MedicinePage({Key key, this.entity, this.onPush}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MedicinePageState();
  }
}

class _MedicinePageState extends State<MedicinePage> {
  _MedicinePage _currentPage = _MedicinePage.MAIN;
  MedicineBloc _medicineBloc = MedicineBloc();

  @override
  void initState() {
    _medicineBloc.add(MedicineGet());
    super.initState();
  }

  @override
  void dispose() {
    _medicineBloc.close();
    super.dispose();
  }

  void _goBack() {
    setState(() {
      _currentPage = _MedicinePage.MAIN;
    });
  }

  Widget _reminderList() {
    return BlocBuilder<MedicineBloc, MedicineState>(
        bloc: _medicineBloc,
        builder: (context, state) {
          return ReminderList(
            medicines: state.medicines,
          );
        });
  }

  Widget _today() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          'امروز',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        _reminderList()
      ],
    );
  }

  Widget _nextWeek() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          'تا هفته آینده',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        ReminderList(
          medicines: [],
        )
      ],
    );
  }

  Widget _floatingButton() {
    var _isPatient =
        BlocProvider.of<EntityBloc>(context).state.entity.isPatient;
    if (_isPatient || _currentPage != _MedicinePage.MAIN) return Container();
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: IColors.themeColor,
            child: Icon(
              Icons.add,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _currentPage = _MedicinePage.CREATION;
              });
            },
          ),
          Container(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'داروی جدید',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ))
        ],
      ),
    );
  }

  Widget _mainPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[_today(), _nextWeek()],
    );
  }

  Widget _getCurrentPage() {
    if (_currentPage == _MedicinePage.MAIN)
      return _mainPage();
    else if (_currentPage == _MedicinePage.CREATION)
      return CreateMedicinePage(
        entity: widget.entity,
        onPush: widget.onPush,
        goBackToMainPage: _goBack,
      );
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      SingleChildScrollView(
          child: Container(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    PartnerInfo(
                      entity: widget.entity,
                      onPush: widget.onPush,
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            right: 30, left: 30, top: 25, bottom: 20),
                        child: _getCurrentPage())
                  ]))),
      Align(
        alignment: Alignment(-.85, .9),
        child: _floatingButton(),
      )
    ]);
  }
}
