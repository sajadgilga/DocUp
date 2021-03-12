import 'package:flutter/widgets.dart';

import 'AutoText.dart';

class Waiting extends StatelessWidget {
  final bool textFlag;
  final bool gifFlag;
  double width;

  Waiting({this.textFlag = true, this.gifFlag = true, this.width = 70});

  @override
  Widget build(BuildContext context) {
    this.width = this.width ?? 70;
    return Container(
      width: this.width + 10.0 + (textFlag ? 200.0 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          gifFlag
              ? Image.asset(
                  "assets/loading.gif",
                  width: this.width,
                  height: this.width,
                )
              : SizedBox(),
          SizedBox(
            width: 10,
          ),
          textFlag
              ? AutoText(
                  "منتظر باشید",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
