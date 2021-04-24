import 'package:Neuronio/utils/DateTimeService.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class TimeSelectionWidget extends StatelessWidget {
  String title;
  bool enable;
  InputBorder border;
  bool forced = false;
  Function(DateTime) extraValidator;
  final TextEditingController timeTextController;

  TimeSelectionWidget(
      {Key key,
      this.title,
      @required this.timeTextController,
      this.enable = true,
      this.border,
      this.forced,
      this.extraValidator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DateTimeField(
        controller: timeTextController,
        format: intl.DateFormat("HH:mm"),
        enabled: this.enable,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        validator: (pattern) {
          if (this.forced) {
            if (pattern == null) {
              return "فیلد خالی است!";
            }
          }
          return extraValidator != null
              ? (extraValidator(pattern) ?? null)
              : null;
        },
        decoration: InputDecoration(
            hintText: title, labelText: title, border: this.border),
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
