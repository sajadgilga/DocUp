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
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/panel/panelMenu/DoctorPanelMenu.dart';
import 'package:docup/ui/panel/panelMenu/PatientPanelMenu.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/customPainter/DrawerPainter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PanelMenu extends StatefulWidget {
  final VoidCallback onPop;
  final ValueChanged<String> onPush;

  PanelMenu(this.onPop, {@required this.onPush});

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
                  child: SvgPicture.asset(
                    Assets.panelListIcon,
                    width: 35,
                    color: IColors.themeColor,
                  )
//                Image(
//                  image: AssetImage(Assets.panelListIcon),
//                  height: 40,
//                  width: 40,
//                ),
                  )),
          Container(
            padding: EdgeInsets.only(top: 10, left: 20),
            child: GestureDetector(
              onTap: () {
                var state = BlocProvider.of<PanelBloc>(context).state;
                if (state is PanelsLoaded) if (state.panels.length > 0)
                  _popMenu();
              },
              child: SvgPicture.asset(
                Assets.searchIcon,
                width: 30,
              ),
            ),
          )
        ],
      ));

  Widget _panelMenu() {
    return BlocBuilder<EntityBloc, EntityState>(builder: (context, state) {
      if (state is EntityError)
        return Waiting();
      if (state.entity.isPatient) {
        return PatientPanelMenu(widget.onPush);
      } else if (state.entity.isDoctor)
        return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
          builder: (context, panelState) {
            var _bloc = BlocProvider.of<PanelSectionBloc>(context);
            if (_bloc.state.section == null)
              _bloc.add(PanelSectionSelect(section: PanelSection.DOCTOR));

            if (panelState.section == PanelSection.DOCTOR)
              return DoctorPanelMenu(widget.onPush);
            else
              return PatientPanelMenu(
                widget.onPush,
                isPatient: false,
              );
          },
        );
      return PatientPanelMenu(widget.onPush); //TODO
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

  void _popMenu() async {
    widget.onPush(NavigatorRoutes.panel);
//    widget.onPop();
  }
}
