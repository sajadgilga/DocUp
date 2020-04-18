import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/strings.dart';
import '../../constants/colors.dart';

class SearchBox extends StatelessWidget {
  Function(String, UserEntity) onPush;
  TextEditingController _controller;
  bool isPatient;

  SearchBox({this.onPush, @required this.isPatient = true});

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
  }

  double _getSearchBoxWidth(width) {
    return (width > 550 ? width * .6 : (width > 400 ? width * .5 : width * .4));
  }

  void _search() {
    onPush(NavigatorRoutes.searchView, null);
  }

  Widget _filterText() {
    return Text((isPatient ? 'تخصص' : 'درحال درمان'),
        style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: IColors.themeColor));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .85,
      padding: EdgeInsets.only(
          top: 5,
          bottom: 20,
          left: MediaQuery.of(context).size.width * .07,
          right: MediaQuery.of(context).size.width * .04),
      decoration: BoxDecoration(
          color: Color.fromRGBO(247, 247, 247, .9),
          borderRadius: BorderRadius.all(Radius.circular(80))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
          Widget>[
        GestureDetector(
            onTap: () {
              _search();
            },
            child: Container(
              constraints: BoxConstraints(),
              child: SizedBox(
                  width: _getSearchBoxWidth(MediaQuery.of(context).size.width),
                  height: 50,
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (text) {
                      _search();
                    },
                    textAlign: TextAlign.end,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                        hintText: Strings.searchBoxHint,
                        prefixIcon: Icon(
                          Icons.search,
                          size: 30,
                        ),
                        focusColor: IColors.themeColor,
                        fillColor: IColors.themeColor),
                  )),
            )),
        Row(
          children: <Widget>[
            _filterText(),
            Container(
              child: Icon(
                Icons.filter_list,
                size: 20,
              ),
              margin: EdgeInsets.only(left: 5),
            ),
          ],
        )
      ]),
//      ),child: Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          TextField(
//            textAlign: TextAlign.end,
//            textDirection: TextDirection.rtl,
//            decoration: InputDecoration(
//                hintText: Strings.searchBoxHint, icon: Icon(Icons.search)),
//          ),
//          Icon(Icons.filter_list)
//        ],
//      ),
    );
  }
}
