import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TimeSelectionWidget extends StatelessWidget {
  const TimeSelectionWidget({
    Key key,
    @required this.timeTextController,
  }) : super(key: key);

  final TextEditingController timeTextController;

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      controller: timeTextController,
      format: DateFormat("HH:mm"),
      onShowPicker: (context, currentValue) async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
              currentValue ?? DateTimeService.getCurrentDateTime()),
        );
        return DateTimeField.convert(time);
      },
    );
  }
}