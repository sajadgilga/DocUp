library persian_datetime_picker;

import 'package:Neuronio/ui/visit/calendar/utils/consts.dart';
import 'package:flutter/material.dart';

import 'handle_picker2.dart';

class PersianDateTimePicker2 extends StatefulWidget {
  final initial;
  final type;
  final List<String> availableDates;

  /// null means all days are available
  final min;
  final max;
  final Color color;
  final Function(String) onSelect;

  PersianDateTimePicker2(
      {this.type = 'date',
      this.initial,
      this.availableDates,
      this.min = '',
      this.max = '',
      this.color = Colors.blueAccent,
      this.onSelect});

  @override
  _PersianDateTimePicker2State createState() => _PersianDateTimePicker2State();
}

class _PersianDateTimePicker2State extends State<PersianDateTimePicker2> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Global.color = widget.color;
    Global.pickerType = widget.type;
    Global.availableDates = widget.availableDates;
    Global.min = widget.min;
    Global.max = widget.max;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: HandlePicker2(
        type: widget.type,
        initDateTime: widget.initial,
        onSelect: widget.onSelect,
      ),
    );
  }
}
