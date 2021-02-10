import 'dart:io';

import 'package:Neuronio/blocs/SearchBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/models/VisitResponseEntity.dart';
import 'package:Neuronio/ui/home/SearchBox.dart';
import 'package:Neuronio/ui/visitsList/visitSearchResult/VisitResult.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/Waiting.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisitRequestsPage extends StatelessWidget {
  final Function(String, UserEntity) onPush;
  TextEditingController _controller = TextEditingController();

//  SearchBloc searchBloc = SearchBloc();

  VisitRequestsPage({@required this.onPush});

  void _search(context) {
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    searchBloc.add(SearchVisit(text: _controller.text, acceptStatus: 0));

//    FocusScope.of(context).unfocus();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  void _initialSearch(context) {
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    searchBloc.add(SearchLoadingEvent());
    searchBloc.add(SearchVisit(text: _controller.text, acceptStatus: 0));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller?.dispose();
  }

  Widget _docupIcon() => Container(
        padding: EdgeInsets.only(top: 20, right: 40, bottom: 20),
        child: Image.asset(Assets.docupIcon, width: 50),
//        child: CrossPlatformSvg.asset(Assets.docupIcon, width: 50),
        alignment: Alignment.centerRight,
      );

  Widget _backArrow(context) {
    return (CrossPlatformDeviceDetection.isIOS
        ? GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                margin: EdgeInsets.only(left: 40),
                child: Icon(
                  Icons.keyboard_backspace,
                  color: IColors.themeColor,
                  size: 30,
                )))
        : Container());
  }

  Widget _header(context) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[_backArrow(context), _docupIcon()],
        ),
      );

  Widget _searchListTitle() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Padding(
        padding: const EdgeInsets.only(right: 40, bottom: 5),
        child: AutoText(
          "درخواست ویزیت",
          softWrap: true,
          style: TextStyle(fontSize: 14),
        ),
      ),
    ]);
  }

//  Widget _searchBox(width, context) => Container(
//        margin: EdgeInsets.only(right: 40, left: 40),
//        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
//        decoration: BoxDecoration(
//            color: Colors.white,
//            borderRadius: BorderRadius.all(Radius.circular(80))),
//        child: TextField(
//          controller: _controller,
//          onSubmitted: (text) {
//            _search(context);
//          },
//          textAlign: TextAlign.end,
//          textDirection: TextDirection.ltr,
//          decoration: InputDecoration(
//            border: InputBorder.none,
//            hintText: Strings.searchBoxHint,
//            prefixIcon: Icon(
//              Icons.search,
//              size: 30,
//            ),
//          ),
//        ),
//      );

  Widget _todayItems(List<VisitEntity> results) {
    List<VisitEntity> todayVisits = [];
    results.forEach((element) {
      DateTime visitTime = DateTimeService.getDateTimeFromStandardString(element.visitTime);
      var now = DateTimeService.getCurrentDateTime();
      DateTime _today = DateTime(now.year, now.month, now.day, 23, 59, 59);
      if (visitTime.isBefore(_today)) todayVisits.add(element);
    });
    return VisitResultList(
      onPush: onPush,
      isDoctor: false,
      text: 'امروز',
      visitResults: todayVisits.reversed.toList(),
      emptyText: Strings.emptyRequestsDoctorSide,
      isRequestsOnly: true,
    );
  }

  Widget _nextDayItems(List<VisitEntity> results) {
    List<VisitEntity> nextDayVisits = [];
    results.forEach((element) {
      DateTime visitTime = DateTimeService.getDateTimeFromStandardString(element.visitTime);
      var now = DateTimeService.getCurrentDateTime();
      DateTime _today = DateTime(now.year, now.month, now.day, 23, 59, 59);
      if (visitTime.isAfter(_today)) nextDayVisits.add(element);
    });
    return VisitResultList(
      onPush: onPush,
      isDoctor: false,
      text: 'روزهای بعد',
      visitResults: nextDayVisits.reversed.toList(),
      emptyText: Strings.emptyRequestsDoctorSide,
      isRequestsOnly: true,
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
        if (state is SearchLoaded && state.result.visit_results != null) {
          return Container(
              margin: EdgeInsets.only(top: 20),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 260),
              child: ListView(
                children: <Widget>[
                  _searchListTitle(),
                  _todayItems(state.result.visit_results),
                  _nextDayItems(state.result.visit_results)
                ],
              ));
        }
        if (state is SearchError)
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 30,
                ),
                APICallError(
                  () {
                    _initialSearch(context);
                  },
                  tightenPage: true,
                ),
              ],
            ),
          );
        if (state is SearchLoading) {
          if (state.result == null || state.result.visit_results == null)
            return Container(
              child: Waiting(),
            );
          else
            return Container(
                margin: EdgeInsets.only(top: 20),
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 260),
                child: ListView(
                  children: <Widget>[
                    _searchListTitle(),
                    _todayItems(state.result.visit_results),
                    _nextDayItems(state.result.visit_results)
                  ],
                ));
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
    return SingleChildScrollView(
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            SearchBox(
                isPatient: false,
                controller: _controller,
                popMenuRect: Rect.fromLTRB(
                    MediaQuery.of(context).size.width * 2,
                    MediaQuery.of(context).size.height * (30 / 100),
                    0,
                    0),
                selectedIndex: 0,
                onMenuClick: null,
                hintText: "نام بیمار",
                filterPopup: false,
                popUpMenuItems: null,
                onChange: (String c) {
                  _search(context);
                }),
            _resultList()
          ],
        ),
      ),
    );
  }
}
