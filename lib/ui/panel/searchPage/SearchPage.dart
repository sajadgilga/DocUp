import 'dart:collection';
import 'dart:io';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/blocs/VisitBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/SearchResult.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/home/SearchBox.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/PopupMenues/PopUpMenus.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ResultList.dart';

class PartnerSearchPage extends StatefulWidget {
  final Function(String, UserEntity) onPush;
  final isRequestPage;
  final int clinicIdDoctorSearch;

  PartnerSearchPage(
      {Key key, this.onPush, this.isRequestPage, this.clinicIdDoctorSearch})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PartnerSearchPageState(onPush: onPush, isRequestPage: isRequestPage);
  }
}

class PartnerSearchPageState extends State<PartnerSearchPage> {
  final Function(String, UserEntity) onPush;
  final isRequestPage;
  TextEditingController _controller = TextEditingController();
  LinkedHashMap<int, List<UserEntity>> orderedPageItems = new LinkedHashMap();
  bool allItemsFetched = false;
  String filterString = "";

  void _updatePageItemsAndPagingFlags(SearchResult result) {
    orderedPageItems[result.next ?? 1] =
        (result.isDoctor ? result.doctor_results : result.patient_results);
    allItemsFetched = allItemsFetched || result.next == null;
  }

  List<UserEntity> _getItemsFromOrderedPageItem() {
    List<UserEntity> res = [];
    orderedPageItems.forEach((key, value) {
      res.addAll(value);
    });
    return res;
  }

  PartnerSearchPageState({@required this.onPush, this.isRequestPage = false});

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _initialSearch(context);
    super.initState();
  }

  void _search(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    if (_state.entity.isDoctor)
      searchBloc.add(SearchPatient(
          text: _controller.text,
          isRequestOnly: isRequestPage,
          patientFilter: filterString));
    else if (_state.entity.isPatient)
      searchBloc.add(SearchDoctor(
          paramSearch: _controller.text,
          clinicId: widget.clinicIdDoctorSearch,
          expertise: filterString));

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  void _initialSearch(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    if (_state.entity.isDoctor)
      searchBloc.add(SearchPatient(
          text: _controller.text,
          isRequestOnly: isRequestPage,
          patientFilter: filterString));
    else if (_state.entity.isPatient)
      searchBloc.add(SearchDoctor(
          paramSearch: _controller.text,
          clinicId: widget.clinicIdDoctorSearch,
          expertise: filterString));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller?.dispose();
  }

//  Widget _docupIcon() => Container(
//        padding: EdgeInsets.only(top: 20, right: 40, bottom: 20),
//        child: Image.asset(Assets.docupIcon, width: 50),
////        child: SvgPicture.asset(Assets.docupIcon, width: 50),
//        alignment: Alignment.centerRight,
//      );
//
//  Widget _backArrow(context) {
//    return (Platform.isIOS
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
        if (state is SearchLoaded) {
          _updatePageItemsAndPagingFlags(state.result);
          return ResultList(
            onPush: onPush,
            isDoctor: state.result.isDoctor,
            results: _getItemsFromOrderedPageItem(),
            isRequestsOnly: isRequestPage,
            nextPageFetchLoader: !allItemsFetched,
          );
        }
        if (state is SearchError)
          APICallError(
            errorMessage: "",
          );
        if (state is SearchLoading) {
          if (state.result == null)
            return Container(
              child: Waiting(),
            );
          else {
            _updatePageItemsAndPagingFlags(state.result);
            return ResultList(
              onPush: onPush,
              isDoctor: state.result.isDoctor,
              results: _getItemsFromOrderedPageItem(),
              nextPageFetchLoader: !allItemsFetched,
              isRequestsOnly: isRequestPage,
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
              popMenuRect: Rect.fromLTRB(MediaQuery.of(context).size.width * 2,
                  MediaQuery.of(context).size.height * (30 / 100), 0, 0),
              selectedIndex: 0,
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
