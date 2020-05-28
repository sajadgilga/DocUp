import 'dart:io';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/blocs/VisitBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'ResultList.dart';

class SearchPage extends StatelessWidget {
  final Function(String, UserEntity) onPush;
  final isRequestPage;
  TextEditingController _controller = TextEditingController();

//  SearchBloc searchBloc = SearchBloc();

  SearchPage({@required this.onPush, this.isRequestPage = false});

  void _search(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    if (_state.entity.isDoctor)
      searchBloc.add(
          SearchPatient(text: _controller.text, isRequestOnly: isRequestPage));
    else if (_state.entity.isPatient)
      searchBloc.add(SearchDoctor(text: _controller.text));

    FocusScope.of(context).unfocus();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  void _initialSearch(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    if (_state.entity.isDoctor)
      searchBloc.add(
          SearchPatient(text: _controller.text, isRequestOnly: isRequestPage));
    else if (_state.entity.isPatient)
      searchBloc.add(SearchDoctor(text: _controller.text));
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
    return (Platform.isIOS
        ? GestureDetector(
            onTap: () {
              Navigator.maybePop(context);
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

  Widget _searchBox(width, context) => Container(
        margin: EdgeInsets.only(right: 40, left: 40),
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
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
          return ResultList(
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
            return ResultList(
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
          _header(context),
          _searchBox(MediaQuery.of(context).size.width, context),
          Expanded(flex: 2, child: _resultList())
        ],
      ),
    );
  }
}
