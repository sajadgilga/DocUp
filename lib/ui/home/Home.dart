import 'package:flutter/material.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:docup/ui/home/ReminderList.dart';
import 'package:docup/ui/home/SearchBox.dart';
import 'package:docup/ui/home/notification/NotificationPage.dart';
import 'package:docup/ui/home/notification/Notification.dart';

import 'package:docup/ui/home/iDoctor/IDoctor.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Doctor.dart';

class Home extends StatelessWidget {
  Widget _intro(double width) => ListView(
        padding: EdgeInsets.only(right: width * .075),
        shrinkWrap: true,
        children: <Widget>[
          Text(
            Strings.docUpIntroHomePart1,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 22),
          ),
          Text(
            Strings.docUpIntroHomePart2,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Image(
            image: AssetImage('assets/backgroundHome.png'),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          ),
          Container(
              child: Column(
            children: <Widget>[
              Header(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationPage()));
                      },
                      child: HomeNotification())),
              Container(
                height: 10,
              ),
              _intro(MediaQuery.of(context).size.width),
              Container(
                height: 20,
              ),
              SearchBox(),
              SizedBox(
                height: 30,
              ),
              Text(
                Strings.medicineReminder,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(
                  width: 20,
                  height: 20,
                  child: Divider(
                    thickness: 2,
                    color: Colors.white,
                  )),
              SizedBox(
                height: 10,
              ),
              ReminderList(),
              IDoctor(
                doctor: Doctor('دکتر زهرا شادلو', 'متخصص پوست', 'اقدسیه',
                    Image(image: AssetImage(' ')), null),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
