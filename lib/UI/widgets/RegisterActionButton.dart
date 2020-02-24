import 'package:docup/UI/main_pageUI/main_page.dart';
import 'package:docup/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RegisterActionButton extends StatelessWidget {
  const RegisterActionButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
          side: BorderSide(color: Colors.red)),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MainPage()));
      },
      color: Colors.red,
      textColor: Colors.white,
      label: Padding(
        padding:
        EdgeInsets.only(bottom: 10.0, top: 10.0, right: 10.0),
        child: Text(Strings.registerAction,
            style: TextStyle(fontSize: 16)),
      ),
      icon: Padding(
          padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
          child: Icon(
            Icons.arrow_back_ios,
            size: 18.0,
          )),
    );
  }
}
