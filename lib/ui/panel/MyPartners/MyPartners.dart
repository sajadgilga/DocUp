import 'dart:io';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/blocs/VisitBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/home/SearchBox.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'MyPartnersResultList.dart';

class MyPartners extends StatelessWidget {
  final Function(String, UserEntity) onPush;
  final isRequestPage;

//  SearchBloc searchBloc = SearchBloc();

  MyPartners({@required this.onPush, this.isRequestPage = false});

  void _initialSearch(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    if (_state.entity.isDoctor)
      searchBloc.add(SearchPatient(text: "", isRequestOnly: isRequestPage));
    else if (_state.entity.isPatient) searchBloc.add(SearchDoctor(paramSearch: ""));
  }

  @override
  void dispose() {}

  Widget _header(context) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(),
          child: Text(
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
//      BlocBuilder<VisitBloc, VisitState>(builder: (context, visitState) {
//      var _entity = BlocProvider.of<EntityBloc>(context).state.entity;
//      if (_entity.isDoctor) {
//        if (visitState is VisitLoaded) {
//          return ResultList(onPush: onPush, isDoctor: _entity.isDoctor, results: visitState.result.results,)
//        }
//      }
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoaded) {
          return MyPartnersResultList(
            onPush: onPush,
            isDoctor: state.result.isDoctor,
            results: (state.result.isDoctor
                ? state.result.doctor_results
                : state.result.patient_results),
            isRequestsOnly: isRequestPage,
          );
        }
        if (state is SearchError)
          return Container(
            child: Text('error!'),
          );
        if (state is SearchLoading) {
          if (state.result == null)
            return Container(
              child: Waiting(),
            );
          else
            return MyPartnersResultList(
              onPush: onPush,
              isDoctor: state.result.isDoctor,
              results: (state.result.isDoctor
                  ? state.result.doctor_results
                  : state.result.patient_results),
              isRequestsOnly: isRequestPage,
            );
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _initialSearch(context);
//    _search(context);
//    _controller.addListener((){print(_controller.text); });
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Column(
        children: <Widget>[
          PageTopLeftIcon(
            topLeft: Icon(
              Icons.arrow_back,
              color: IColors.themeColor,
              size: 20,
            ),
            topLeftFlag: false,
            topRight: Padding(
              padding: EdgeInsets.only(right: 25),
              child: menuLabel("پنل کاربری"),
            ),
            topRightFlag: true,
            onTap: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: 25, top: 20),
            child: _header(context),
          ),
          _resultList()
        ],
      ),
    );
  }
}
