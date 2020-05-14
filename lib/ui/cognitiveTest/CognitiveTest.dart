import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:flutter/cupertino.dart';

class CognitiveTest extends StatefulWidget {
  final ValueChanged<String> onPush;

  CognitiveTest({Key key,
    @required this.onPush})
      : super(key: key);

  @override
  _CognitiveTestState createState() => _CognitiveTestState();

}


class _CognitiveTestState extends State<CognitiveTest> {


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            DocUpHeader(title: "تست حافظه"),
          ],
        ));
  }

}