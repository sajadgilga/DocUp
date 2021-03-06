import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/ui/BasePage.dart';
import 'package:Neuronio/ui/start/OnBoardingPage.dart';
import 'package:Neuronio/ui/start/StartPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    super.initState();
    checkToken();
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
          context, MaterialPageRoute(builder: (context) => BasePage()));
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
      backgroundColor: Color.fromRGBO(251, 252, 253, 1),
      body: Container(
        child: Center(
          child: Image.asset(
            Assets.logoRectangle,
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.width * 0.4,
          ),
        ),
      ),
    );
  }
}
