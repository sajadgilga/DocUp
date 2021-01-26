import 'package:Neuronio/utils/CrossPlatformSvg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants/colors.dart';
import '../AutoText.dart';

enum MedicineType { capsule, syrup, ointment }

extension MedicineExtension on MedicineType {
  String get asset {
    switch (this) {
      case MedicineType.capsule:
        return 'assets/capsule.svg';
      case MedicineType.syrup:
        return 'assets/syrup.svg';
      case MedicineType.ointment:
        return 'assets/ointment.svg';
      default:
        return '';
    }
  }
}

enum ReminderState { done, overdue, near, disabled }

extension ReminderStateExtension on ReminderState {
  Color get color {
    switch (this) {
      case ReminderState.done:
        return Colors.green;
      case ReminderState.near:
        return IColors.themeColor;
      case ReminderState.overdue:
        return Colors.grey;
      case ReminderState.disabled:
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
      case ReminderState.disabled:
        return Border.all(width: 0, color: this.color);
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
      case ReminderState.disabled:
        return Colors.white;
      default:
        return Colors.black;
    }
  }
}

// ignore: must_be_immutable
class MedicineReminder extends StatefulWidget {
  String time;
  MedicineType type;
  String title;
  String count;
  ReminderState state;
  double textSize;

//  Color color;

  MedicineReminder(this.time, this.title, this.type, this.count,
      {this.state = null, this.textSize = 12.0});

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

  @override
  void initState() {
    if (widget.state != null) _reminderState = widget.state;
    super.initState();
  }

  @override
  void didUpdateWidget(MedicineReminder oldWidget) {
    if (widget.state != null) _reminderState = widget.state;
    super.didUpdateWidget(oldWidget);
  }

  void _finishReminder() {
    if (_reminderState == ReminderState.disabled) return;
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
          AutoText(
            'ساعت ${widget.time}',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: widget.textSize - 2,
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

  Widget _reminderBoxBody() => DecoratedBox(
        decoration: _reminderBoxDecoration(),
        child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Column(children: <Widget>[
              (widget.time == null
                  ? SizedBox(
                      height: 10,
                    )
                  : _header()),
              SizedBox(
                height: 10,
              ),
              CrossPlatformSvg.asset(
                widget.type.asset,
                alignment: Alignment.center,
                color: _reminderState.color,
                width: 15,
                height: 15,
              ),
              AutoText(
                '${widget.count}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: widget.textSize - 4,
                    color: _reminderState.color,
                    fontWeight: FontWeight.bold),
              ),
              AutoText(
                '${widget.title}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: widget.textSize,
                    color: _reminderState.color,
                    fontWeight: FontWeight.w900),
              ),
            ])),
      );

  Widget _reminderBox() => Container(
      constraints: BoxConstraints(maxHeight: 120, maxWidth: 120),
      child: Stack(
        children: <Widget>[
          InkWell(child: _reminderBoxBody()),
          Positioned.fill(
              child: new Material(
                  color: Colors.transparent,
                  child: new InkWell(
                    splashColor: (widget.time == null
                        ? Colors.transparent
                        : Theme.of(context).splashColor),
                    highlightColor: (widget.time == null
                        ? Colors.transparent
                        : Theme.of(context).highlightColor),
                    onTap: () {
                      _finishReminder();
                    },
                  ))),
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
