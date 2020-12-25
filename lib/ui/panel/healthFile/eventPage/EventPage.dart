import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/models/Event.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/home/notification/NotificationPage.dart';
import 'package:docup/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/FloatingButton.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//enum _MedicinePage { MAIN, CREATION }

class EventPage extends StatefulWidget {
  final Entity entity;
  final Function(String, dynamic) onPush;

  const EventPage({Key key, this.entity, this.onPush}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventPageState();
  }
}

class _EventPageState extends State<EventPage> {
//  _MedicinePage _currentPage = _MedicinePage.MAIN;
  List<Event> _events;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _floatingButton() {
    if (widget.entity.isPatient)
      return FloatingButton(
        label: 'رویدادهای سلامت',
        callback: () {
          showNextVersionDialog(context);
        },
        icon: Icons.search,
      );
    return FloatingButton(
      label: 'رویداد جدید',
      callback: () {
        showNextVersionDialog(context);
      },
      icon: Icons.add,
    );
  }

  Widget _eventList() {
    return Container(
      /// TODO
      // child: ListView.builder(
      //     shrinkWrap: true,
      //     scrollDirection: Axis.vertical,
      //     itemCount: _events.length,
      //     itemBuilder: (BuildContext context, int index) => NotificationItem(
      //           title: _events[index].title,
      //           description: _events[index].description,
      //           time: _events[index].time,
      //         )),
    );
  }

  Widget _emptyList() {
    return Container(
        margin: EdgeInsets.only(top: 50),
        child: Center(child: AutoText("رویداد سلامتی موجود نیست")));
  }

  Widget _body() {
    if (_events == null || _events.length == 0) return _emptyList();
    return _eventList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      SingleChildScrollView(
          child: Container(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    PartnerInfo(
                      entity: widget.entity,
                      onPush: widget.onPush,
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            right: 30, left: 30, top: 25, bottom: 20),
                        child: _body())
                  ]))),
      Align(
        alignment: Alignment(-.85, .9),
        child: _floatingButton(),
      )
    ]);
  }
}
