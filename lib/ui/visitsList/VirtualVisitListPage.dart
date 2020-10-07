import 'dart:io';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/blocs/VisitBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/searchPage/ResultList.dart';
import 'package:docup/ui/visitsList/visitSearchResult/VisitResult.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VirtualVisitList extends StatelessWidget {
  final Function(String, UserEntity) onPush;
  TextEditingController _controller = TextEditingController();

//  SearchBloc searchBloc = SearchBloc();

  VirtualVisitList({@required this.onPush});

  void _search(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    searchBloc.add(SearchPatient(text: _controller.text, isRequestOnly: true));

    FocusScope.of(context).unfocus();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  void _initialSearch(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    searchBloc.add(SearchPatient(text: _controller.text, isRequestOnly: true));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller?.dispose();
  }

  Widget _docupIcon() => Container(
        padding: EdgeInsets.only(top: 20, right: 40, bottom: 20),
        child: Image.asset(Assets.docupIcon, width: 50),
//        child: SvgPicture.asset(Assets.docupIcon, width: 50),
        alignment: Alignment.centerRight,
      );

  Widget _backArrow(context) {
    return (true
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
          children: <Widget>[_backArrow(context)],
        ),
      );

  Widget _searchBox(width, context) => Container(
        margin: EdgeInsets.only(right: 40, left: 40),
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        width: MediaQuery.of(context).size.width * (80 / 100),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(80))),
        child: TextField(
          controller: _controller,
          onSubmitted: (text) {
            _search(context);
          },
          textAlign: TextAlign.end,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: Strings.searchBoxHint,
            prefixIcon: Icon(
              Icons.search,
              size: 30,
            ),
          ),
        ),
      );

  Widget _todayItems(List<VisitEntity> results) {
    List<VisitEntity> todayVisits = [];
    results.forEach((element) {
      DateTime visitTime = DateTime.parse(element.visitTime);
      var now = DateTime.now();
      DateTime _today = DateTime(now.year, now.month, now.day, 23, 59, 59);
      if (visitTime.isBefore(_today)) todayVisits.add(element);
    });
    return VisitResultList(
      onPush: onPush,
      isDoctor: false,
      text: 'امروز',
      visitResults: todayVisits,
      emptyText: Strings.emptyVisitSearch,
      isRequestsOnly: true,
    );
  }

  Widget _nextDayItems(List<VisitEntity> results) {
    List<VisitEntity> nextDayVisits = [];
    results.forEach((element) {
      DateTime visitTime = DateTime.parse(element.visitTime);
      var now = DateTime.now();
      DateTime _today = DateTime(now.year, now.month, now.day, 23, 59, 59);
      if (visitTime.isAfter(_today)) nextDayVisits.add(element);
    });
    return VisitResultList(
      onPush: onPush,
      isDoctor: false,
      text: 'روزهای بعد',
      visitResults: nextDayVisits,
      emptyText: Strings.emptyVisitSearch,
      isRequestsOnly: true,
    );
  }

  Widget _searchListTitle() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Padding(
        padding: const EdgeInsets.only(right: 40, bottom: 5),
        child: Text(
          "ویزیت های مجازی",
          softWrap: true,
          style: TextStyle(fontSize: 14),
        ),
      ),
    ]);
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
            ),
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
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              _backArrow(context),
            ],
          ),
          _searchBox(MediaQuery.of(context).size.width, context),
          _resultList()
        ],
      ),
    );
  }
}
