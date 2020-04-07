import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/colors.dart';

enum Medicine { capsule, syrup, ointment }

extension MedicineExtension on Medicine {
  String get asset {
    switch (this) {
      case Medicine.capsule:
        return 'assets/capsule.svg';
      case Medicine.syrup:
        return 'assets/syrup.svg';
      case Medicine.ointment:
        return 'assets/ointment.svg';
      default:
        return '';
    }
  }
}

enum ReminderState { done, overdue, near }

extension ReminderStateExtension on ReminderState {
  Color get color {
    switch (this) {
      case ReminderState.done:
        return Colors.green;
      case ReminderState.near:
        return IColors.themeColor;
      case ReminderState.overdue:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Border get border {
    switch (this) {
      case ReminderState.done:
        return Border.all(width: 0);
      case ReminderState.near:
        return Border.all(width: 4.0, color: this.color);
      case ReminderState.overdue:
        return Border.all(width: 4.0, color: this.color);
      default:
        return Border.all(width: 0);
    }
  }

  Color get shadow {
    switch (this) {
      case ReminderState.done:
        return Colors.white;
      case ReminderState.near:
        return Colors.black;
      case ReminderState.overdue:
        return Colors.black;
      default:
        return Colors.black;
    }
  }
}

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

//  Color getCurrentColor() {
//    return (_reminderState == ReminderState.near
//        ? IColors.red
//        : (_reminderState == ReminderState.done ? Colors.green : Colors.grey));
//  }

  void _finishReminder() {
    setState(() {
      _reminderState = (_reminderState == ReminderState.done
          ? ReminderState.near
          : ReminderState.done);
    });
  }

//  String _getAsset() {
//    return (widget.type == Medicine.capsule
//        ? 'assets/capsule.svg'
//        : (widget.type == Medicine.syrup)
//            ? 'assets/syrup.svg'
//            : 'assets/ointment.svg');
//  }

  Widget radioButton(bool isSelected) => Container(
        width: 16,
        height: 16,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _reminderState.color, width: 2.0)),
        child: isSelected
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: _reminderState.color),
              )
            : Container(),
      );

  Widget _header() => Align(
        alignment: Alignment.center,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(
            'ساعت ${widget.time}',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                color: _reminderState.color,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          GestureDetector(
            child: radioButton(_reminderState == ReminderState.done),
          ),
        ]),
      );

  BoxDecoration _reminderBoxDecoration() => BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        border: _reminderState.border,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      );

  Widget _reminderBox() => Container(
      constraints: BoxConstraints(maxHeight: 120, maxWidth: 120),
      child: Stack(
        children: <Widget>[
          InkWell(
            child: DecoratedBox(
              decoration: _reminderBoxDecoration(),
              child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Column(children: <Widget>[
                    _header(),
                    SizedBox(
                      height: 10,
                    ),
                    SvgPicture.asset(
                      widget.type.asset,
                      alignment: Alignment.center,
                      color: _reminderState.color,
                      width: 15,
                      height: 15,
                    ),
                    Text(
                      '${widget.count}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 8,
                          color: _reminderState.color,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.title}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: _reminderState.color,
                          fontWeight: FontWeight.w900),
                    ),
                  ])),
            ),
          ),
          Positioned.fill(
              child: new Material(
                  color: Colors.transparent,
                  child: new InkWell(
                    onTap: () {
                      _finishReminder();
                    },
                  )
              )
          ),
        ],
      ));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: AnimatedPhysicalModel(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          elevation: (_reminderState == ReminderState.done) ? 0 : 8.0,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          shadowColor: _reminderState.shadow,
          color: Colors.transparent,
          child: _reminderBox()),
    );
  }
}
