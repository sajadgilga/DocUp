import 'package:docup/ui/widgets/IntroductionScreen2/introContent.dart';
import 'package:docup/ui/widgets/IntroductionScreen2/page_view_model.dart';
import 'package:flutter/material.dart';

class IntroPage2 extends StatelessWidget {
  final PageViewModel2 page;

  const IntroPage2({Key key, @required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: page.decoration.pageColor,
      decoration: page.decoration.boxDecoration,
      child: SafeArea(
        top: false,
        child: page.wholePageChild != null
            ? page.wholePageChild
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (page.image != null)
                    Expanded(
                      flex: page.decoration.imageFlex,
                      child: Padding(
                        padding: page.decoration.imagePadding,
                        child: page.image,
                      ),
                    ),
                  Expanded(
                    flex: page.decoration.bodyFlex,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 70.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: IntroContent2(page: page),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
