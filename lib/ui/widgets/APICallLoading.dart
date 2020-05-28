import 'package:docup/constants/colors.dart';
import 'package:flutter/material.dart';

class APICallLoading extends StatelessWidget {
  final String loadingMessage;

  const APICallLoading({Key key, this.loadingMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage == null ? "" : loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: IColors.themeColor,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(IColors.themeColor),
          ),
        ],
      ),
    );
  }
}