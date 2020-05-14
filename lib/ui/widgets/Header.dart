import 'package:docup/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Header extends StatelessWidget {
  final Widget child;

  Header({Key key, this.child}) : super(key: key);

  Widget _docUpIcon() {
    return Container(
      padding: EdgeInsets.only(top: 20, right: 20),
      child: Image.asset(Assets.docUpIcon, width: 35,),
//      SvgPicture.asset(
//        Assets.docUpIcon,
//        width: 35,
//        height: 35,
//      ),
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
