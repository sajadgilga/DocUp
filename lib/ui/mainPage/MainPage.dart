import 'package:docup/ui/doctorDetail/DoctorDetailPage.dart';
import 'package:docup/ui/home/Home.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

import 'package:docup/ui/mainPage/navigator_destination.dart';
import '../../constants/colors.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  List<Widget> _children = [Home(), Panel()];
  int _currentIndex = 0;

  _open_doctor_detail() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DoctorDetailPage()));
  }

  List<BottomNavigationBarItem> _bottomNavigationItems() {
    return navigator_destinations
        .map<BottomNavigationBarItem>((Destination destination) {
      return BottomNavigationBarItem(
          icon: (destination.hasImage
              ? Container(
                  width: MediaQuery.of(context).size.width * .09,
                  child: ClipPolygon(
                    sides: 6,
                    rotate: 90,
                    boxShadows: [
                      PolygonBoxShadow(color: Colors.black, elevation: 1.0),
                      PolygonBoxShadow(color: Colors.grey, elevation: 2.0)
                    ],
                    child: Image(
                      image: destination.image,
                    ),
                  ),
                )
              : Icon(
                  destination.icon,
                  size: MediaQuery.of(context).size.width * .06,
                )),
          title: Text(
            destination.title,
          ),
          backgroundColor: Colors.white);
    }).toList();
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      items: _bottomNavigationItems(),
      currentIndex: _currentIndex,
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
      backgroundColor: Colors.white,
      unselectedItemColor: navigator_destinations[0].color,
      selectedItemColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: IColors.background,
        bottomNavigationBar: SizedBox(
          child: _bottomNavigationBar(),
        ),
        body: _children[_currentIndex]);
  }
}
