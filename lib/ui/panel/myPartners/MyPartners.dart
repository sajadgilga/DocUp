import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/PanelBloc.dart';
import 'package:Neuronio/blocs/SearchBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/SearchResult.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/Waiting.dart';
import 'package:Neuronio/utils/entityUpdater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'MyPartnersResultList.dart';

class MyPartners extends StatefulWidget {
  final Function(String, UserEntity) onPush;

  MyPartners({@required this.onPush});

  @override
  _MyPartnersState createState() => _MyPartnersState();
}

class _MyPartnersState extends State<MyPartners> {
  void _initialSearch() {
    EntityAndPanelUpdater.processOnEntityLoad((entity) {
      if (mounted) {
        var panelBloc = BlocProvider.of<PanelBloc>(context);
        if (entity.isDoctor)
          panelBloc.add(PatientPanel(
            text: "",
          ));
        else if (entity.isPatient) if (entity.mEntity != null) {
          panelBloc.add(DoctorPanel(isMyDoctors: true));
        } else {
          throw Exception("empty mEntity in my partners");
        }
      }
    });
  }

  @override
  void initState() {
    _initialSearch();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _header(context) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(),
          child: AutoText(
            entity.isPatient ? "پزشکان من" : "بیماران من",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 30),
          child: Container(
              width: 25,
              child: Image.asset(
                Assets.panelMyDoctorIcon,
                width: 25,
                height: 25,
                color: IColors.themeColor,
              )),
        ),
      ],
    );
  }

  Widget _resultList() {
    return BlocBuilder<PanelBloc, PanelState>(
      builder: (context, state) {
        if (state is PanelLoaded ||
            (state is PanelLoading && state.panels != null)) {
          return MyPartnersResultList(
            onPush: widget.onPush,
            isDoctor: state.panels.isDoctor,
            results: (state.panels.isDoctor
                ? state.panels.doctorResults
                : state.panels.patientResults),
            isRequestsOnly: false,
          );
        } else if (state is PanelError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 30,
              ),
              APICallError(
                () {
                  _initialSearch();
                },
                tightenPage: true,
              ),
            ],
          );
        } else if (state is PanelLoading) {
          if (state.panels == null)
            return Container(
              child: Waiting(),
            );
        }
        return Container(
          child: Waiting(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return Container(
      child: Column(
        children: <Widget>[
          // PageTopLeftIcon(
          //   topLeft: Icon(
          //     Icons.arrow_back,
          //     color: IColors.themeColor,
          //     size: 20,
          //   ),
          //   topLeftFlag: false,
          //   topRight: Padding(
          //     padding: EdgeInsets.only(right: 25),
          //     child: menuLabel("پنل کاربری"),
          //   ),
          //   topRightFlag: true,
          //   onTap: () {},
          // ),
          Padding(
            padding: EdgeInsets.only(right: 25, top: 10),
            child: _header(context),
          ),
          _resultList()
        ],
      ),
    );
  }
}
