import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ResultList.dart';

class SearchPage extends StatelessWidget {
  final Function(String, UserEntity) onPush;
  TextEditingController _controller = TextEditingController();
//  SearchBloc searchBloc = SearchBloc();

  SearchPage({@required this.onPush});

  void _search(context) {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    if (_state.entity.isDoctor)
      searchBloc.add(SearchPatient(text: _controller.text));
    else if (_state.entity.isPatient)
      searchBloc.add(SearchDoctor(text: _controller.text));

    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
  }

  Widget _docUpIcon() => Container(
        padding: EdgeInsets.only(top: 10, right: 10),
        child: Image(
          image: AssetImage(Assets.docUpIcon),
          width: 100,
          height: 100,
        ),
        alignment: Alignment.centerRight,
      );

  Widget _header() => _docUpIcon();

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
    return BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchLoaded) {
              return ResultList(
                onPush: onPush,
                isDoctor: state.result.isDoctor,
                results: (state.result.isDoctor
                    ? state.result.doctor_results
                    : state.result.patient_results),
              );
            } else if (state is SearchError)
              return Container(
                child: Text('error!'),
              );
            return
              Container();
          },
        );
  }

  @override
  Widget build(BuildContext context) {
//    _controller.addListener((){print(_controller.text); });
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Column(
        children: <Widget>[
          _header(),
          _searchBox(MediaQuery.of(context).size.width, context),
          Expanded(flex: 2, child: _resultList())
        ],
      ),
    );
  }
}
