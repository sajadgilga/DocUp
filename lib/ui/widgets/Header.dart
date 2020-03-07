import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final Widget child;

  Header({Key key, this.child}) : super(key: key);

  Widget _docUpIcon() {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Image(
        image: AssetImage('assets/DocUpHome.png'),
        width: 100,
        height: 100,
      ),
      alignment: Alignment.centerRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          child,
          _docUpIcon(),
        ],
      ),
      padding: EdgeInsets.only(left: 20, right: 10),
    );
  }
}
