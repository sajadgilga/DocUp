
import 'package:flutter/widgets.dart';

class Waiting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/loading.gif",
            width: 70,
            height: 70,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "منتظر باشید",
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
