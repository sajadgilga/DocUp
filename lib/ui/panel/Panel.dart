import 'package:docup/constants/colors.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/widgets/Header.dart';
import 'package:flutter/material.dart';

import 'ChatPage.dart';

enum PanelStates { PATIENT_DATA, DOCTOR_CHAT, VIDEO_CALL }

class Panel extends StatefulWidget {
  final Doctor doctor;

  Panel({Key key, this.doctor}) : super(key: key);

  @override
  PanelState createState() {
    return PanelState();
  }
}

class PanelState extends State<Panel> {
  PanelStates _state = PanelStates.DOCTOR_CHAT;

  Widget _header() => Header(
          child: Row(
        children: <Widget>[
          GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.only(top: 15, right: 10),
                child: Image(
                  image: AssetImage('assets/panelList.png'),
                  height: 40,
                  width: 40,
                ),
              )),
          Container(
            padding: EdgeInsets.only(top: 15, left: 5),
            child: GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.search,
                size: 30,
              ),
            ),
          )
        ],
      ));

  Widget _tabs(width) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 15),
          alignment: Alignment.bottomCenter,
          child: Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ),
        Container(
            padding: EdgeInsets.only(right: 20, left: 20),
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {},
                  color: (_state == PanelStates.VIDEO_CALL
                      ? IColors.red
                      : Colors.white),
                  child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      alignment: Alignment.center,
                      child: Text(
                        "تماس تصویری",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: (_state == PanelStates.VIDEO_CALL
                                ? Colors.white
                                : Colors.grey),
                            fontSize: 12),
                      )),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 5,
                ),
                RaisedButton(
                  onPressed: () {},
                  color: (_state == PanelStates.DOCTOR_CHAT
                      ? IColors.red
                      : Colors.white),
                  child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        "گفتگو با پزشک",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: (_state == PanelStates.DOCTOR_CHAT
                                ? Colors.white
                                : Colors.grey),
                            fontSize: 12),
                      )),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 5,
                ),
                RaisedButton(
                  onPressed: () {},
                  color: (_state == PanelStates.PATIENT_DATA
                      ? IColors.red
                      : Colors.white),
                  child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        "اطلاعات بیماری",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: (_state == PanelStates.PATIENT_DATA
                                ? Colors.white
                                : Colors.grey),
                            fontSize: 12),
                      )),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 5,
                ),
              ],
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
      child: Column(
        children: <Widget>[
          _header(),
          _tabs(MediaQuery.of(context).size.width),
          SizedBox(
            height: 20,
          ),
          Expanded(flex: 2, child: ChatPage(doctor: widget.doctor,))
        ],
      ),
    );
  }
}
