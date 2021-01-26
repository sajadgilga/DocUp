import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;


class TimeSelectionWidget extends StatelessWidget {
  String title;

  TimeSelectionWidget({Key key, this.title, @required this.timeTextController})
      : super(key: key);

  final TextEditingController timeTextController;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DateTimeField(
        controller: timeTextController,
        format: intl.DateFormat("HH:mm"),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(hintText: title, labelText: title),
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(
                currentValue ?? DateTimeService.getCurrentDateTime()),
          );
          return DateTimeField.convert(time);
        },
      ),
    );
  }
}
