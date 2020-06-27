import 'package:docup/constants/colors.dart';
import 'package:flutter/material.dart';

class APICallLoading extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(IColors.themeColor),
          ),
        ],
      ),
    );
  }
}