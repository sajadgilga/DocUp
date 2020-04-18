import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/mainPage/MainPage.dart';
import 'package:docup/ui/start/OnBoardingPage.dart';
import 'package:docup/ui/start/StartPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RoleType.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    checkToken();
    super.initState();
  }

  Future<void> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("token")) {
      if (!prefs.containsKey('isPatient'))
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => StartPage()));
      bool isPatient = prefs.getBool("isPatient");
      switchRole(isPatient ? RoleType.PATIENT : RoleType.DOCTOR);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainPage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OnBoardingPage()));
    }
  }

  void switchRole(RoleType roleType) {
    BlocProvider.of<EntityBloc>(context).add(EntityChangeType(type: roleType));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: SvgPicture.asset(
            Assets.docUpIcon,
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.width * 0.4,
          ),
        ),
      ),
    );
  }
}
