import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum Medicine { capsule, syrup, ointment }

enum ReminderState { done, overdue, near }

// ignore: must_be_immutable
class MedicineReminder extends StatefulWidget {
  String time;
  Medicine type;
  String title;
  String count;

//  Color color;

  MedicineReminder(this.time, this.title, this.type, this.count);

  @override
  _MedicineReminderState createState() {
    return _MedicineReminderState();
  }
}

class _MedicineReminderState extends State<MedicineReminder> {
  ReminderState _reminderState = ReminderState.near;

  Color getCurrentColor() {
    return (_reminderState == ReminderState.near
        ? Color.fromRGBO(254, 95, 85, 1)
        : (_reminderState == ReminderState.done ? Colors.green : Colors.grey));
  }

  void _finishReminder() {
    setState(() {
      _reminderState = (_reminderState == ReminderState.done
          ? ReminderState.near
          : ReminderState.done);
    });
  }

  String _getAsset() {
    return (widget.type == Medicine.capsule
        ? 'assets/capsule.svg'
        : (widget.type == Medicine.syrup)
            ? 'assets/syrup.svg'
            : 'assets/ointment.svg');
  }

  Widget radioButton(bool isSelected) => Container(
        width: 16,
        height: 16,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: getCurrentColor(), width: 2.0)),
        child: isSelected
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: getCurrentColor()),
              )
            : Container(),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        elevation: (_reminderState == ReminderState.done) ? 0 : 10.0,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        shadowColor: (_reminderState == ReminderState.done) ? Colors.black : Colors.white,
        color: Colors.white,
        child: Container(
            constraints: BoxConstraints(maxHeight: 120, maxWidth: 120),
            child: Stack(
              children: <Widget>[
                InkWell(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        border: (_reminderState == ReminderState.done
                            ? Border.all(width: 0.0)
                            : Border.all(width: 2.0, color: getCurrentColor())),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
//                        boxShadow: (_reminderState == ReminderState.done
//                            ? []
//                            : [
//                                BoxShadow(
//                                    color: Colors.black38,
//                                    offset: Offset(1, 1),
//                                    blurRadius: 20)
//                              ])
                    ),
                    child: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Column(children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'ساعت ${widget.time}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: getCurrentColor(),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    child: radioButton(
                                        _reminderState == ReminderState.done),
                                  ),
                                ]),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SvgPicture.asset(
                            _getAsset(),
                            alignment: Alignment.center,
                            color: getCurrentColor(),
                            width: 15,
                            height: 15,
                          ),
                          Text(
                            '${widget.count}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 8,
                                color: getCurrentColor(),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${widget.title}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: getCurrentColor(),
                                fontWeight: FontWeight.w900),
                          ),
                        ])),
                  ),
                  onTap: _finishReminder,
                )
              ],
            )));
  }
}
