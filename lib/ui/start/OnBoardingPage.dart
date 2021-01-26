import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/IntroductionScreen2/WholeIntroChild.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/IntroductionScreen2/dots_decorator.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/IntroductionScreen2/introduction_screen.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/IntroductionScreen2/page_decoration.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/IntroductionScreen2/page_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'StartPage.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState2>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => StartPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration2(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen2(
      key: introKey,
      pages: [
        PageViewModel2(
          wholePageChild: WholeIntoChild1(),
          decoration: pageDecoration,
        ),
        PageViewModel2(
          wholePageChild: WholeIntoChild2(),
          decoration: pageDecoration,
        ),
        PageViewModel2(
          wholePageChild: WholeIntoChild3(
            onDone: () => _onIntroEnd(context),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () {},
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: AutoText(''),
      next: SizedBox(),
      done: SizedBox(),
      dotsDecorator: const DotsDecorator2(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
