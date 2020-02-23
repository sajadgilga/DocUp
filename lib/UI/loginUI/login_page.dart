import 'package:docup/UI/main_pageUI/main_page.dart';
import 'package:docup/UI/widgets/option_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../constants/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'iransans',
        primarySwatch: MaterialColor(0xFF880E4F, swatch),
      ),
//      home: MyHomePage(title: 'DocUp'),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Widget submitButton = RaisedButton.icon(
    shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(18.0),
        side: BorderSide(color: Colors.red)),
    onPressed: () {},
    color: Colors.red,
    textColor: Colors.white,
    label: Text("دریافت", style: TextStyle(fontSize: 16)),
    icon: Icon(
      Icons.arrow_back_ios,
      size: 18.0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                ": ثبت نام در داک آپ به عنوان",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      OptionButton("پزشک", "assets/doctor.svg", Colors.green),
                      SizedBox(width: 10,),
                      OptionButton("سلامت‌جو", "assets/team.svg", Colors.red),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40),
              Text(
                "پزشک همراه شما",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 5),
              Text(
                "ثبت‌نام کنید و آنلاین پیگیر روند بهبود خود باشید",
                style: TextStyle(
                  fontSize: 13
                ),
              ),
              SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.only(left: 40.0, right: 40.0),
                child: TextFormField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                      hintText: "ایمیل یا شماره همراه",
                      hintStyle: TextStyle(color: Colors.black, fontSize: 16.0),
                      labelStyle: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(height: 80.0),
              RaisedButton.icon(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.red)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
                },
                color: Colors.red,
                textColor: Colors.white,
                label: Padding(
                  padding:
                      EdgeInsets.only(bottom: 10.0, top: 10.0, right: 10.0),
                  child: Text("دریافت", style: TextStyle(fontSize: 16)),
                ),
                icon: Padding(
                    padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 18.0,
                    )),
              ),
              SizedBox(height: 20.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("ورود",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                            decoration: TextDecoration.underline)),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text("حساب کاربری دارید؟", style: TextStyle(fontSize: 13)),
                  ])
            ],
          ),
        ],
      ),
    );
  }
}
