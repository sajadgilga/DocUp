import 'package:flutter/cupertino.dart';

class ALittleVerticalSpace extends StatelessWidget {
  final double height;

  ALittleVerticalSpace({double this.height = 20});

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

class MediumVerticalSpace extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(height: 20);
}
