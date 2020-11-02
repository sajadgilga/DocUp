import 'package:flutter/material.dart';

import 'Waiting.dart';

class DocUpAPICallLoading extends StatelessWidget {
  DocUpAPICallLoading();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Waiting(),
      ),
    );
  }
}

class DocUpAPICallLoading2 extends StatelessWidget {
  final bool textFlag;
  final double width;
  final double height;

  DocUpAPICallLoading2({this.textFlag = true, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height ?? MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      child: Center(
        child: Waiting(
          textFlag: textFlag,
          width: width,
        ),
      ),
    );
  }
}

class APICallLoadingProgress extends StatelessWidget {
  final Color colors;

  APICallLoadingProgress({this.colors});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Waiting()],
        ),
      ),
    );
  }
}
