import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Header extends StatelessWidget {
  final Widget child;
  final double top;

  Header({Key key, this.child, this.top = 25}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 0, top: top),
      constraints: BoxConstraints(maxHeight: 70, minHeight: 70),
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
