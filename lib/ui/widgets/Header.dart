import 'package:docup/constants/assets.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Header extends StatelessWidget {
  final Widget child;

  Header({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          child,
          DocUpHeader(),
        ],
      ),
    );
  }
}
