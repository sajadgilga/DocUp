import 'dart:convert';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/panel/panelMenu/DoctorPanelMenu.dart';
import 'package:docup/ui/panel/panelMenu/PatientPanelMenu.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/customPainter/DrawerPainter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PanelMenu extends StatefulWidget {
  final VoidCallback onPop;

  PanelMenu(this.onPop);

  @override
  _PanelMenuState createState() {
    return _PanelMenuState();
  }
}

class _PanelMenuState extends State<PanelMenu> {
  Widget _header(context) => Header(
          child: Row(
        children: <Widget>[
          GestureDetector(
              onTap: () {
                var state = BlocProvider.of<PanelBloc>(context).state;
                if (state is PanelsLoaded) if (state.panels.length > 0)
                  _popMenu();
              },
              child: Container(
                padding: EdgeInsets.only(top: 15, left: 10, right: 10),
                child: Image(
                  image: AssetImage(Assets.panelListIcon),
                  height: 40,
                  width: 40,
                ),
              )),
          Container(
            padding: EdgeInsets.only(top: 15, left: 10),
            child: GestureDetector(
              onTap: () {
                var state = BlocProvider.of<PanelBloc>(context).state;
                if (state is PanelsLoaded) if (state.panels.length > 0)
                  _popMenu();
              },
              child: Icon(
                Icons.search,
                size: 30,
              ),
            ),
          )
        ],
      ));

  Widget _panelMenu() {
    return BlocBuilder<EntityBloc, EntityState>(builder: (context, state) {
      if (state.entity.isPatient) {
        return PatientPanelMenu();
      } else if (state.entity.isDoctor)
        return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
          builder: (context, panelState) {
            var _bloc = BlocProvider.of<PanelSectionBloc>(context);
            if (_bloc.state.section == null)
              _bloc.add(PanelSectionSelect(section: PanelSection.DOCTOR));

            if (panelState.section == PanelSection.DOCTOR)
              return DoctorPanelMenu();
            else
              return PatientPanelMenu(isPatient: false,);
          },
        );
      return PatientPanelMenu(); //TODO
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Stack(
        children: <Widget>[
          CustomPaint(
            painter: DrawerPainter(arcStart: 20),
            child: Container(
                padding: EdgeInsets.only(top: 100, right: 60),
                child: _panelMenu()),
          ),
          GestureDetector(
              onTap: () {
                _popMenu();
              },
              child: Container(
                  constraints: BoxConstraints(maxHeight: 100),
                  alignment: Alignment.topCenter,
                  child: _header(context))),
        ],
      ),
    );
  }

  void _popMenu() {
    widget.onPop();
  }
}