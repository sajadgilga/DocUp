import 'package:flutter/material.dart';

import '../navigator_destination.dart';
import 'homeUI/home.dart';

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

  List<BottomNavigationBarItem> _bottomNavigationItems() {
    return navigator_destinations
        .map<BottomNavigationBarItem>((Destination destination) {
      return BottomNavigationBarItem(
          icon: (destination.hasImage
              ? CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTecOfjQvwGtwJf2sKG67szwVAPx__kvg2NbHDZaW_Ul6-Ojsj-'),
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
      onTap: (int index) => _change_text(),
      backgroundColor: Colors.white,
      unselectedItemColor: navigator_destinations[0].color,
      selectedItemColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
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

// For hexagon image
//                  icon: Stack(alignment: Alignment.center,children: <Widget>[
//                    Image(
//                      image: destination.image,
//                      width: MediaQuery.of(context).size.width * .08,
//                    ),
//                    Image(
//                      image: AssetImage('assets/hex.png'),
//                      width: MediaQuery.of(context).size.width * .08,
//                    )
//                  ]),
