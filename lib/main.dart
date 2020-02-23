import 'package:flutter/material.dart';

import 'UI/main_pageUI/main_page.dart';
import 'constants/colors.dart';
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
      home: MainPage(),
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
  bool _isSelected = false;

  void _radio() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  Widget radioButton(bool isSelected) => Container(
        width: 16,
        height: 16,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2.0)),
        child: isSelected
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.black),
              )
            : Container(),
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
                "ثبت نام در داک آپ به عنوان",
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text("سلامت جو"),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: _radio,
                        child: radioButton(_isSelected),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 80),
              Text(
                "پزشک همراه شما",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              Text(
                "ثبت‌نام کنید و آنلاین پیگیر روند بهبود خود باشید",
              ),
              SizedBox(height: 50),
              TextField(
                decoration: InputDecoration(
                    hintText: "ایمیل یا شماره همراه",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                    )),
              ),
              RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red)),
                  onPressed: () {},
                  color: Colors.red,
                  textColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.arrow_back_ios,
                        size: 18.0,
                      ),
                      Text("دریافت", style: TextStyle(fontSize: 16)),
                    ],
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
