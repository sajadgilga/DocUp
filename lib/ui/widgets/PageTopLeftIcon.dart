import 'package:docup/constants/assets.dart';
import 'package:flutter/cupertino.dart';

class PageTopLeftIcon extends StatelessWidget {
  final Widget topLeft;
  final bool topLeftFlag;
  final Widget topRight;
  final bool topRightFlag;
  final Function() onTap;

  PageTopLeftIcon(
      {Key key,
      this.topLeft,
      this.topLeftFlag = true,
      this.topRight,
      this.topRightFlag = false,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 25, left: 20, bottom: 5),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: topLeftFlag ? topLeft : SizedBox(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: topRightFlag
                ? topRight
                : SizedBox(),
          ),
        ],
      ),
    );
  }
}
