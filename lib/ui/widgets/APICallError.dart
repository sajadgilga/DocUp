import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:flutter/material.dart';

class APICallError extends StatelessWidget {
  final String errorMessage;

  final Function onRetryPressed;

  const APICallError(
      {Key key, this.errorMessage = "error", this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// TODO
    return Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: Image.asset(Assets.apiCallError),
            ),
            Column(
              children: [
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                ActionButton(
                  color: IColors.themeColor,
                  textColor: IColors.whiteTransparent,
                  title: 'Retry',
                  borderRadius: 10,
                  callBack: onRetryPressed,
                )
              ],
            )
          ],
        ));
  }
}
