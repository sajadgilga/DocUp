import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';

import 'ResultList.dart';

class SearchPage extends StatelessWidget {
  final ValueChanged<String> onPush;
  TextEditingController _controller = TextEditingController();

  SearchPage({@required this.onPush});

  void _search() {}

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
  }

  Widget _docUpIcon() => Container(
        padding: EdgeInsets.only(top: 10, right: 10),
        child: Image(
          image: AssetImage('assets/DocUpHome.png'),
          width: 100,
          height: 100,
        ),
        alignment: Alignment.centerRight,
      );

  Widget _header() => _docUpIcon();

  Widget _searchBox(width) => Container(
        margin: EdgeInsets.only(right: 40, left: 40),
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(80))),
        child: TextField(
          controller: _controller,
          onSubmitted: (text) {
            _search();
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

  @override
  Widget build(BuildContext context) {
//    _controller.addListener((){print(_controller.text); });
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Column(
        children: <Widget>[
          _header(),
          _searchBox(MediaQuery.of(context).size.width),
          Expanded(
              flex: 2,
              child: ResultList(
                onPush: onPush,
              ))
        ],
      ),
    );
  }
}
