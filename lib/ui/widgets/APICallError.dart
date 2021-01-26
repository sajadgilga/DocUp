import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/utils/CrossPlatformSvg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'AutoText.dart';

class APICallError extends StatelessWidget {
  final String errorMessage;
  final Function onRetryPressed;
  final bool tightenPage;
  final String defaultMessage = "بار دیگر تلاش کنید.";
  final bool withImage;

  const APICallError(this.onRetryPressed,
      {Key key,
      this.errorMessage,
      this.tightenPage = false,
      this.withImage = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// TODO
    double x = MediaQuery.of(context).size.width;
    double y = MediaQuery.of(context).size.height;
    double imageWidth = x * (120 / 360);
    return Container(
        height: tightenPage ? null : y,
        width: x,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: withImage?MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
          children: <Widget>[
            withImage
                ? Container(
                    padding: EdgeInsets.only(left: x * (10 / 360)),
                    width: imageWidth,
                    child: CrossPlatformSvg.asset(
                      Assets.apiCallError,
                      width: imageWidth,
                    ),
                  )
                : SizedBox(),
            Container(
              width: x - imageWidth,
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: withImage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.center,
                children: [
                  AutoText(
                    "خطا در برقراری ارتباط",
                    textAlign: withImage ? TextAlign.right : TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  AutoText(
                    "لطفا اتصال به اینترنت را بررسی" +
                        "\n" +
                        " کنید و مجددا تلاش نمایید.",
                    textAlign: withImage ? TextAlign.right : TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 6,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  AutoText(
                    kReleaseMode
                        ? defaultMessage
                        : (errorMessage ?? defaultMessage),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    maxLines: 20,
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
              ),
            )
          ],
        ));
  }
}
