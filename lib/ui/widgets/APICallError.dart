import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class APICallError extends StatelessWidget {
  final String errorMessage;

  final Function onRetryPressed;

  const APICallError(
      {Key key, this.errorMessage = "error", this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// TODO
    double x = MediaQuery.of(context).size.width;
    double y = MediaQuery.of(context).size.height;
    double imageWidth = x * (150 / 360);
    return Container(
        height: y,
        width: x,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: x * (41 / 360)),
              width: imageWidth,
              child: SvgPicture.asset(
                Assets.apiCallError,
                width: imageWidth,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "خطا در برقراری ارتباط",
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "لطفا اتصال به اینترنت را بررسی" +
                      "\n" +
                      " کنید و مجددا تلاش نمایید.",
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                  ),
                ),
                Text(
                  errorMessage,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
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
