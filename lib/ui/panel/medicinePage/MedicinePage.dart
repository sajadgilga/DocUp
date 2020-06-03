import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/medicines/ReminderList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedicinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MedicinePageState();
  }
}

class _MedicinePageState extends State<MedicinePage> {
  Widget _today() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          'امروز',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        ReminderList(
          medicines: [],
        )
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
    var _isPatient = BlocProvider.of<EntityBloc>(context).state.entity.isDoctor;
    if (_isPatient) return Container();
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
            onPressed: () {},
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

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      SingleChildScrollView(
          child: Container(
              constraints: BoxConstraints(minWidth: double.infinity),
              margin: EdgeInsets.only(right: 30, left: 30, top: 25, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[_today(), _nextWeek()],
              ))),
      Align(
        alignment: Alignment(-.85, .9),
        child: _floatingButton(),
      )
    ]);
  }
}
