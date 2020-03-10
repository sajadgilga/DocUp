import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

class ResultList extends StatefulWidget {
  final ValueChanged<String> onPush;


  ResultList({this.onPush});

  @override
  _ResultListState createState() => _ResultListState();
}

class _ResultListState extends State<ResultList> {
  static Doctor _doctor1 = Doctor(
      "دکتر زهرا شادلو",
      "متخصص پوست",
      "اقدسیه",
      Image(
        image: AssetImage('assets/lion.jpg'),
      ),
      []);
static Doctor _doctor2 = Doctor(
      "دکتر عارفه اسدی",
      "متخصص پوست",
      "اقدسیه",
      Image(
        image: AssetImage('assets/doctor1.jpg'),
      ),
      []);

  List<Doctor> _results = [_doctor1, _doctor2];

  @override
  Widget build(BuildContext context) {
    List<_SearchResultItem> results = [];

    for (var result in _results) {
      results.add(_SearchResultItem(
        onPush: widget.onPush,
        doctor: result,
      ));
    }
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 60),
      margin: EdgeInsets.only(top: 50, right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            child: Text(
              'نتایج جستجو',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView(
              children: results,
            ),
          )
        ],
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final Doctor doctor;
  final ValueChanged<String> onPush;

  _SearchResultItem({Key key, this.doctor, this.onPush}) : super(key: key);

  void _showDoctorDialogue() {
    onPush(NavigatorRoutes.doctorDialogue);
  }

  Widget _image() => GestureDetector(
      onTap: _showDoctorDialogue,
      child: Container(
          child: Container(
              width: 70,
              child: Hero(
                  tag: 'doctorImage${doctor.name}',
                  child: ClipPolygon(
                    sides: 6,
                    rotate: 90,
                    child: doctor.image,
                  )))));

  Widget _info() => Container(
        margin: EdgeInsets.only(right: 20),
        child: Column(
          children: <Widget>[
            Text(
              doctor.name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              textAlign: TextAlign.right,
            ),
            Text(
              doctor.speciality,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[_info(), _image()],
      ),
    );
  }
}
