import 'package:docup/ui/doctor_detail/DoctorDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

import '../navigator_destination.dart';
import 'home/Home.dart';
import '../../constants/colors.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  String _text = 'goodi';
  int _count = 0;

  void _change_text() => setState(() => _text = 'something${_count++}');

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
      onTap: (int index) => _open_doctor_detail(),
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
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Image(
              image: AssetImage('assets/backgroundHome.png'),
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitWidth,
            ),
            Home()
          ],
        ),
      ),
    );
  }
}
