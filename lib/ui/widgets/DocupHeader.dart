import 'package:DocUp/constants/assets.dart';
import 'package:DocUp/constants/colors.dart';
import 'package:flutter/cupertino.dart';

class DocUpHeader extends StatelessWidget {

  final String title;

  DocUpHeader({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 20, right: 20),
          child: Container(
              width: 40, child: Image.asset(Assets.logoTransparent)),
          alignment: Alignment.centerRight,
        ),
        _headerWidget()
      ],
    );
  }

  _headerWidget() => Visibility(
    visible: title != null,
    child: Center(
        child: Text(title == null ? "" : title,
            style: TextStyle(color: IColors.themeColor, fontSize: 24))),
  );
}
