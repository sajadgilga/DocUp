import 'dart:collection';

import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/SearchBloc.dart';
import 'package:Neuronio/models/SearchResult.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/home/SearchBox.dart';
import 'package:Neuronio/ui/visit/VisitUtils.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/PopupMenues/PopUpMenus.dart';
import 'package:Neuronio/ui/widgets/Waiting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ResultList.dart';

class PartnerSearchPage extends StatefulWidget {
  final Function(String, UserEntity, int, VisitSource) onPush;
  final int clinicIdDoctorSearch;
  final Function(int) selectPage;

  PartnerSearchPage(
      {Key key, this.onPush, this.clinicIdDoctorSearch, this.selectPage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PartnerSearchPageState();
  }
}

class PartnerSearchPageState extends State<PartnerSearchPage> {
  TextEditingController _controller = TextEditingController();
  LinkedHashMap<int, List<UserEntity>> orderedPageItems = new LinkedHashMap();
  bool allItemsFetched = false;
  String filterString = "";

  void _updatePageItemsAndPagingFlags(SearchResult result) {
    orderedPageItems[result.next ?? 1] =
        (result.isDoctor ? result.doctorResults : result.patientResults);
    allItemsFetched = allItemsFetched || result.next == null;
  }

  List<UserEntity> _getItemsFromOrderedPageItem() {
    List<UserEntity> res = [];
    orderedPageItems.forEach((key, value) {
      res.addAll(value);
    });
    return res;
  }

  PartnerSearchPageState();

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _initialSearch(context);
    super.initState();
  }

  void _search(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    if (_state.entity.isDoctor &&
        [null, 0].contains(widget.clinicIdDoctorSearch))
      searchBloc.add(
          SearchPatient(text: _controller.text, patientFilter: filterString));
    else if (_state.entity.isPatient ||
        ![null, 0].contains(widget.clinicIdDoctorSearch))
      searchBloc.add(SearchDoctor(
          paramSearch: _controller.text,
          clinicId: widget.clinicIdDoctorSearch,
          expertise: filterString));

    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  void _initialSearch(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    if (_state.entity.isDoctor &&
        [null, 0].contains(widget.clinicIdDoctorSearch))
      searchBloc.add(
          SearchPatient(text: _controller.text, patientFilter: filterString));
    else if (_state.entity.isPatient ||
        ![null, 0].contains(widget.clinicIdDoctorSearch))
      searchBloc.add(SearchDoctor(
          paramSearch: _controller.text,
          clinicId: widget.clinicIdDoctorSearch,
          expertise: filterString));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    try {
      _controller?.dispose();
    } catch (e) {}
    super.dispose();
  }

//  Widget _docupIcon() => Container(
//        padding: EdgeInsets.only(top: 20, right: 40, bottom: 20),
//        child: Image.asset(Assets.docupIcon, width: 50),
////        child: CrossPlatformSvg.asset(Assets.docupIcon, width: 50),
//        alignment: Alignment.centerRight,
//      );
//
//  Widget _backArrow(context) {
//    return (PlatformDetection.isIOS
//        ? GestureDetector(
//            onTap: () {
//              Navigator.pop(context);
//            },
//            child: Container(
//                margin: EdgeInsets.only(left: 40),
//                child: Icon(
//                  Icons.keyboard_backspace,
//                  color: IColors.themeColor,
//                  size: 30,
//                )))
//        : Container());
//  }

//
//  Widget _header(context) => Container(
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          children: <Widget>[_backArrow(context), _docupIcon()],
//        ),
//      );

//  Widget _searchBox(width, context) => Padding(
//        padding: const EdgeInsets.only(top: 10),
//        child: Container(
//          margin: EdgeInsets.only(right: 40, left: 40),
//          padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
//          decoration: BoxDecoration(
//              color: Colors.white,
//              borderRadius: BorderRadius.all(Radius.circular(25))),
//          child: TextField(
//            controller: _controller,
//            onSubmitted: (text) {
//              _search(context);
//            },
//            textAlign: TextAlign.end,
//            textDirection: TextDirection.ltr,
//            decoration: InputDecoration(
//              border: InputBorder.none,
//              hintText: Strings.searchBoxHint,
//              prefixIcon: Icon(
//                Icons.search,
//                size: 30,
//              ),
//            ),
//          ),
//        ),
//      );

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
        if (state is SearchLoaded &&
            (state.result.isDoctor
                ? state.result.doctorResults != null
                : state.result.patientResults != null)) {
          _updatePageItemsAndPagingFlags(state.result);
          return PartnerResultList(
            onPush: widget.onPush,
            isDoctor: state.result.isDoctor,
            selectPage: widget.selectPage,
            results: _getItemsFromOrderedPageItem(),
            isRequestsOnly: false,
            nextPageFetchLoader: !allItemsFetched,
          );
        }
        if (state is SearchError)
          return APICallError(
            () {
              _initialSearch(context);
            },
          );
        if (state is SearchLoading) {
          if (state.result == null ||
              (state.result.isDoctor
                  ? state.result.doctorResults == null
                  : state.result.patientResults == null))
            return Container(
              child: Waiting(),
            );
          else {
            _updatePageItemsAndPagingFlags(state.result);
            return PartnerResultList(
              onPush: widget.onPush,
              isDoctor: state.result.isDoctor,
              selectPage: widget.selectPage,
              results: _getItemsFromOrderedPageItem(),
              nextPageFetchLoader: !allItemsFetched,
              isRequestsOnly: false,
            );
          }
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: SearchBox(
              isPatient: !_state.entity.isDoctor,
              controller: _controller,
              popMenuRect: Rect.fromLTRB(
                  0,
                  0,
                  MediaQuery.of(context).size.width * 2,
                  MediaQuery.of(context).size.height * (2.5 / 100)),
              onMenuClick: (MenuItemProvider item) {
                filterString = item.menuTitle;
                _search(context);
              },
              popUpMenuItems: !_state.entity.isDoctor
                  ? [
                      "همه",
                      "پوست و زیبایی",
                      "مغز و اعصاب",
                      "قلب و عروق",
                      "دکترای کاردرمانی"
                    ]
                  : ["همه", "در انتظار تایید", "درمان موفق", "در حال درمان"],
              onChange: (String c) {
                _search(context);
              },
            ),
          ),
          Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 11, vertical: 14),
                child: Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 250, 250, 250),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: _resultList()),
              ))
        ],
      ),
    );
  }
}
