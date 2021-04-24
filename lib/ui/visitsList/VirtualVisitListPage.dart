import 'package:Neuronio/blocs/SearchBloc.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/models/VisitResponseEntity.dart';
import 'package:Neuronio/ui/home/SearchBox.dart';
import 'package:Neuronio/ui/visitsList/visitSearchResult/VisitResult.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/ui/widgets/Waiting.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VirtualVisitList extends StatelessWidget {
  final Function(String, UserEntity) onPush;
  TextEditingController _controller = TextEditingController();

  VirtualVisitList({@required this.onPush});

  void _search(context) {
    BlocProvider.of<SearchBloc>(context).add(
        SearchVisit(text: _controller.text, acceptStatus: 1, visitType: 1));

//    FocusScope.of(context).unfocus();
//     SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  void _initialSearch(context) {
    BlocProvider.of<SearchBloc>(context).add(SearchLoadingEvent());
    BlocProvider.of<SearchBloc>(context).add(
        SearchVisit(text: _controller.text, acceptStatus: 1, visitType: 1));
  }

  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller?.dispose();
  }

//  Widget _searchBox(width, context) => Container(
//        margin: EdgeInsets.only(right: 40, left: 40),
//        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
//        width: MediaQuery.of(context).size.width * (80 / 100),
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
      DateTime visitTime =
          DateTimeService.getDateTimeFromStandardString(element.visitTime);
      var now = DateTimeService.getCurrentDateTime();
      DateTime _today = DateTime(now.year, now.month, now.day, 23, 59, 59);
      if (visitTime.isBefore(_today)) todayVisits.add(element);
    });
    return VisitResultList(
      onPush: onPush,
      isDoctor: false,
      text: 'امروز',
      visitResults: todayVisits.reversed.toList(),
      emptyText: InAppStrings.emptyVisitSearch,
      isRequestsOnly: true,
    );
  }

  Widget _nextDayItems(List<VisitEntity> results) {
    List<VisitEntity> nextDayVisits = [];
    results.forEach((element) {
      DateTime visitTime =
          DateTimeService.getDateTimeFromStandardString(element.visitTime);
      var now = DateTimeService.getCurrentDateTime();
      DateTime _today = DateTime(now.year, now.month, now.day, 23, 59, 59);
      if (visitTime.isAfter(_today)) nextDayVisits.add(element);
    });
    return VisitResultList(
      onPush: onPush,
      isDoctor: false,
      text: 'روزهای بعد',
      visitResults: nextDayVisits.reversed.toList(),
      emptyText: InAppStrings.emptyVisitSearch,
      isRequestsOnly: true,
    );
  }

  Widget _searchListTitle() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Padding(
        padding: const EdgeInsets.only(right: 40, bottom: 5),
        child: AutoText(
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
        if (state is SearchLoaded && state.result.visitResults != null) {
          return Container(
            margin: EdgeInsets.only(top: 20),
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 260),
            child: ListView(
              children: <Widget>[
                _searchListTitle(),
                _todayItems(state.result.visitResults),
                _nextDayItems(state.result.visitResults)
              ],
            ),
          );
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
          if (state.result == null || state.result.visitResults == null) {
            return Container(
              child: Waiting(),
            );
          } else {
            return Container(
                margin: EdgeInsets.only(top: 20),
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 260),
                child: ListView(
                  children: <Widget>[
                    _searchListTitle(),
                    _todayItems(state.result.visitResults),
                    _nextDayItems(state.result.visitResults)
                  ],
                ));
          }
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _initialSearch(context);
//    _search(context);
//    _controller.addListener((){print(_controller.text); });
    return SingleChildScrollView(
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        child: Column(
          children: <Widget>[
            ALittleVerticalSpace(),
            SearchBox(
                isPatient: false,
                controller: _controller,
                popMenuRect: Rect.fromLTRB(
                    MediaQuery.of(context).size.width * 2,
                    MediaQuery.of(context).size.height * (30 / 100),
                    0,
                    0),
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
